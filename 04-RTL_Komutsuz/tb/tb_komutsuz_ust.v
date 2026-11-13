// tb_komutsuz_ust.v -- komutsuz prototip: bayt akisi -> CRC denetimi -> cizelge -> dogrusal katman (Q, K, V)
// Akis dosyasi (akis_uret.py) bayt bayt verilir; her cizelge satiri bitince cikis BRAM'i altin <ad>_cikis.mem ile
// BIT-BIREBIR karsilastirilir.
// plusarg: +akis=<hex> +vdir=<test_vektorleri> +ns=<cumle> +aralik=<n: iki bayt arasi cevrim, 1=her cevrim> [+hatali=1: CRC hatasi bekle]
// Hatali modda beklenen: hata=1 (CRC), cizelge durur, hatali panel tuketilmez.
`timescale 1ns/1ps
module tb_komutsuz_ust;
    parameter NS_V = 4;
    parameter K = 128, C = 128, NB = 8;
    parameter BAYT_CUMLE = 60515;                  // (1 + 8192 + 2) + 3*16*1090

    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg         bayt_gecerli = 0;
    reg  [7:0]  bayt_veri = 0;
    wire        bayt_hazir;
    wire        satir_bitti, hata, tasma_hatasi;
    reg         devam = 0;
    reg  [11:0] cikis_oku_adres = 0;
    wire [63:0] cikis_oku_veri;
    wire [3:0]  satir_no;
    wire [15:0] cumle_no;
    wire [31:0] hata_sayisi, kabul_edilen_bayt;
    wire [6:0]  cumle_uzunluk;

    komutsuz_ust dut (.clk(clk), .rst(rst), .bayt_gecerli(bayt_gecerli), .bayt_veri(bayt_veri), .bayt_hazir(bayt_hazir),
        .satir_bitti(satir_bitti), .devam(devam), .cikis_oku_adres(cikis_oku_adres), .cikis_oku_veri(cikis_oku_veri),
        .hata(hata), .satir_no(satir_no), .cumle_no(cumle_no), .hata_sayisi(hata_sayisi), .kabul_edilen_bayt(kabul_edilen_bayt), .cumle_uzunluk(cumle_uzunluk),
        .tasma_hatasi(tasma_hatasi));

    integer ns, aralik, hatali_mod, n_bayt, errors, nchk, cyc, cyc0, cyc_basla;
    reg [255*8:1] akisdosya, vdir, yol;
    reg [7:0] akis [0:NS_V*BAYT_CUMLE-1];
    reg [7:0] exq [0:NS_V*64*C-1];
    reg [7:0] exk [0:NS_V*64*C-1];
    reg [7:0] exv [0:NS_V*64*C-1];
    always @(posedge clk) cyc <= cyc + 1;

    // ---- bayt kaynagi: iki bayt arasi 'aralik' cevrim (1 = her cevrim) ----
    integer i_bayt = 0;
    task gonder;
        input [7:0] b;
        reg tamam;
        integer g;
        begin
            for (g = 1; g < aralik; g = g + 1) begin @(negedge clk); bayt_gecerli = 0; end
            tamam = 0;
            while (!tamam) begin
                @(negedge clk); bayt_veri = b; bayt_gecerli = 1; tamam = bayt_hazir;
            end
        end
    endtask
    initial begin : kaynak
        @(negedge rst);
        repeat (6) @(posedge clk);
        while (i_bayt < n_bayt) begin
            gonder(akis[i_bayt]);
            i_bayt = i_bayt + 1;
        end
        @(negedge clk); bayt_gecerli = 0;
    end

    // ---- cikis kontrolu ----
    integer c, blk, bi, sat, cum;
    reg [7:0] gelen, bekle_b;
    task kontrol_et;
        input integer cumle;
        input integer satir;
        begin
            for (blk = 0; blk < NB; blk = blk + 1)
                for (c = 0; c < C; c = c + 1) begin
                    @(negedge clk); cikis_oku_adres = blk*C + c;
                    @(negedge clk); @(negedge clk);
                    for (bi = 0; bi < 8; bi = bi + 1) begin
                        nchk = nchk + 1;
                        case (satir)
                            0: bekle_b = exq[(cumle*64 + blk*8 + bi)*C + c];
                            1: bekle_b = exk[(cumle*64 + blk*8 + bi)*C + c];
                            default: bekle_b = exv[(cumle*64 + blk*8 + bi)*C + c];
                        endcase
                        gelen = cikis_oku_veri[bi*8 +: 8];
                        if (gelen !== bekle_b) begin
                            errors = errors + 1;
                            if (errors < 6) $display("  FAIL cumle %0d satir %0d token %0d kanal %0d: dut=%0d beklenen=%0d", cumle, satir, blk*8+bi, c, $signed(gelen), $signed(bekle_b));
                        end
                    end
                end
        end
    endtask

    initial begin
        errors = 0; nchk = 0; cyc = 0;
        $display("==== KOMUTSUZ AKIS SINAMASI: bayt akisi -> denetim kodu -> cizelge -> dogrusal katman (Q, K, V), cumle uzunlugu akistan okunur ====");
        if (!$value$plusargs("akis=%s", akisdosya)) akisdosya = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/sim/akis_dogru.hex";   // Vivado'da parametresiz
        if (!$value$plusargs("vdir=%s", vdir)) vdir = "C:/Users/rumey/Documents/biitirme-projem/02-RTL_Altin_Model/03_Sonuclar/test_vektorleri";
        if (!$value$plusargs("ns=%d", ns)) ns = NS_V;
        if (!$value$plusargs("aralik=%d", aralik)) aralik = 1;
        if (!$value$plusargs("hatali=%d", hatali_mod)) hatali_mod = 0;
        n_bayt = ns * BAYT_CUMLE;
        $readmemh(akisdosya, akis);
        $sformat(yol, "%0s/l0_q_cikis.mem", vdir); $readmemh(yol, exq);
        $sformat(yol, "%0s/l0_k_cikis.mem", vdir); $readmemh(yol, exk);
        $sformat(yol, "%0s/l0_v_cikis.mem", vdir); $readmemh(yol, exv);
        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;
        cyc_basla = cyc;

        if (hatali_mod == 0) begin
            for (cum = 0; cum < ns; cum = cum + 1) begin
                cyc0 = cyc;
                for (sat = 0; sat < 3; sat = sat + 1) begin
                    while (!satir_bitti && cyc - cyc0 < 20000000) begin @(posedge clk); #1; if (hata) begin sat = 99; cum = 999; end end
                    if (!satir_bitti) begin errors = errors + 1; $display("  FAIL cumle %0d satir %0d: zaman asimi/hata", cum, sat); sat = 99; cum = 999; end
                    else begin
                        kontrol_et(cum, sat);
                        if (sat == 0) begin
                            if (cumle_uzunluk !== akis[cum*BAYT_CUMLE][6:0]) begin errors = errors + 1; $display("  FAIL cumle %0d: cumle uzunlugu devre=%0d akis=%0d", cum, cumle_uzunluk, akis[cum*BAYT_CUMLE][6:0]); end
                            else $display("   cumle %0d: akistan okunan cumle uzunlugu = %0d (denetim koduyla dogrulanmis)", cum, cumle_uzunluk);
                        end
                        @(negedge clk); devam = 1; @(negedge clk); devam = 0;
                    end
                end
                if (cum < 999) $display("BILGI cumle %0d: %0d cevrim (akis %0d bayt, aralik=%0d), hata=%0d", cum, cyc - cyc0, BAYT_CUMLE, aralik, hata);
            end
            if (hata || hata_sayisi != 0) begin errors = errors + 1; $display("  FAIL: beklenmeyen CRC hatasi (%0d)", hata_sayisi); end
            if (tasma_hatasi) begin errors = errors + 1; $display("  FAIL: golge ustune yazildi"); end
            $display("----------------------------------------------");
            $display("TOPLAM %0d cevrim, %0d bayt kabul, %0d kontrol", cyc - cyc_basla, kabul_edilen_bayt, nchk);
            if (errors == 0) $display("KOMUTSUZ PROTOTIP TEST (ns=%0d aralik=%0d): PASS  (%0d kontrol, 0 hata)", ns, aralik, nchk);
            else             $display("KOMUTSUZ PROTOTIP TEST (ns=%0d aralik=%0d): FAIL  (%0d hata)", ns, aralik, errors);
        end else begin
            // hatali akis: CRC hatasi yakalanmali, cizelge durmali
            cyc0 = cyc;
            while (!hata && cyc - cyc0 < 1500000) begin
                @(posedge clk); #1;
                if (satir_bitti) begin @(negedge clk); devam = 1; @(negedge clk); devam = 0; end   // cikis okunmaz; cizelge ilerlesin
            end
            repeat (3000) @(posedge clk);
            $display("----------------------------------------------");
            $display("HATALI AKIS: hata=%0d hata_sayisi=%0d kabul_edilen_bayt=%0d satir_no=%0d cumle_no=%0d", hata, hata_sayisi, kabul_edilen_bayt, satir_no, cumle_no);
            if (hata && hata_sayisi == 1 && !satir_bitti) $display("CRC HATA ENJEKSIYONU TEST: PASS  (hata yakalandi, cizelge durdu)");
            else $display("CRC HATA ENJEKSIYONU TEST: FAIL");
        end
        $finish;
    end
endmodule
