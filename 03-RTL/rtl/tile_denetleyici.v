// -----------------------------------------------------------------------------
// tile_denetleyici.v -- tile sirasi, adres ureteci, golge acc ve cikis katı (G5)
//
// Bir katmani isler:  Y[T x C] = X[T x K] * W^T,  T = 8*NB token, C = 8*np kanal.
//   her cikis paneli p (8 kanal), her token blogu b (8 token): K boyunca akit, 8x8 acc.
//   Sira: panel disi dongu, token blogu ic dongu (panel 8 blokta yeniden kullanilir).
//
// Veri duzeni (OKUBENI.md):
//   aktivasyon BRAM sozcugu (b*K + k): bayt i = X[b*8+i][k]      (64 bit)
//   panel sozcugu (k)                : bayt j = W[p*8+j][k]      (64 bit)
//   -> A sutunu k = aktivasyon sozcugu, B satiri k = panel sozcugu; her ikisi 1 cevrimde.
//
// Zamanlama: start cevriminde adres k=0 sunulur; BRAM okumasi 1 cevrim gecikmeli oldugundan
//   sistolik dizi cevrim t'de k=t verisini gorur. Tile bitince (done) bir sonraki tile
//   AYNI cevrimde baslatilir (ayni panel icinde). Tile periyodu = K+2N-2 (hesap) + 1 (baslatma) = K+15.
//
// Golge acc: tile bitince c_flat (8x8x32) golgeye kopyalanir, sistolik dizi hemen sonraki tile'a
//   gecer; golge, siradaki tile hesaplanirken 64 cevrimde (cikis sirasi: kanal j dis, token i ic)
//   bias eklenerek akitilir. Golge ancak K+15 >= 64 oldugunda guvenle ortusur (K>=49).
//
// Panel el sikismasi: pan_hazir[b]=1 -> tampon b dolu (host set eder). pan_bitti: panelin son tile
//   cikisi tamamlanip tampon bos oldugunda 1 cevrim darbe (pan_bitti_buf = bosalan tampon).
//   Host darbede hazir bitini siler, tamponu yeniden yazar, tekrar set eder.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module tile_denetleyici #(
    parameter N   = 8,
    parameter NB  = 8,          // token blogu sayisi (T = N*NB)
    parameter KW  = 11,
    parameter PW  = 7,          // panel sayaci genisligi (np <= 127)
    parameter AW  = 12          // aktivasyon BRAM adres genisligi (NB*K <= 4096)
) (
    input  wire              clk,
    input  wire              rst,
    // katman denetimi
    input  wire              kos,            // 1 cevrim darbe (IDLE iken)
    input  wire [KW-1:0]     cfg_k,
    input  wire [PW-1:0]     cfg_np,
    input  wire              a_isaretsiz,    // 1: A baytlari isaretsiz (UINT8 olasilik)
    output wire              busy,
    output reg               layer_done,
    // panel el sikismasi
    input  wire [1:0]        pan_hazir,
    output reg               pan_bitti,
    output reg               pan_bitti_buf,
    // aktivasyon BRAM (kayitli okuma)
    output wire [AW-1:0]     act_raddr,
    input  wire [63:0]       act_rdata,
    // panel tamponu
    output wire              pan_rbuf,
    output wire [KW-1:0]     pan_raddr,
    input  wire [63:0]       pan_rdata,
    // cikis kati bias/m0 sorgusu (panel_tamponu'na baglanir)
    output wire              out_pbuf,
    output wire [2:0]        out_rj,
    input  wire [31:0]       rbias,
    // cikis akisi (birikec + bias), kanal j dis, token i ic
    output reg               out_valid,
    output reg  [2:0]        out_i,
    output reg  [2:0]        out_j,
    output reg  [3:0]        out_blk,
    output reg  [PW-1:0]     out_panel,
    output reg               out_son,        // tile'in son elemani
    output reg signed [31:0] out_acc,
    // tanilama
    output reg               out_tasma       // golge ustune yazildi (yapisal hata)
);
    localparam S_IDLE  = 3'd0;
    localparam S_PWAIT = 3'd1;
    localparam S_FEED  = 3'd2;
    localparam S_WAIT  = 3'd3;
    localparam S_BITIR = 3'd4;

    reg [2:0]      state;
    reg [KW-1:0]   k_reg, rd_k;
    reg [PW-1:0]   np_reg, panel;
    reg [3:0]      blk;
    reg [AW-1:0]   abase;
    reg            cur_buf;

    wire [N*N*32-1:0] c_flat;
    wire              sys_done, sys_busy;

    // ---- tile baslatma / adresler ----
    wire go_same   = (state == S_WAIT) && sys_done && (blk != NB-1);
    wire go_pw     = (state == S_PWAIT) && pan_hazir[cur_buf];
    wire start_now = go_same | go_pw;
    wire [KW-1:0] rk_eff = start_now ? {KW{1'b0}} : rd_k;
    wire [AW-1:0] ab_eff = go_same ? (abase + k_reg) : abase;
    assign act_raddr = ab_eff + rk_eff;
    assign pan_raddr = rk_eff;
    assign pan_rbuf  = cur_buf;
    assign busy      = (state != S_IDLE);

    // ---- sistolik dizi ----
    wire [N*9-1:0] a_col;
    genvar gi;
    generate
        for (gi = 0; gi < N; gi = gi + 1) begin : g_a
            assign a_col[gi*9 +: 9] = a_isaretsiz ? {1'b0, act_rdata[gi*8 +: 8]}
                                                  : {act_rdata[gi*8+7], act_rdata[gi*8 +: 8]};
        end
    endgenerate

    systolic_nxn #(.N(N), .A_W(9), .B_W(8), .ACC_W(32), .K_W(KW)) u_dizi (
        .clk(clk), .rst(rst), .start(start_now), .k_len(k_reg),
        .in_valid(state == S_FEED), .a_col(a_col), .b_row(pan_rdata),
        .c_flat(c_flat), .busy(sys_busy), .done(sys_done));

    // ---- golge acc + cikis katı ----
    reg [N*N*32-1:0] golge;
    reg              o_run, o_buf, o_last;
    reg [5:0]        o_idx;
    reg [3:0]        o_blk;
    reg [PW-1:0]     o_panel;

    wire cap       = (state == S_WAIT) && sys_done;
    wire o_son_idx = (o_idx == 6'd63);
    assign out_pbuf = o_buf;
    assign out_rj   = o_idx[5:3];
    wire [2:0] o_i  = o_idx[2:0];
    wire [2:0] o_j  = o_idx[5:3];
    wire signed [31:0] elem = golge[(o_i*N + o_j)*32 +: 32];

    always @(posedge clk) begin
        if (rst) begin
            o_run <= 1'b0; o_idx <= 6'd0; out_valid <= 1'b0; out_son <= 1'b0; out_tasma <= 1'b0;
            pan_bitti <= 1'b0; pan_bitti_buf <= 1'b0; o_last <= 1'b0; o_buf <= 1'b0;
            o_blk <= 4'd0; o_panel <= {PW{1'b0}};
            out_i <= 3'd0; out_j <= 3'd0; out_blk <= 4'd0; out_panel <= {PW{1'b0}}; out_acc <= 32'sd0;
        end else begin
            pan_bitti <= 1'b0;
            out_valid <= o_run;
            out_son   <= o_run & o_son_idx;
            out_i     <= o_i;
            out_j     <= o_j;
            out_blk   <= o_blk;
            out_panel <= o_panel;
            out_acc   <= elem + $signed(rbias);
            if (o_run && o_son_idx) begin
                o_run <= 1'b0;
                if (o_last) begin pan_bitti <= 1'b1; pan_bitti_buf <= o_buf; end
            end else if (o_run) begin
                o_idx <= o_idx + 6'd1;
            end
            if (cap) begin
                if (o_run && !o_son_idx) out_tasma <= 1'b1;     // onceki akitma bitmeden golge ezildi
                golge   <= c_flat;
                o_buf   <= cur_buf;
                o_blk   <= blk;
                o_panel <= panel;
                o_last  <= (blk == NB-1);
                o_run   <= 1'b1;
                o_idx   <= 6'd0;
            end
        end
    end

    // ---- ana FSM ----
    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE; k_reg <= {KW{1'b0}}; rd_k <= {KW{1'b0}}; np_reg <= {PW{1'b0}};
            panel <= {PW{1'b0}}; blk <= 4'd0; abase <= {AW{1'b0}}; cur_buf <= 1'b0; layer_done <= 1'b0;
        end else begin
            layer_done <= 1'b0;
            case (state)
                S_IDLE: if (kos) begin
                    k_reg <= cfg_k; np_reg <= cfg_np; panel <= {PW{1'b0}}; blk <= 4'd0;
                    abase <= {AW{1'b0}}; cur_buf <= 1'b0; state <= S_PWAIT;
                end
                S_PWAIT: if (go_pw) begin
                    rd_k <= {{(KW-1){1'b0}}, 1'b1}; state <= S_FEED;
                end
                S_FEED: begin
                    rd_k <= rd_k + 1'b1;
                    if (rd_k == k_reg) state <= S_WAIT;
                end
                S_WAIT: if (sys_done) begin
                    if (go_same) begin
                        rd_k <= {{(KW-1){1'b0}}, 1'b1};
                        blk <= blk + 1'b1; abase <= ab_eff; state <= S_FEED;
                    end else if (panel == np_reg - 1'b1) begin
                        state <= S_BITIR;
                    end else begin
                        panel <= panel + 1'b1; cur_buf <= ~cur_buf; blk <= 4'd0; abase <= {AW{1'b0}};
                        state <= S_PWAIT;
                    end
                end
                S_BITIR: if (!o_run && !out_valid) begin
                    layer_done <= 1'b1; state <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
