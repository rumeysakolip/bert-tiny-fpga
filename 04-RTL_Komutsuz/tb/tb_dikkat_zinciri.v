// tb_dikkat_zinciri.v -- dikkat zinciri: Q.K^T -> yeniden olcekleme -> Softmax -> olasilik belleği, ALTIN MODELLE bit-birebir
//   Her is (katman, cumle, bas): once 4096 skor (yeniden olceklenmis), sonra 4096 olasilik baytı altin modelin dosyalariyla karsilastirilir.
//   Vivado'da parametresiz calisir. plusarg: +ns=<cumle sayisi> (varsayilan 2, en cok 4)  +vdir=<test_vektorleri>  +ddir=<vektor_dikkat>
`timescale 1ns/1ps
module tb_dikkat_zinciri;
    parameter NS_VARSAYILAN = 2;
    parameter VDIR_V = "C:/Users/rumey/Documents/biitirme-projem/02-RTL_Altin_Model/03_Sonuclar/test_vektorleri";
    parameter DDIR_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_dikkat";

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg          q_yaz_etkin = 0, k_yaz_etkin = 0, basla = 0;
    reg  [11:0]  q_yaz_adres = 0, k_yaz_adres = 0;
    reg  [63:0]  q_yaz_veri = 0, k_yaz_veri = 0;
    reg  [30:0]  ayar_m0_qk = 0;
    reg  [5:0]   ayar_n_qk = 0;
    reg  [23:0]  ayar_m0_sm = 0;
    reg  [6:0]   uzunluk = 0;
    wire         skor_hazir, bitti, mesgul, skor_tasma, tile_tasma;
    reg  [11:0]  skor_oku_adres = 0;
    wire signed [15:0] skor_oku_veri;
    reg  [8:0]   p_oku_adres = 0;
    wire [63:0]  p_oku_veri;

    dikkat_cekirdegi dut (.clk(clk), .rst(rst), .q_yaz_etkin(q_yaz_etkin), .q_yaz_adres(q_yaz_adres), .q_yaz_veri(q_yaz_veri),
        .k_yaz_etkin(k_yaz_etkin), .k_yaz_adres(k_yaz_adres), .k_yaz_veri(k_yaz_veri),
        .ayar_k_taban(12'd0), .ayar_k_adim(12'd64), .ayar_m0_qk(ayar_m0_qk), .ayar_n_qk(ayar_n_qk), .ayar_m0_sm(ayar_m0_sm), .uzunluk(uzunluk),
        .basla(basla), .mod(1'b0), .ayar_m0_pv(31'd0), .ayar_n_pv(6'd0), .c_oku_adres(9'd0), .c_oku_veri(), .skor_hazir(skor_hazir), .bitti(bitti), .mesgul(mesgul),
        .skor_oku_adres(skor_oku_adres), .skor_oku_veri(skor_oku_veri), .p_oku_adres(p_oku_adres), .p_oku_veri(p_oku_veri),
        .skor_tasma(skor_tasma), .tile_tasma(tile_tasma));

    reg [63:0] memQ [0:2047];
    reg [63:0] memK [0:2047];
    reg [31:0] memSkor [0:32767];
    reg [7:0]  memP    [0:32767];
    reg [31:0] memPar  [0:5];
    reg [7:0]  memUz   [0:3];
    reg [255*8:1] vdir, ddir, yol;
    integer ns, L, s, h, i, w, errors, nchk, hs, hp, cyc, t0, t_skor, t_bit, top_cevrim, isler, b;
    reg skor_goruldu, bitti_goruldu;
    reg signed [31:0] bek_s;
    reg [7:0] bek_p, gel_p;

    always @(posedge clk) cyc <= cyc + 1;
    always @(posedge clk) begin
        if (skor_hazir) begin skor_goruldu <= 1'b1; t_skor <= cyc; end
        if (bitti)      begin bitti_goruldu <= 1'b1; t_bit <= cyc; end
    end

    initial begin
        errors = 0; nchk = 0; cyc = 0; top_cevrim = 0; isler = 0;
        if (!$value$plusargs("vdir=%s", vdir)) vdir = VDIR_V;
        if (!$value$plusargs("ddir=%s", ddir)) ddir = DDIR_V;
        if (!$value$plusargs("ns=%d", ns)) ns = NS_VARSAYILAN;
        $display("==== DIKKAT ZINCIRI SINAMASI: Q.K^T -> olcekleme -> Softmax, 2 katman x 2 bas x %0d cumle, altin modelle bit-birebir ====", ns);
        $sformat(yol, "%0s/param.mem", ddir);   $readmemh(yol, memPar);
        $sformat(yol, "%0s/uzunluk.mem", ddir); $readmemh(yol, memUz);
        repeat (4) @(posedge clk); @(negedge clk); rst = 0; repeat (3) @(posedge clk);

        for (L = 0; L < 2; L = L + 1) begin
            $sformat(yol, "%0s/skor_l%0d.mem", ddir, L);          $readmemh(yol, memSkor);
            $sformat(yol, "%0s/l%0d_olasilik_u8.mem", vdir, L);   $readmemh(yol, memP);
            for (s = 0; s < ns; s = s + 1)
                for (h = 0; h < 2; h = h + 1) begin
                    // vektorler: Q blok duzeni (A), K panel duzeni (B)
                    $sformat(yol, "%0s/l%0d_qk_h%0d_girdi_blok.mem", vdir, L, h); $readmemh(yol, memQ);
                    $sformat(yol, "%0s/l%0d_qk_h%0d_w_panel.mem", vdir, L, h);    $readmemh(yol, memK);
                    for (w = 0; w < 512; w = w + 1) begin
                        @(negedge clk); q_yaz_etkin = 1; q_yaz_adres = w; q_yaz_veri = memQ[s*512 + w];
                        k_yaz_etkin = 1; k_yaz_adres = w; k_yaz_veri = memK[s*512 + w];
                    end
                    @(negedge clk); q_yaz_etkin = 0; k_yaz_etkin = 0;
                    ayar_m0_qk = memPar[L*3][30:0]; ayar_n_qk = memPar[L*3 + 1][5:0]; ayar_m0_sm = memPar[L*3 + 2][23:0]; uzunluk = memUz[s][6:0];
                    skor_goruldu = 0; bitti_goruldu = 0;
                    @(negedge clk); basla = 1; t0 = cyc;
                    @(negedge clk); basla = 0;
                    while (!skor_goruldu && (cyc - t0) < 200000) @(posedge clk);
                    if (!skor_goruldu) begin errors = errors + 1; $display("  HATA: skorlar zaman asimi"); end
                    // skor karsilastirma
                    hs = 0;
                    for (i = 0; i < 4096; i = i + 1) begin
                        @(negedge clk); skor_oku_adres = i;
                        @(negedge clk); @(negedge clk);
                        bek_s = memSkor[(s*2 + h)*4096 + i];
                        if (skor_oku_veri !== bek_s[15:0]) begin
                            hs = hs + 1;
                            if (hs < 4) $display("  HATA skor (sorgu %0d, anahtar %0d): devre=%0d beklenen=%0d", i / 64, i % 64, skor_oku_veri, bek_s);
                        end
                    end
                    while (!bitti_goruldu && (cyc - t0) < 400000) @(posedge clk);
                    if (!bitti_goruldu) begin errors = errors + 1; $display("  HATA: olasiliklar zaman asimi"); end
                    // olasilik karsilastirma: sozcuk (blk*64 + key), bayt j = sorgu 8*blk + j
                    hp = 0;
                    for (b = 0; b < 8; b = b + 1)
                        for (w = 0; w < 64; w = w + 1) begin
                            @(negedge clk); p_oku_adres = b*64 + w;
                            @(negedge clk); @(negedge clk);
                            for (i = 0; i < 8; i = i + 1) begin
                                bek_p = memP[(s*2 + h)*4096 + (b*8 + i)*64 + w];
                                gel_p = p_oku_veri[i*8 +: 8];
                                if (gel_p !== bek_p) begin
                                    hp = hp + 1;
                                    if (hp < 4) $display("  HATA olasilik (sorgu %0d, anahtar %0d): devre=%0d beklenen=%0d", b*8 + i, w, gel_p, bek_p);
                                end
                            end
                        end
                    if (skor_tasma || tile_tasma) begin errors = errors + 1; $display("  HATA: tasma bayragi (skor=%0d, tile=%0d)", skor_tasma, tile_tasma); end
                    errors = errors + hs + hp; nchk = nchk + 8192; isler = isler + 1; top_cevrim = top_cevrim + (t_bit - t0);
                    $display("[katman %0d, cumle %0d, bas %0d] uzunluk=%0d : skorlar %0s (4096 kontrol, %0d hata) | olasiliklar %0s (4096 kontrol, %0d hata) | cevrim: Q.K^T=%0d Softmax=%0d",
                             L, s, h, memUz[s], (hs == 0) ? "BASARILI" : "BASARISIZ", hs, (hp == 0) ? "BASARILI" : "BASARISIZ", hp, t_skor - t0, t_bit - t_skor);
                end
        end
        $display("----------------------------------------------");
        $display("DIKKAT ZINCIRI TEST: %0s  (%0d is, %0d kontrol, %0d hata, toplam %0d cevrim)", (errors == 0) ? "BASARILI" : "BASARISIZ", isler, nchk, errors, top_cevrim);
        $finish;
    end
endmodule
