// tb_dikkat_av.v -- P.V (katman 0, bas 0): A = P (UINT8 olasilik, isaretsiz), B = V^T (cumle basina farkli panel)
// (tb_tile.v'nin dikkat varyanti; K=64, C=64 anahtar, PER_S=1) -- tile_denetleyici + panel_tamponu + aktivasyon BRAM: bir dogrusal katmanin birikeci
// (bias dahil) altin test vektoru ile BIT-BIREBIR karsilastirilir (G5 kabul).
// -P parametreleri: K, C, NS (cumle sayisi).  vvp argumanlari: +vdir= +pdir= +ad=<kisa_ad> [+vcd=...]
//   vdir : 02-RTL_Altin_Model/03_Sonuclar/test_vektorleri   pdir : .../parametreler
// Panel yukleme host davranisidir: baslangicta panel 0,1; panel_bitti darbesinde bosalan tampona sonraki panel.
`timescale 1ns/1ps
module tb_dikkat_av;
    parameter K  = 64;
    parameter C  = 64;
    parameter NS = 4;
    parameter PER_S = 1;      // 1: B operandi (panel) cumle basina farkli (dikkat: K ve V aktivasyonlari)
    parameter AISGZ = 1;      // 1: A baytlari isaretsiz (UINT8 olasilik)
    parameter K_ENFAZLA = 512;
    // plusarg verilmezse (Vivado GUI) l0_q katmani kullanilir (K=128, C=128, NS=4). Baska bilgisayarda yollari degistirin.
    parameter VDIR_V = "C:/Users/rumey/Documents/biitirme-projem/02-RTL_Altin_Model/03_Sonuclar/test_vektorleri";
    parameter PDIR_V = "C:/Users/rumey/Documents/biitirme-projem/02-RTL_Altin_Model/03_Sonuclar/test_vektorleri";   // dikkatte bias dosyasi da test_vektorleri icinde
    parameter AD_V   = "l0_av_h0";
    parameter K_GENISLIGI = 11, PANEL_GENISLIGI = 7, ADRES_GENISLIGI = 12;
    localparam P  = C / 8;
    localparam NB = 8;

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    // aktivasyon BRAM yazma
    reg              aktivasyon_yaz_etkin = 0;
    reg  [ADRES_GENISLIGI-1:0]    aktivasyon_yaz_adres = 0;
    reg  [63:0]      aktivasyon_yaz_veri = 0;
    wire [ADRES_GENISLIGI-1:0]    aktivasyon_oku_adres;
    wire [63:0]      aktivasyon_oku_veri;
    cift_kapili_bellek #(.ADRES_GENISLIGI(ADRES_GENISLIGI), .VERI_GENISLIGI(64)) u_act (.clk(clk), .yaz_etkin(aktivasyon_yaz_etkin), .yaz_adres(aktivasyon_yaz_adres), .yaz_veri(aktivasyon_yaz_veri),
                                        .oku_adres(aktivasyon_oku_adres), .oku_veri(aktivasyon_oku_veri));
    // panel tamponu
    reg              panel_yaz_etkin = 0, panel_yaz_tampon = 0;
    reg  [1:0]       panel_yaz_secici = 0;
    reg  [K_GENISLIGI-1:0]    panel_yaz_adres = 0;
    reg  [63:0]      panel_yaz_veri = 0;
    wire             panel_oku_tampon;
    wire [K_GENISLIGI-1:0]    panel_oku_adres;
    wire [63:0]      panel_oku_veri;
    wire             sorgu_tampon;
    wire [2:0]       sorgu_kanal;
    wire [31:0]      sorgu_bias;
    wire [30:0]      sorgu_m0;
    panel_tamponu #(.K_ENFAZLA(K_ENFAZLA), .K_GENISLIGI(K_GENISLIGI)) u_pan (.clk(clk), .panel_yaz_etkin(panel_yaz_etkin), .panel_yaz_tampon(panel_yaz_tampon), .panel_yaz_secici(panel_yaz_secici),
        .panel_yaz_adres(panel_yaz_adres), .panel_yaz_veri(panel_yaz_veri), .agirlik_oku_tampon(panel_oku_tampon), .agirlik_oku_adres(panel_oku_adres), .agirlik_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias), .sorgu_m0(sorgu_m0));

    reg              calistir = 0;
    reg  [1:0]       panel_hazir = 0;
    wire             mesgul, katman_bitti, panel_bitti, panel_bitti_tampon;
    wire             cikis_gecerli, cikis_tile_son, cikis_tasma;
    wire [2:0]       cikis_token, cikis_kanal;
    wire [3:0]       cikis_blok;
    wire [PANEL_GENISLIGI-1:0]    cikis_panel;
    wire signed [31:0] cikis_birikec;

    tile_denetleyici #(.DIZI_BOYUTU(8), .BLOK_SAYISI(NB), .K_GENISLIGI(K_GENISLIGI), .PANEL_GENISLIGI(PANEL_GENISLIGI), .ADRES_GENISLIGI(ADRES_GENISLIGI)) dut (
        .clk(clk), .rst(rst), .calistir(calistir), .ayar_k(K[K_GENISLIGI-1:0]), .ayar_panel_sayisi(P[PANEL_GENISLIGI-1:0]), .ayar_blok_sayisi(4'd0), .a_isaretsiz(AISGZ[0]),
        .mesgul(mesgul), .katman_bitti(katman_bitti), .panel_hazir(panel_hazir), .panel_bitti(panel_bitti),
        .panel_bitti_tampon(panel_bitti_tampon), .aktivasyon_oku_adres(aktivasyon_oku_adres), .aktivasyon_oku_veri(aktivasyon_oku_veri),
        .panel_oku_tampon(panel_oku_tampon), .panel_oku_adres(panel_oku_adres), .panel_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias),
        .cikis_gecerli(cikis_gecerli), .cikis_token(cikis_token), .cikis_kanal(cikis_kanal), .cikis_blok(cikis_blok), .cikis_panel(cikis_panel),
        .cikis_tile_son(cikis_tile_son), .cikis_birikec(cikis_birikec), .cikis_tasma(cikis_tasma));

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
    always @(posedge calistir) if (vcd_on) begin #33000; $dumpoff; end       // VCD'yi ilk ~3300 cevrimle sinirla

    always @(posedge clk) cyc <= cyc + 1;
    always @(posedge clk) if (cikis_gecerli)
        got[(s*64 + cikis_blok*8 + cikis_token)*C + cikis_panel*8 + cikis_kanal] <= cikis_birikec;
    always @(posedge clk) if (cikis_tile_son) tile_say <= tile_say + 1;

    task yukle_panel;
        input integer p;
        input integer b;
        integer q;
        begin
            for (q = 0; q < K; q = q + 1) begin
                @(negedge clk); panel_yaz_etkin = 1; panel_yaz_tampon = b; panel_yaz_secici = 0; panel_yaz_adres = q; panel_yaz_veri = memW[(PER_S ? s*P*K : 0) + p*K + q];
            end
            for (q = 0; q < 8; q = q + 1) begin
                @(negedge clk); panel_yaz_etkin = 1; panel_yaz_tampon = b; panel_yaz_secici = 1; panel_yaz_adres = q; panel_yaz_veri = memB[p*8 + q];
            end
            @(negedge clk); panel_yaz_etkin = 0;
            panel_hazir[b] = 1'b1;
        end
    endtask

    // panel_bitti: bosalan tamponu yeniden doldur
    always @(posedge clk) if (panel_bitti) begin
        panel_hazir[panel_bitti_tampon] = 1'b0;
        if (next_p < P) begin
            next_p = next_p + 1;
            yukle_panel(next_p - 1, panel_bitti_tampon);
        end
    end

    initial begin
        cyc = 0; errors = 0; nchk = 0; tile_say = 0; s = 0; next_p = 0;
        if (!$value$plusargs("vdir=%s", vdir)) vdir = VDIR_V;
        if (!$value$plusargs("pdir=%s", pdir)) pdir = PDIR_V;
        if (!$value$plusargs("ad=%s", ad))     ad   = AD_V;
        $display("BILGI: katman=%0s  vdir=%0s", ad, vdir);
        vcd_on = $value$plusargs("vcd=%s", vcdfile);
        if (vcd_on) begin $dumpfile(vcdfile); $dumpvars(0, tb_dikkat_av); end
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
                @(negedge clk); aktivasyon_yaz_etkin = 1; aktivasyon_yaz_adres = w; aktivasyon_yaz_veri = memAct[s*NB*K + w];
            end
            @(negedge clk); aktivasyon_yaz_etkin = 0;
            // 2) ilk iki paneli yukle, sonrasini panel_bitti ile (host modeli)
            panel_hazir = 2'b00; next_p = 0;
            next_p = 1; yukle_panel(0, 0);
            if (P > 1) begin next_p = 2; yukle_panel(1, 1); end
            // 3) katmani baslat
            @(negedge clk); calistir = 1; cyc0 = cyc;
            @(negedge clk); calistir = 0;
            bitti_goruldu = 0;
            while (!bitti_goruldu && (cyc - cyc0) < 40*P*NB*(K+20)) begin
                @(posedge clk); #1;
                if (katman_bitti) bitti_goruldu = 1;
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
            if (cikis_tasma) begin errors = errors + 1; $display("  FAIL: golge ustune yazildi (cikis_tasma)"); end
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
