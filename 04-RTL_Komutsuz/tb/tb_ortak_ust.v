// tb_ortak_ust.v -- komutsuz hizlandirici uctan uca: bayt akisi -> ayristirici -> cizelge -> ortak cekirdek; altin modelle bit-birebir
//   Cizelge her satirin sonunda bekler (gozlem kipi); bu testbench o anda bellegi okuyup altin model vektorleriyle karsilastirir:
//   Q, K, V (devrik), baglam, dikkat cikisi, LayerNorm 1 (yeniden olcekli ve ham cikis), ileri besleme 1 (GELU + olcek), ileri besleme 2, LayerNorm 2.
//   Vivado'da parametresiz calisir. plusarg: +akis=<bayt akisi dosyasi> +ns=<cumle> +vdir=<test_vektorleri> +ldir=<vektor_ln>
`timescale 1ns/1ps
module tb_ortak_ust;
    parameter KATMAN = 2;
    parameter AKIS_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_akis/akis_katman2.hex";
    parameter VDIR_V = "C:/Users/rumey/Documents/biitirme-projem/02-RTL_Altin_Model/03_Sonuclar/test_vektorleri";
    parameter LDIR_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_ln";
    parameter AKIS_BAYT = 2000000;          // akis dizisinin boyutu; gercek uzunluk dosyadan olculur
    parameter SDIR_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_sinif";
    parameter DOLGU_ATLA = 0;               // 1: cizelge cumlenin gercek blok sayisi (nb) kadar hesaplar, karsilastirma yalniz gecerli tokenlarda; 0: eski davranis (8 blok, 64 satir)
    parameter NA = 1;                       // paralel dogrusal hat sayisi (agirlik ROM modu: 1, 2, 4, 8)
    parameter AGIRLIK_ROM = 0;              // 1: agirliklar yonga ici bankalardan; akista yalniz aktivasyon bloklari (uret_katman_akis.py --sadece_akt)
    parameter ROM_D = 8192;                 // agirlik bankasi derinligi
    parameter LN_PAR = 0;                   // 1: paralel (8 hatli) LayerNorm
    parameter SMP = 0;                      // 1: paralel (8 birimli) Softmax
    parameter HIZLI_OLCUM = 0;              // 1: yalniz sure olcumu (xelab -generic_top "HIZLI_OLCUM=1"); sonuclar anlamsiz, "SAF HESAP" satiri okunur

    integer aralik, hizli, bayt_say;
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg         bayt_gecerli; reg [7:0] bayt_veri; wire bayt_hazir;
    reg         gozlem = 1, devam = 0; wire satir_bitti;
    reg  [12:0] oku_adres = 0; wire [63:0] oku_veri;
    wire        sinif, sonuc_gecerli; wire signed [7:0] logit0, logit1;
    wire        hata, cumle_bitti, tasma_hatasi, skor_tasma, ln_tasma, bellek_catisma;
    wire [3:0]  satir_no, katman_no; wire [15:0] cumle_no; wire [31:0] hata_sayisi, kabul_edilen_bayt, kirpilan_sayisi; wire [6:0] cumle_uzunluk;

    ortak_ust #(.KATMAN_ISLEM(KATMAN), .HIZLI_OLCUM(HIZLI_OLCUM), .DOLGU_ATLA(DOLGU_ATLA), .NA(NA), .AGIRLIK_ROM(AGIRLIK_ROM), .ROM_D(ROM_D), .LN_PAR(LN_PAR), .SMP(SMP)) dut (.clk(clk), .rst(rst), .bayt_gecerli(bayt_gecerli), .bayt_veri(bayt_veri), .bayt_hazir(bayt_hazir),
        .gozlem(gozlem), .devam(devam), .satir_bitti(satir_bitti), .oku_adres(oku_adres), .oku_veri(oku_veri),
        .hata(hata), .satir_no(satir_no), .katman_no(katman_no), .cumle_no(cumle_no), .cumle_bitti(cumle_bitti), .sinif(sinif), .sonuc_gecerli(sonuc_gecerli), .logit0(logit0), .logit1(logit1),
        .hata_sayisi(hata_sayisi), .kabul_edilen_bayt(kabul_edilen_bayt), .cumle_uzunluk(cumle_uzunluk),
        .tasma_hatasi(tasma_hatasi), .skor_tasma(skor_tasma), .ln_tasma(ln_tasma), .bellek_catisma(bellek_catisma), .kirpilan_sayisi(kirpilan_sayisi));

    reg [7:0]  akis  [0:AKIS_BAYT-1];
    reg [7:0]  memExp [0:131071];
    reg [7:0]  memSin [0:63];
    reg [63:0] memW   [0:4095];
    reg [255*8:1] vdir, ldir, sdir, akis_yol, yol;
    integer sinif_dogru; reg [7:0] sinif_beklenen;
    integer ns, s, L, r, errors, nchk, cyc, cyc0, bayt_no, catisma_say, top_bayt;
    integer hk, blk, c, bi, w, h, ntok, nblk, nbt, ktok;      // nbt: karsilastirilacak blok sayisi, ktok: karsilastirilacak gecerli token sayisi
    reg [7:0] gelen, beklenen;

    always @(posedge clk) cyc <= cyc + 1;
    reg [3:0] sn_onceki; reg [3:0] kn_onceki;
    always @(posedge clk) begin sn_onceki <= satir_no; kn_onceki <= katman_no; if (hizli != 0 && (satir_no != sn_onceki || katman_no != kn_onceki)) $display("SATIR katman %0d satir %0d basladi cevrim %0d", katman_no, satir_no, cyc); end
    always @(posedge clk) if (bellek_catisma) catisma_say <= catisma_say + 1;
    // saf hesap penceresi: aktivasyon blogunun denetim kodu dogrulandigi cevrimden (PC tarafi biter) sonuc_gecerli'ye kadar
    integer cyc_akt = 0;
    always @(posedge clk) if (dut.blok_tamam && !dut.blok_tur) cyc_akt <= cyc;

    // ---------------- bayt akisi besleyici: bayt, ayristirici kabul edene (gecerli ve hazir) kadar tutulur ----------------
    wire [7:0] bayt_simdiki = akis[bayt_no];
    // aralik: iki bayt arasi cevrim (1 = tam hiz; 4 ~ dortlu hatli flas 25 MB/s); hizli: 1 ise kontrolsuz olcum kipi
    always @* begin bayt_gecerli = (!rst && bayt_no < top_bayt && bayt_say == 0); bayt_veri = bayt_simdiki; end
    always @(posedge clk) begin
        if (rst) bayt_say <= 0;
        else if (bayt_say >= aralik - 1) bayt_say <= 0; else bayt_say <= bayt_say + 1;
    end
    always @(posedge clk) begin
        if (rst) bayt_no <= 0;
        else if (bayt_gecerli && bayt_hazir) bayt_no <= bayt_no + 1;
    end

    task oku_kelime;                      // bellekten bir sozcuk oku (oku_veri sonucta gecerli)
        input integer adres;
        begin
            @(negedge clk); oku_adres = adres;
            @(negedge clk); @(negedge clk);
        end
    endtask

    // 8 bitlik karsilastirma: bellekte taban + blok*aralik + kanal ; beklenen[(s*64 + blok*8 + i)*exp_kanal + exp_ofs + kanal]
    task karsilastir8;
        input [255*8:1] ad;
        input integer taban, aralik, nblok, kanal_say, exp_kanal, exp_ofs;
        integer kh, bb, cc, ii;
        begin
            kh = 0;
            for (bb = 0; bb < nblok; bb = bb + 1)
                for (cc = 0; cc < kanal_say; cc = cc + 1) begin
                    oku_kelime(taban + bb*aralik + cc);
                    for (ii = 0; ii < ((nblok == 1 && ntok == 1) ? 1 : 8); ii = ii + 1) if (r >= 14 || (bb*8 + ii) < ktok) begin
                        nchk = nchk + 1;
                        beklenen = (r >= 14) ? memExp[s*exp_kanal + exp_ofs + cc] : memExp[(s*64 + bb*8 + ii)*exp_kanal + exp_ofs + cc];
                        gelen = oku_veri[ii*8 +: 8];
                        if (gelen !== beklenen) begin
                            kh = kh + 1; errors = errors + 1;
                            if (kh < 4) $display("   HATA %0s: token %0d kanal %0d: devre=%0d beklenen=%0d", ad, bb*8+ii, exp_ofs+cc, $signed(gelen), $signed(beklenen));
                        end
                    end
                end
            $display("   [katman %0d, satir %0d] %0s: %0s (%0d hata)", L, r, ad, (kh == 0) ? "BASARILI" : "BASARISIZ", kh);
        end
    endtask

    // 64 bit sozcuk karsilastirma (devrik V ve LayerNorm ham cikisi)
    task karsilastir64;
        input [255*8:1] ad;
        input integer taban, sozcuk_say, exp_ofs, mod;     // mod 1: devrik V (sozcuk = panel*64 + token); 2: blok duzeni (sozcuk = blok*128 + kanal)
        integer kh, ww;
        begin
            kh = 0;
            for (ww = 0; ww < sozcuk_say; ww = ww + 1) if (!((mod == 1 && (ww % 64) >= 8*nbt) || (mod == 2 && (ww / 128) >= nbt))) begin
                oku_kelime(taban + ww);
                nchk = nchk + 8;
                if (oku_veri !== memW[exp_ofs + ww]) begin
                    kh = kh + 1; errors = errors + 1;
                    if (kh < 4) $display("   HATA %0s: sozcuk %0d", ad, ww);
                end
            end
            $display("   [katman %0d, satir %0d] %0s: %0s (%0d hata)", L, r, ad, (kh == 0) ? "BASARILI" : "BASARISIZ", kh);
        end
    endtask

    task yukle8;                          // test_vektorleri / vektor_ln dosyasini 8 bit dizisine oku
        input [255*8:1] dizin;
        input [255*8:1] dosya;
        begin
            $sformat(yol, "%0s/%0s", dizin, dosya);
            $readmemh(yol, memExp);
        end
    endtask

    task satir_kontrol;
        begin
            nbt  = (DOLGU_ATLA != 0 && cumle_uzunluk >= 1 && cumle_uzunluk <= 64) ? (cumle_uzunluk + 7) / 8 : 8;
            ktok = (DOLGU_ATLA != 0 && cumle_uzunluk >= 1 && cumle_uzunluk <= 64) ? cumle_uzunluk : 64;
            ntok = (r >= 14) ? 1 : 8;
            if (L > 0 && r != 10 && r != 13 && r < 14) begin end   // 2. katman girdisi zincirle gelir; ara vektor dosyalari baska girdi yolundan: yalniz LayerNorm cikislari denetlenir
            else case (r)
                1: begin
                    $sformat(yol, "l%0d_q_cikis.mem", L); yukle8(vdir, yol);
                    for (h = 0; h < 2; h = h + 1) karsilastir8("Q (sorgu)", 1024 + 512*h, 64, nbt, 64, 128, 64*h);
                end
                3: begin
                    $sformat(yol, "l%0d_k_cikis.mem", L); yukle8(vdir, yol);
                    for (h = 0; h < 2; h = h + 1) karsilastir8("K (anahtar)", 2048 + 512*h, 64, nbt, 64, 128, 64*h);
                end
                4: begin
                    for (h = 0; h < 2; h = h + 1) begin
                        $sformat(yol, "%0s/l%0d_av_h%0d_w_panel.mem", vdir, L, h); $readmemh(yol, memW);
                        karsilastir64("V (devrik panel duzeni)", 3072 + 512*h, 512, s*512, 1);
                    end
                end
                8: begin
                    $sformat(yol, "l%0d_attn_out_girdi.mem", L); yukle8(vdir, yol);
                    karsilastir8("baglam (P.V)", 5120, 128, nbt, 128, 128, 0);
                end
                9: begin
                    $sformat(yol, "l%0d_attn_out_cikis.mem", L); yukle8(vdir, yol);
                    karsilastir8("dikkat cikis dogrusali", 1024, 128, nbt, 128, 128, 0);
                end
                10: begin
                    $sformat(yol, "ln%0d_cikis.mem", 2*L + 1); yukle8(ldir, yol);
                    karsilastir8("LayerNorm 1 (yeniden olcekli)", 0, 128, nbt, 128, 128, 0);
                    $sformat(yol, "%0s/ln%0d_x_blok.mem", ldir, 2*L + 2); $readmemh(yol, memW);
                    karsilastir64("LayerNorm 1 (ham cikis)", 5120, 1024, s*1024, 2);
                end
                11, 12: $display("   [katman %0d, satir %0d] ara sonuc: altin modelin ara vektor dosyasi bu satir icin zincirleme girdiyle uretilmedi; dogruluk sonraki LayerNorm ile denetlenir", L, r);
                13: begin
                    $sformat(yol, "ln%0d_cikis.mem", 2*L + 2); yukle8(ldir, yol);
                    if (2*L + 2 == 4) begin ntok = 1; nblk = 1; end else nblk = nbt;
                    karsilastir8("LayerNorm 2 (katman cikisi)", 0, 128, nblk, 128, 128, 0);
                end
                14: begin
                    yukle8(sdir, "pooler_tanh_zincir.mem");
                    karsilastir8("pooler (tanh, yalniz ilk token)", 1024, 128, 1, 128, 128, 0);
                end
                15: begin
                    yukle8(sdir, "classifier_zincir.mem");
                    karsilastir8("siniflandirici (iki sinif puani)", 2048, 1, 1, 2, 2, 0);
                end
                default: ;
            endcase
        end
    endtask

    initial begin
        errors = 0; nchk = 0; cyc = 0; catisma_say = 0; top_bayt = 0; sinif_dogru = 0;
        if (!$value$plusargs("vdir=%s", vdir)) vdir = VDIR_V;
        if (!$value$plusargs("ldir=%s", ldir)) ldir = LDIR_V;
        if (!$value$plusargs("sdir=%s", sdir)) sdir = SDIR_V;
        if (!$value$plusargs("akis=%s", akis_yol)) akis_yol = AKIS_V;
        if (!$value$plusargs("ns=%d", ns)) ns = 4;
        if (!$value$plusargs("aralik=%d", aralik)) aralik = 1;
        if (!$value$plusargs("hizli=%d", hizli)) hizli = 0;
        $readmemh(akis_yol, akis);
        // olcum kipinde agirlik paneli yazilmaz: X yayilmasin diye panel tamponunu sifirla (yalniz benzetim)
        if (HIZLI_OLCUM != 0) for (bi = 0; bi < 1024; bi = bi + 1) dut.u_cekirdek.u_panel_tamponu.agirlik[bi] = 64'd0;
        top_bayt = 0; while (top_bayt < AKIS_BAYT && akis[top_bayt] !== 8'bx) top_bayt = top_bayt + 1;
        $display("==== UCTAN UCA SINAMA: bayt akisi -> CRC-16 ayristirici -> sabit cizelge -> ortak cekirdek; %0d katman, %0d cumle; altin modelle bit-birebir ====", KATMAN, ns);
        $display("Cizelge katman basina 14 satir: Q(2 bas) K(2 bas) V | Q.K^T+Softmax ve P.V (2 bas) | cikis dogrusali | LayerNorm 1 | ileri besleme 1, 2 | LayerNorm 2");
        repeat (4) @(posedge clk); @(negedge clk); rst = 0; repeat (3) @(posedge clk);
        if (hizli != 0) begin
            gozlem = 0;
            $display("OLCUM KIPI: kontrolsuz; bayt araligi %0d cevrim", aralik);
            for (s = 0; s < ns; s = s + 1) begin
                cyc0 = cyc;
                @(posedge clk); while (!sonuc_gecerli) @(posedge clk);
                $display("[cumle %0d] toplam %0d cevrim (%0d ms @100 MHz); sinif=%0d puanlar %0d, %0d", s, cyc - cyc0, (cyc - cyc0) / 100000, sinif, logit0, logit1);
                $display("[cumle %0d] SAF HESAP (aktivasyon girisi haric) %0d cevrim = %0d.%02d ms @100 MHz; cumle_uzunluk=%0d; HIZLI_OLCUM=%0d",
                         s, cyc - cyc_akt, (cyc - cyc_akt) / 100000, ((cyc - cyc_akt) % 100000) / 1000, cumle_uzunluk, HIZLI_OLCUM);
            end
            $display("OLCUM BITTI: toplam %0d cevrim, %0d bayt akis", cyc, kabul_edilen_bayt);
            $finish;
        end
        $sformat(yol, "%0s/sinif_zincir.mem", sdir); $readmemh(yol, memSin);
        for (s = 0; s < ns; s = s + 1) begin
            sinif_beklenen = memSin[s];
            for (L = 0; L < KATMAN; L = L + 1)
                for (r = 0; r < ((L == KATMAN - 1) ? 16 : 14); r = r + 1) begin
                    @(posedge clk); while (!satir_bitti && !hata) @(posedge clk);
                    if (hata) begin $display("HATA: akis denetim kodu hatasi (katman %0d satir %0d)", L, r); errors = errors + 1; $finish; end
                    $display("[cumle %0d katman %0d satir %0d] bitti (cevrim %0d, okunan bayt %0d)", s, L, r, cyc, kabul_edilen_bayt);
                    satir_kontrol;
                    @(negedge clk); devam = 1; @(negedge clk); devam = 0;
                end
            @(posedge clk); while (!sonuc_gecerli) @(posedge clk);
            nchk = nchk + 1;
            $display("[cumle %0d] SONUC: sinif=%0d (puanlar %0d, %0d) | beklenen sinif=%0d : %0s", s, sinif, logit0, logit1, sinif_beklenen, (sinif == sinif_beklenen[0]) ? "DOGRU" : "YANLIS");
            if (sinif != sinif_beklenen[0]) errors = errors + 1; else sinif_dogru = sinif_dogru + 1;
        end
        repeat (10) @(posedge clk);
        if (catisma_say != 0) begin errors = errors + 1; $display("HATA: bellek okuma portlari %0d kez ayni birimde carpisti", catisma_say); end
        if (tasma_hatasi || skor_tasma || ln_tasma) begin errors = errors + 1; $display("HATA: tasma (dogrusal %0d skor %0d artik %0d)", tasma_hatasi, skor_tasma, ln_tasma); end
        if (hata_sayisi != 0) begin errors = errors + 1; $display("HATA: %0d denetim kodu hatasi", hata_sayisi); end
        $display("----------------------------------------------");
        $display("UCTAN UCA TEST: %0s  (%0d katman, %0d cumle, %0d kontrol, %0d hata, toplam %0d cevrim, %0d bayt akis, bellek carpismasi %0d)",
                 (errors == 0) ? "BASARILI" : "BASARISIZ", KATMAN, ns, nchk, errors, cyc, kabul_edilen_bayt, catisma_say);
        $finish;
    end
endmodule
