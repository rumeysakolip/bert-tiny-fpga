// tb_tile.v -- tile_denetleyici + panel_tamponu + aktivasyon BRAM: bir dogrusal katmanin birikeci
// (bias dahil) altin test vektoru ile BIT-BIREBIR karsilastirilir (G5 kabul).
// -P parametreleri: K, C, NS (cumle sayisi).  vvp argumanlari: +vdir= +pdir= +ad=<kisa_ad> [+vcd=...]
//   vdir : 02-RTL_Altin_Model/03_Sonuclar/test_vektorleri   pdir : .../parametreler
// Panel yukleme host davranisidir: baslangicta panel 0,1; pan_bitti darbesinde bosalan tampona sonraki panel.
`timescale 1ns/1ps
module tb_tile;
    parameter K  = 128;
    parameter C  = 128;
    parameter NS = 4;
    parameter PER_S = 0;      // 1: B operandi (panel) cumle basina farkli (dikkat: K ve V aktivasyonlari)
    parameter AISGZ = 0;      // 1: A baytlari isaretsiz (UINT8 olasilik)
    parameter KMAX = 512;
    parameter KW = 11, PW = 7, AW = 12;
    localparam P  = C / 8;
    localparam NB = 8;

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    // aktivasyon BRAM yazma
    reg              aw_en = 0;
    reg  [AW-1:0]    aw_addr = 0;
    reg  [63:0]      aw_data = 0;
    wire [AW-1:0]    act_raddr;
    wire [63:0]      act_rdata;
    bram_sdp #(.AW(AW), .DW(64)) u_act (.clk(clk), .we(aw_en), .waddr(aw_addr), .wdata(aw_data),
                                        .raddr(act_raddr), .rdata(act_rdata));
    // panel tamponu
    reg              pw_en = 0, pw_buf = 0;
    reg  [1:0]       pw_sel = 0;
    reg  [KW-1:0]    pw_addr = 0;
    reg  [63:0]      pw_data = 0;
    wire             pan_rbuf;
    wire [KW-1:0]    pan_raddr;
    wire [63:0]      pan_rdata;
    wire             out_pbuf;
    wire [2:0]       out_rj;
    wire [31:0]      rbias;
    wire [30:0]      rm0;
    panel_tamponu #(.KMAX(KMAX), .KW(KW)) u_pan (.clk(clk), .pw_en(pw_en), .pw_buf(pw_buf), .pw_sel(pw_sel),
        .pw_addr(pw_addr), .pw_data(pw_data), .pr_buf(pan_rbuf), .pr_addr(pan_raddr), .pr_data(pan_rdata),
        .rbuf(out_pbuf), .rj(out_rj), .rbias(rbias), .rm0(rm0));

    reg              kos = 0;
    reg  [1:0]       pan_hazir = 0;
    wire             busy, layer_done, pan_bitti, pan_bitti_buf;
    wire             out_valid, out_son, out_tasma;
    wire [2:0]       out_i, out_j;
    wire [3:0]       out_blk;
    wire [PW-1:0]    out_panel;
    wire signed [31:0] out_acc;

    tile_denetleyici #(.N(8), .NB(NB), .KW(KW), .PW(PW), .AW(AW)) dut (
        .clk(clk), .rst(rst), .kos(kos), .cfg_k(K[KW-1:0]), .cfg_np(P[PW-1:0]), .a_isaretsiz(AISGZ[0]),
        .busy(busy), .layer_done(layer_done), .pan_hazir(pan_hazir), .pan_bitti(pan_bitti),
        .pan_bitti_buf(pan_bitti_buf), .act_raddr(act_raddr), .act_rdata(act_rdata),
        .pan_rbuf(pan_rbuf), .pan_raddr(pan_raddr), .pan_rdata(pan_rdata),
        .out_pbuf(out_pbuf), .out_rj(out_rj), .rbias(rbias),
        .out_valid(out_valid), .out_i(out_i), .out_j(out_j), .out_blk(out_blk), .out_panel(out_panel),
        .out_son(out_son), .out_acc(out_acc), .out_tasma(out_tasma));

    reg [63:0] memAct [0:NS*NB*K-1];
    reg [63:0] memW   [0:(PER_S ? NS : 1)*P*K-1];
    reg [31:0] memB   [0:C-1];
    reg [31:0] memExp [0:NS*64*C-1];
    reg [31:0] got    [0:NS*64*C-1];
    reg [255*8:1] vdir, pdir, ad, yol, vcdfile;

    integer s, errors, nchk, next_p, cyc, cyc0, tile_say, i, k, j, w;
    integer cyc_layer [0:NS-1];
    integer dolu_sayac;
    reg     bitti_goruldu, vcd_on;
    always @(posedge kos) if (vcd_on) begin #33000; $dumpoff; end       // VCD'yi ilk ~3300 cevrimle sinirla

    always @(posedge clk) cyc <= cyc + 1;
    always @(posedge clk) if (out_valid)
        got[(s*64 + out_blk*8 + out_i)*C + out_panel*8 + out_j] <= out_acc;
    always @(posedge clk) if (out_son) tile_say <= tile_say + 1;

    task yukle_panel;
        input integer p;
        input integer b;
        integer q;
        begin
            for (q = 0; q < K; q = q + 1) begin
                @(negedge clk); pw_en = 1; pw_buf = b; pw_sel = 0; pw_addr = q; pw_data = memW[(PER_S ? s*P*K : 0) + p*K + q];
            end
            for (q = 0; q < 8; q = q + 1) begin
                @(negedge clk); pw_en = 1; pw_buf = b; pw_sel = 1; pw_addr = q; pw_data = memB[p*8 + q];
            end
            @(negedge clk); pw_en = 0;
            pan_hazir[b] = 1'b1;
        end
    endtask

    // pan_bitti: bosalan tamponu yeniden doldur
    always @(posedge clk) if (pan_bitti) begin
        pan_hazir[pan_bitti_buf] = 1'b0;
        if (next_p < P) begin
            next_p = next_p + 1;
            yukle_panel(next_p - 1, pan_bitti_buf);
        end
    end

    initial begin
        cyc = 0; errors = 0; nchk = 0; tile_say = 0; s = 0; next_p = 0;
        if (!$value$plusargs("vdir=%s", vdir) || !$value$plusargs("pdir=%s", pdir) ||
            !$value$plusargs("ad=%s", ad)) begin
            $display("HATA: +vdir= +pdir= +ad= gerekli"); $display("TILE DENETLEYICI TEST: FAIL"); $finish;
        end
        vcd_on = $value$plusargs("vcd=%s", vcdfile);
        if (vcd_on) begin $dumpfile(vcdfile); $dumpvars(0, tb_tile); end
        $sformat(yol, "%0s/%0s_girdi_blok.mem", vdir, ad);  $readmemh(yol, memAct);
        $sformat(yol, "%0s/%0s_w_panel.mem", vdir, ad);     $readmemh(yol, memW);
        $sformat(yol, "%0s/%0s_b.mem", pdir, ad);           $readmemh(yol, memB);
        $sformat(yol, "%0s/%0s_birikec.mem", vdir, ad);     $readmemh(yol, memExp);

        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;
        repeat (3) @(posedge clk);

        for (s = 0; s < NS; s = s + 1) begin
            // 1) aktivasyonlari BRAM'e yukle (cumle s)
            for (w = 0; w < NB*K; w = w + 1) begin
                @(negedge clk); aw_en = 1; aw_addr = w; aw_data = memAct[s*NB*K + w];
            end
            @(negedge clk); aw_en = 0;
            // 2) ilk iki paneli yukle, sonrasini pan_bitti ile (host modeli)
            pan_hazir = 2'b00; next_p = 0;
            next_p = 1; yukle_panel(0, 0);
            if (P > 1) begin next_p = 2; yukle_panel(1, 1); end
            // 3) katmani baslat
            @(negedge clk); kos = 1; cyc0 = cyc;
            @(negedge clk); kos = 0;
            bitti_goruldu = 0;
            while (!bitti_goruldu && (cyc - cyc0) < 40*P*NB*(K+20)) begin
                @(posedge clk); #1;
                if (layer_done) bitti_goruldu = 1;
            end
            cyc_layer[s] = cyc - cyc0;
            if (!bitti_goruldu) begin
                errors = errors + 1; $display("  FAIL cumle %0d: zaman asimi", s);
            end
            repeat (4) @(posedge clk);
            // 4) karsilastir
            for (i = 0; i < 64*C; i = i + 1) begin
                nchk = nchk + 1;
                if (got[s*64*C + i] !== memExp[s*64*C + i]) begin
                    errors = errors + 1;
                    if (errors < 6) $display("  FAIL cumle %0d eleman %0d (token %0d kanal %0d): dut=%0d beklenen=%0d",
                        s, i, i / C, i % C, $signed(got[s*64*C + i]), $signed(memExp[s*64*C + i]));
                end
            end
            if (out_tasma) begin errors = errors + 1; $display("  FAIL: golge ustune yazildi (out_tasma)"); end
        end

        $display("----------------------------------------------");
        $display("KATMAN_CEVRIM %0s K=%0d C=%0d : cumle basina %0d %0d %0d %0d ; teorik (K+14)*P*NB = %0d ; tile sayisi %0d",
                 ad, K, C, cyc_layer[0], cyc_layer[1], cyc_layer[2], cyc_layer[3], (K+14)*P*NB, tile_say);
        if (errors == 0 && tile_say == NS*P*NB)
            $display("TILE DENETLEYICI TEST (%0s K=%0d C=%0d): PASS  (%0d kontrol, 0 hata)", ad, K, C, nchk);
        else
            $display("TILE DENETLEYICI TEST (%0s K=%0d C=%0d): FAIL  (%0d hata, tile %0d/%0d)", ad, K, C, errors, tile_say, NS*P*NB);
        $finish;
    end
endmodule
