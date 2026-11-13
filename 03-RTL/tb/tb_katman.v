// tb_katman.v -- dogrusal_katman uctan uca: aktivasyon BRAM -> dizi -> +bias -> M0/n -> cikis BRAM.
// Cikis BRAM sozcukleri altin <ad>_cikis.mem (INT8) ile BIT-BIREBIR karsilastirilir (G7 kabul).
// -P: K, C, NS, SH (KAYDIRMA_<AD>), GELU (1: ffn1 icin LUT)    vvp: +vdir= +pdir= +ad= [+lut=<dosya>] [+sfx=cikis|gelu_cikis] [+vcd=]
`timescale 1ns/1ps
module tb_katman;
    parameter K = 128, C = 128, NS = 4, SH = 37, GELU = 0;
    parameter K_ENFAZLA = 512, K_GENISLIGI = 11, PANEL_GENISLIGI = 7, ADRES_GENISLIGI = 12;
    // plusarg verilmezse (Vivado GUI) l0_q katmani kullanilir (K=128, C=128, SH=37). Baska bilgisayarda yollari degistirin.
    parameter VDIR_V = "C:/Users/rumey/Documents/biitirme-projem/02-RTL_Altin_Model/03_Sonuclar/test_vektorleri";
    parameter PDIR_V = "C:/Users/rumey/Documents/biitirme-projem/02-RTL_Altin_Model/03_Sonuclar/parametreler";
    parameter AD_V   = "l0_q";
    localparam P = C / 8;
    localparam NB = 8;
    parameter NBE = 0;                       // etkin token blogu sayisi (Konu 3): 0 = hepsi (8); 1..8: yalniz ilk NBE blok islenir ve karsilastirilir
    localparam [3:0] NBE4 = NBE;
    localparam NBX = (NBE == 0) ? NB : NBE;

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg              calistir = 0;
    reg              aktivasyon_yaz_etkin = 0;
    reg  [ADRES_GENISLIGI-1:0]    aktivasyon_yaz_adres = 0;
    reg  [63:0]      aktivasyon_yaz_veri = 0;
    reg              panel_yaz_etkin = 0, panel_yaz_tampon = 0;
    reg  [1:0]       panel_yaz_secici = 0;
    reg  [K_GENISLIGI-1:0]    panel_yaz_adres = 0;
    reg  [63:0]      panel_yaz_veri = 0;
    reg  [1:0]       panel_hazir = 0;
    reg              gelu_yaz_etkin = 0;
    reg  [7:0]       gelu_yaz_adres = 0, gelu_yaz_veri = 0;
    reg  [ADRES_GENISLIGI-1:0]    cikis_oku_adres = 0;
    wire [63:0]      cikis_oku_veri;
    wire             mesgul, katman_bitti, panel_bitti, panel_bitti_tampon, tasma_hatasi;
    wire [31:0]      kirpilan_sayisi;

    dogrusal_katman #(.K_ENFAZLA(K_ENFAZLA), .K_GENISLIGI(K_GENISLIGI), .PANEL_GENISLIGI(PANEL_GENISLIGI), .ADRES_GENISLIGI(ADRES_GENISLIGI)) dut (
        .clk(clk), .rst(rst), .calistir(calistir), .ayar_k(K[K_GENISLIGI-1:0]), .ayar_panel_sayisi(P[PANEL_GENISLIGI-1:0]), .ayar_blok_sayisi(NBE4), .ayar_kaydirma(SH[5:0]),
        .a_isaretsiz(1'b0), .gelu_etkin(GELU != 0), .mesgul(mesgul), .katman_bitti(katman_bitti),
        .aktivasyon_yaz_etkin(aktivasyon_yaz_etkin), .aktivasyon_yaz_adres(aktivasyon_yaz_adres), .aktivasyon_yaz_veri(aktivasyon_yaz_veri),
        .panel_yaz_etkin(panel_yaz_etkin), .panel_yaz_tampon(panel_yaz_tampon), .panel_yaz_secici(panel_yaz_secici), .panel_yaz_adres(panel_yaz_adres), .panel_yaz_veri(panel_yaz_veri),
        .panel_hazir(panel_hazir), .panel_bitti(panel_bitti), .panel_bitti_tampon(panel_bitti_tampon),
        .gelu_yaz_etkin(gelu_yaz_etkin), .gelu_yaz_adres(gelu_yaz_adres), .gelu_yaz_veri(gelu_yaz_veri),
        .cikis_oku_adres(cikis_oku_adres), .cikis_oku_veri(cikis_oku_veri), .tasma_hatasi(tasma_hatasi), .kirpilan_sayisi(kirpilan_sayisi));

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
                @(negedge clk); panel_yaz_etkin = 1; panel_yaz_tampon = b; panel_yaz_secici = 0; panel_yaz_adres = t; panel_yaz_veri = memW[p*K + t];
            end
            for (t = 0; t < 8; t = t + 1) begin
                @(negedge clk); panel_yaz_etkin = 1; panel_yaz_tampon = b; panel_yaz_secici = 1; panel_yaz_adres = t; panel_yaz_veri = memB[p*8 + t];
                @(negedge clk); panel_yaz_etkin = 1; panel_yaz_tampon = b; panel_yaz_secici = 2; panel_yaz_adres = t; panel_yaz_veri = memM0[p*8 + t];
            end
            @(negedge clk); panel_yaz_etkin = 0;
            panel_hazir[b] = 1'b1;
        end
    endtask

    // panel_bitti bir cevrimlik darbedir; onceki panel yuklenirken (gorev icinde) gelen darbe kacmasin diye siraya alinir.
    // (Gercek host'ta bu seviye bayragidir: komut_cozucu panel_bos'u tutar. nb=1 gibi cok kisa panellerde darbeler yuklemeden hizli gelir.)
    integer bq_bas = 0, bq_son = 0;
    reg     bq_buf [0:63];
    always @(posedge clk) if (panel_bitti) begin
        panel_hazir[panel_bitti_tampon] = 1'b0;
        bq_buf[bq_son % 64] = panel_bitti_tampon; bq_son = bq_son + 1;
    end
    always @(posedge clk) if (bq_bas != bq_son) begin
        if (next_p < P) begin
            next_p = next_p + 1;
            yukle_panel(next_p - 1, bq_buf[bq_bas % 64]);
        end
        bq_bas = bq_bas + 1;
    end

    initial begin
        cyc = 0; errors = 0; nchk = 0; next_p = 0; kirp_top = 0;
        if (!$value$plusargs("vdir=%s", vdir)) vdir = VDIR_V;
        if (!$value$plusargs("pdir=%s", pdir)) pdir = PDIR_V;
        if (!$value$plusargs("ad=%s", ad))     ad   = AD_V;
        $display("BILGI: katman=%0s", ad);
        vcd_var = $value$plusargs("vcd=%s", vcdfile);
        if (vcd_var) begin $dumpfile(vcdfile); $dumpvars(0, dut.u_tile_denetleyici.u_sistolik_dizi, dut.u_tile_denetleyici); end
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
                @(negedge clk); gelu_yaz_etkin = 1; gelu_yaz_adres = w; gelu_yaz_veri = memLut[w];
            end
            @(negedge clk); gelu_yaz_etkin = 0;
        end

        for (s = 0; s < NS; s = s + 1) begin
            for (w = 0; w < NB*K; w = w + 1) begin
                @(negedge clk); aktivasyon_yaz_etkin = 1; aktivasyon_yaz_adres = w; aktivasyon_yaz_veri = memAct[s*NB*K + w];
            end
            @(negedge clk); aktivasyon_yaz_etkin = 0;
            panel_hazir = 2'b00;
            next_p = 1; yukle_panel(0, 0);
            if (P > 1) begin next_p = 2; yukle_panel(1, 1); end
            @(negedge clk); calistir = 1; cyc0 = cyc;
            @(negedge clk); calistir = 0;
            bitti = 0;
            while (!bitti && (cyc - cyc0) < 40*P*NB*(K+20)) begin
                @(posedge clk); #1;
                if (katman_bitti) bitti = 1;
            end
            cyc_layer[s] = cyc - cyc0;
            if (!bitti) begin errors = errors + 1; $display("  FAIL cumle %0d: zaman asimi", s); end
            // cikis BRAM'ini oku ve karsilastir: sozcuk (blk*C + c), bayt i = token blk*8+i
            for (blk = 0; blk < NBX; blk = blk + 1)
                for (c = 0; c < C; c = c + 1) begin
                    @(negedge clk); cikis_oku_adres = blk*C + c;
                    @(negedge clk); @(negedge clk);
                    for (bi = 0; bi < 8; bi = bi + 1) begin
                        nchk = nchk + 1;
                        beklenen_bayt = memExp[(s*64 + blk*8 + bi)*C + c];
                        gelen_bayt = cikis_oku_veri[bi*8 +: 8];
                        if (gelen_bayt !== beklenen_bayt) begin
                            errors = errors + 1;
                            if (errors < 6) $display("  FAIL cumle %0d token %0d kanal %0d: dut=%0d beklenen=%0d",
                                s, blk*8+bi, c, $signed(gelen_bayt), $signed(beklenen_bayt));
                        end
                    end
                end
            if (tasma_hatasi) begin errors = errors + 1; $display("  FAIL: golge ustune yazildi"); end
            kirp_top = kirp_top + kirpilan_sayisi;
        end

        $display("----------------------------------------------");
        $display("KATMAN_CEVRIM %0s K=%0d C=%0d : cumle basina %0d ; teorik (K+14)*P*NB = %0d ; kirpilan eleman (toplam) %0d",
                 ad, K, C, cyc_layer[0], (K+14)*P*NBX, kirp_top);
        if (errors == 0)
            $display("DOGRUSAL KATMAN TEST (%0s K=%0d C=%0d n=%0d): PASS  (%0d kontrol, 0 hata)", ad, K, C, SH, nchk);
        else
            $display("DOGRUSAL KATMAN TEST (%0s K=%0d C=%0d n=%0d): FAIL  (%0d hata)", ad, K, C, SH, errors);
        $finish;
    end
endmodule
