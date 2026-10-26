// -----------------------------------------------------------------------------
// systolic_nxn.v -- parametrik NxN cikis-sabit sistolik dizi, AKISLI arayuz (G4)
//   C[N][N] = sum_k A[:,k] * B[k,:]   (tile; K = k_len cevrim boyunca akitilir)
//
// Arayuz:
//   start        : 1 cevrim darbe (busy iken yok sayilir). k_len ve PE'ler start kenarinda
//                  yakalanir/sifirlanir. Veri start kenarindan SONRAKI cevrimden itibaren verilir.
//   in_valid     : o cevrimde a_col/b_row gecerli. Tam k_len gecerli cevrim sonra kabul biter.
//                  Gecerli cevrimler arasinda bosluk (durma) olabilir: bosluk her iki akisa
//                  birden sifir sokar, hizalama bozulmaz.
//   a_col        : A[i][k], i=0..N-1  -> [i*A_W +: A_W]   (her cevrimde BIR sutun)
//   b_row        : B[k][j], j=0..N-1  -> [j*B_W +: B_W]   (her cevrimde BIR satir)
//   c_flat       : C[i][j] -> [(i*N+j)*ACC_W +: ACC_W], done=1 iken gecerli
//   busy / done  : done, bir sonraki start'a ya da rst'ye kadar 1 kalir.
//
// Skew: A satiri i, i cevrim; B sutunu j, j cevrim gecikmeli beslenir (kaydirma yazmaci).
//   PE(i,j) girisinde cevrim t'de k = t-i-j gorulur; ikisi de ayni k'yi gorur.
//   Sureler: besleme K cevrim, bosaltma 2N-2 cevrim -> tile = K + 2N - 2 cevrim
//   (N=4,K=4 -> 10 : eski systolic_4x4 ile ayni; N=8,K=64 -> 78).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module systolic_nxn #(
    parameter N     = 8,
    parameter A_W   = 9,
    parameter B_W   = 8,
    parameter ACC_W = 32,
    parameter K_W   = 11            // k_len genisligi (K <= 2^K_W - 1)
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     start,
    input  wire [K_W-1:0]           k_len,
    input  wire                     in_valid,
    input  wire [N*A_W-1:0]         a_col,
    input  wire [N*B_W-1:0]         b_row,
    output wire [N*N*ACC_W-1:0]     c_flat,
    output wire                     busy,
    output reg                      done
);
    localparam S_IDLE = 2'd0;
    localparam S_RUN  = 2'd1;
    localparam S_DONE = 2'd2;
    localparam DRAIN  = 2*N - 2;                     // bosaltma cevrimi
    localparam D_W    = 8;                           // dcnt genisligi (2N-2 <= 255)

    reg [1:0]       state;
    reg [K_W-1:0]   k_reg, kcnt;
    reg [D_W-1:0]   dcnt;
    reg             last_seen;                       // k_len'inci veri alindi

    wire start_ok = start && (state != S_RUN);
    wire run      = (state == S_RUN);
    assign busy   = run;
    wire in_ok    = run && in_valid && !last_seen && (kcnt < k_reg);
    wire pe_rst   = rst | start_ok;

    // ---- kontrol FSM'i ----
    always @(posedge clk) begin
        if (rst) begin
            state     <= S_IDLE;
            k_reg     <= {K_W{1'b0}};
            kcnt      <= {K_W{1'b0}};
            dcnt      <= {D_W{1'b0}};
            last_seen <= 1'b0;
            done      <= 1'b0;
        end else if (start_ok) begin
            k_reg     <= k_len;
            kcnt      <= {K_W{1'b0}};
            dcnt      <= {D_W{1'b0}};
            last_seen <= 1'b0;
            done      <= 1'b0;
            state     <= S_RUN;
        end else if (run) begin
            if (in_ok) begin
                kcnt <= kcnt + 1'b1;
                if (kcnt == k_reg - 1'b1) last_seen <= 1'b1;
            end else if (last_seen) begin
                if (dcnt == DRAIN - 1) begin
                    state <= S_DONE;
                    done  <= 1'b1;
                end else begin
                    dcnt <= dcnt + 1'b1;
                end
            end
        end
    end

    // ---- skew'li besleme (kaydirma yazmaci; gecersiz cevrimde sifir) ----
    wire [N*A_W-1:0] a_feed;
    wire [N*B_W-1:0] b_feed;

    genvar gi, gj;
    generate
        for (gi = 0; gi < N; gi = gi + 1) begin : g_skew_a
            wire [A_W-1:0] giris = in_ok ? a_col[gi*A_W +: A_W] : {A_W{1'b0}};
            if (gi == 0) begin : g_d0
                assign a_feed[gi*A_W +: A_W] = giris;
            end else begin : g_dn
                reg [A_W*gi-1:0] sr;
                always @(posedge clk) begin
                    if (pe_rst) sr <= {(A_W*gi){1'b0}};
                    else        sr <= (sr << A_W) | giris;
                end
                assign a_feed[gi*A_W +: A_W] = sr[A_W*(gi-1) +: A_W];
            end
        end
        for (gj = 0; gj < N; gj = gj + 1) begin : g_skew_b
            wire [B_W-1:0] giris = in_ok ? b_row[gj*B_W +: B_W] : {B_W{1'b0}};
            if (gj == 0) begin : g_d0
                assign b_feed[gj*B_W +: B_W] = giris;
            end else begin : g_dn
                reg [B_W*gj-1:0] sr;
                always @(posedge clk) begin
                    if (pe_rst) sr <= {(B_W*gj){1'b0}};
                    else        sr <= (sr << B_W) | giris;
                end
                assign b_feed[gj*B_W +: B_W] = sr[B_W*(gj-1) +: B_W];
            end
        end
    endgenerate

    // ---- NxN PE izgarasi ----
    // PE'ler arasi baglantilar net dizisi (paketlenmis genis vektor degil): hem sentez icin
    // esdeger hem de Icarus'ta her degisimde tum dilimlerin yeniden degerlendirilmesini onler.
    wire signed [A_W-1:0]   a_w   [0:N*N-1];
    wire signed [B_W-1:0]   b_w   [0:N*N-1];
    wire signed [ACC_W-1:0] acc_w [0:N*N-1];

    generate
        for (gi = 0; gi < N; gi = gi + 1) begin : g_row
            for (gj = 0; gj < N; gj = gj + 1) begin : g_col
                wire signed [A_W-1:0] a_in;
                wire signed [B_W-1:0] b_in;

                if (gj == 0) begin : g_a_edge
                    assign a_in = a_feed[gi*A_W +: A_W];
                end else begin : g_a_int
                    assign a_in = a_w[gi*N + gj - 1];            // soldaki PE
                end

                if (gi == 0) begin : g_b_edge
                    assign b_in = b_feed[gj*B_W +: B_W];
                end else begin : g_b_int
                    assign b_in = b_w[(gi-1)*N + gj];            // ustteki PE
                end

                pe #(.A_W(A_W), .B_W(B_W), .ACC_W(ACC_W)) u_pe (
                    .clk  (clk),
                    .rst  (pe_rst),
                    .en   (run),
                    .a_in (a_in),
                    .b_in (b_in),
                    .a_out(a_w[gi*N + gj]),
                    .b_out(b_w[gi*N + gj]),
                    .acc  (acc_w[gi*N + gj])
                );
                assign c_flat[(gi*N + gj)*ACC_W +: ACC_W] = acc_w[gi*N + gj];
            end
        end
    endgenerate

endmodule
