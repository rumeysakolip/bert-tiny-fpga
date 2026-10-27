// tb_katman.v -- dogrusal_katman uctan uca: aktivasyon BRAM -> dizi -> +bias -> M0/n -> cikis BRAM.
// Cikis BRAM sozcukleri altin <ad>_cikis.mem (INT8) ile BIT-BIREBIR karsilastirilir (G7 kabul).
// -P: K, C, NS, SH (KAYDIRMA_<AD>), GELU (1: ffn1 icin LUT)    vvp: +vdir= +pdir= +ad= [+lut=<dosya>] [+sfx=cikis|gelu_cikis] [+vcd=]
`timescale 1ns/1ps
module tb_katman;
    parameter K = 128, C = 128, NS = 4, SH = 37, GELU = 0;
    parameter KMAX = 512, KW = 11, PW = 7, AW = 12;
    localparam P = C / 8;
    localparam NB = 8;

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg              kos = 0;
    reg              aw_en = 0;
    reg  [AW-1:0]    aw_addr = 0;
    reg  [63:0]      aw_data = 0;
    reg              pw_en = 0, pw_buf = 0;
    reg  [1:0]       pw_sel = 0;
    reg  [KW-1:0]    pw_addr = 0;
    reg  [63:0]      pw_data = 0;
    reg  [1:0]       pan_hazir = 0;
    reg              lw_en = 0;
    reg  [7:0]       lw_addr = 0, lw_data = 0;
    reg  [AW-1:0]    cr_addr = 0;
    wire [63:0]      cr_data;
    wire             busy, layer_done, pan_bitti, pan_bitti_buf, tasma_hata;
    wire [31:0]      kirpilan_say;

    dogrusal_katman #(.KMAX(KMAX), .KW(KW), .PW(PW), .AW(AW)) dut (
        .clk(clk), .rst(rst), .kos(kos), .cfg_k(K[KW-1:0]), .cfg_np(P[PW-1:0]), .cfg_n(SH[5:0]),
        .a_isaretsiz(1'b0), .gelu_en(GELU != 0), .busy(busy), .layer_done(layer_done),
        .aw_en(aw_en), .aw_addr(aw_addr), .aw_data(aw_data),
        .pw_en(pw_en), .pw_buf(pw_buf), .pw_sel(pw_sel), .pw_addr(pw_addr), .pw_data(pw_data),
        .pan_hazir(pan_hazir), .pan_bitti(pan_bitti), .pan_bitti_buf(pan_bitti_buf),
        .lw_en(lw_en), .lw_addr(lw_addr), .lw_data(lw_data),
        .cr_addr(cr_addr), .cr_data(cr_data), .tasma_hata(tasma_hata), .kirpilan_say(kirpilan_say));

    reg [63:0] memAct [0:NS*NB*K-1];
    reg [63:0] memW   [0:P*K-1];
    reg [31:0] memB   [0:C-1];
    reg [31:0] memM0  [0:C-1];
    reg [7:0]  memExp [0:NS*64*C-1];
    reg [7:0]  memLut [0:255];
    reg [255*8:1] vdir, pdir, ad, yol, vcdfile, lutdosya, sfx;

    integer s, errors, nchk, next_p, cyc, cyc0, w, q, blk, c, bi, kirp_top, lat;
    integer cyc_layer [0:NS-1];
    reg     bitti, vcd_var;
    reg [7:0] beklenen_bayt, gelen_bayt;

    always @(posedge clk) cyc <= cyc + 1;

    task yukle_panel;
        input integer p;
        input integer b;
        integer t;
        begin
            for (t = 0; t < K; t = t + 1) begin
                @(negedge clk); pw_en = 1; pw_buf = b; pw_sel = 0; pw_addr = t; pw_data = memW[p*K + t];
            end
            for (t = 0; t < 8; t = t + 1) begin
                @(negedge clk); pw_en = 1; pw_buf = b; pw_sel = 1; pw_addr = t; pw_data = memB[p*8 + t];
                @(negedge clk); pw_en = 1; pw_buf = b; pw_sel = 2; pw_addr = t; pw_data = memM0[p*8 + t];
            end
            @(negedge clk); pw_en = 0;
            pan_hazir[b] = 1'b1;
        end
    endtask

    always @(posedge clk) if (pan_bitti) begin
        pan_hazir[pan_bitti_buf] = 1'b0;
        if (next_p < P) begin
            next_p = next_p + 1;
            yukle_panel(next_p - 1, pan_bitti_buf);
        end
    end

    initial begin
        cyc = 0; errors = 0; nchk = 0; next_p = 0; kirp_top = 0;
        if (!$value$plusargs("vdir=%s", vdir) || !$value$plusargs("pdir=%s", pdir) ||
            !$value$plusargs("ad=%s", ad)) begin
            $display("HATA: +vdir= +pdir= +ad= gerekli"); $display("DOGRUSAL KATMAN TEST: FAIL"); $finish;
        end
        vcd_var = $value$plusargs("vcd=%s", vcdfile);
        if (vcd_var) begin $dumpfile(vcdfile); $dumpvars(0, dut.u_tile.u_dizi, dut.u_tile); end
        $sformat(yol, "%0s/%0s_girdi_blok.mem", vdir, ad);  $readmemh(yol, memAct);
        $sformat(yol, "%0s/%0s_w_panel.mem", vdir, ad);     $readmemh(yol, memW);
        $sformat(yol, "%0s/%0s_b.mem", pdir, ad);           $readmemh(yol, memB);
        $sformat(yol, "%0s/%0s_m0.mem", pdir, ad);          $readmemh(yol, memM0);
        if (!$value$plusargs("sfx=%s", sfx)) sfx = "cikis";               // beklenen dosya eki (GELU: gelu_cikis)
        $sformat(yol, "%0s/%0s_%0s.mem", vdir, ad, sfx);       $readmemh(yol, memExp);

        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;
        repeat (3) @(posedge clk);

        if (GELU != 0) begin                                  // LUT'u host yukler
            if (!$value$plusargs("lut=%s", lutdosya)) begin $display("HATA: +lut="); $finish; end
            $readmemh(lutdosya, memLut);
            for (w = 0; w < 256; w = w + 1) begin
                @(negedge clk); lw_en = 1; lw_addr = w; lw_data = memLut[w];
            end
            @(negedge clk); lw_en = 0;
        end

        for (s = 0; s < NS; s = s + 1) begin
            for (w = 0; w < NB*K; w = w + 1) begin
                @(negedge clk); aw_en = 1; aw_addr = w; aw_data = memAct[s*NB*K + w];
            end
            @(negedge clk); aw_en = 0;
            pan_hazir = 2'b00;
            next_p = 1; yukle_panel(0, 0);
            if (P > 1) begin next_p = 2; yukle_panel(1, 1); end
            @(negedge clk); kos = 1; cyc0 = cyc;
            @(negedge clk); kos = 0;
            bitti = 0;
            while (!bitti && (cyc - cyc0) < 40*P*NB*(K+20)) begin
                @(posedge clk); #1;
                if (layer_done) bitti = 1;
            end
            cyc_layer[s] = cyc - cyc0;
            if (!bitti) begin errors = errors + 1; $display("  FAIL cumle %0d: zaman asimi", s); end
            // cikis BRAM'ini oku ve karsilastir: sozcuk (blk*C + c), bayt i = token blk*8+i
            for (blk = 0; blk < NB; blk = blk + 1)
                for (c = 0; c < C; c = c + 1) begin
                    @(negedge clk); cr_addr = blk*C + c;
                    @(negedge clk); @(negedge clk);
                    for (bi = 0; bi < 8; bi = bi + 1) begin
                        nchk = nchk + 1;
                        beklenen_bayt = memExp[(s*64 + blk*8 + bi)*C + c];
                        gelen_bayt = cr_data[bi*8 +: 8];
                        if (gelen_bayt !== beklenen_bayt) begin
                            errors = errors + 1;
                            if (errors < 6) $display("  FAIL cumle %0d token %0d kanal %0d: dut=%0d beklenen=%0d",
                                s, blk*8+bi, c, $signed(gelen_bayt), $signed(beklenen_bayt));
                        end
                    end
                end
            if (tasma_hata) begin errors = errors + 1; $display("  FAIL: golge ustune yazildi"); end
            kirp_top = kirp_top + kirpilan_say;
        end

        $display("----------------------------------------------");
        $display("KATMAN_CEVRIM %0s K=%0d C=%0d : cumle basina %0d ; teorik (K+14)*P*NB = %0d ; kirpilan eleman (toplam) %0d",
                 ad, K, C, cyc_layer[0], (K+14)*P*NB, kirp_top);
        if (errors == 0)
            $display("DOGRUSAL KATMAN TEST (%0s K=%0d C=%0d n=%0d): PASS  (%0d kontrol, 0 hata)", ad, K, C, SH, nchk);
        else
            $display("DOGRUSAL KATMAN TEST (%0s K=%0d C=%0d n=%0d): FAIL  (%0d hata)", ad, K, C, SH, errors);
        $finish;
    end
endmodule
