// tb_kart.v -- kart mantigi + flas modeli: flastan cumle akisi -> hizlandirici -> LED ve gosterge; altin modelle karsilastirir.
//   Vivado'da parametresiz calisir (cumle 2, SCK = 100 MHz / 8). plusarg: +sent=<0..3> +akis=<hex dosyasi>
//   Denetler: sinif ve iki puan altin modelle ayni, hata ve tasma LED'leri sonmus, flas ile denetleyici ayni anda hat surmuyor,
//             gostergenin dort modu beklenen karakterleri gosteriyor.
`timescale 1ns/1ps
module tb_kart;
    parameter BOL = 4;
    parameter SENT_V = 2;
    parameter AKIS_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_akis/akis_katman2.hex";
    localparam [23:0] TABAN = 24'h240000;
    localparam NS = 4, BAYT_CUMLE = 419429;

    reg clk = 0;
    always #5 clk = ~clk;
    reg  btn = 0;
    reg  [15:0] sw = 16'd0;
    wire [15:0] led; wire [6:0] seg; wire dp; wire [3:0] an;
    wire f_sck, f_cs_n, f_io0, f_oe; wire [3:0] f_out; wire f_surer;

    // kart hatti: denetleyici io0'i yalniz f_oe iken surer; flas yalniz veri asamasinda surer
    kart_mantik #(.BOL(BOL), .AKIS_TABAN(TABAN), .CUMLE_BAYT(BAYT_CUMLE), .DEB_BIT(4)) dut (
        .clk(clk), .btn(btn), .sw(sw), .led(led), .seg(seg), .dp(dp), .an(an),
        .flas_sck(f_sck), .flas_cs_n(f_cs_n), .flas_io0_o(f_io0), .flas_io_oe(f_oe), .flas_io_i(f_surer ? f_out : 4'h0));
    flas_modeli #(.BOYUT(NS*BAYT_CUMLE), .DOSYA(AKIS_V), .TABAN(TABAN), .TV(8)) flas (
        .sck(f_sck), .cs_n(f_cs_n), .io0_i(f_oe ? f_io0 : 1'b0), .io_o(f_out), .surer(f_surer));

    integer sent_n, errors = 0, cyc = 0;
    reg [3:0] onceki_satir = 4'hF; reg [3:0] onceki_kat = 4'hF;
    always @(posedge clk) begin
        if (dut.u_ust.satir_no !== onceki_satir || dut.u_ust.katman_no !== onceki_kat) begin
            onceki_satir <= dut.u_ust.satir_no; onceki_kat <= dut.u_ust.katman_no;
            if (verbose) $display("   [cevrim %0d] katman %0d satir %0d basladi, okunan bayt %0d", cyc, dut.u_ust.katman_no, dut.u_ust.satir_no, dut.kabul_edilen_bayt);
        end
        if (dut.sonuc_gecerli) $display("   [cevrim %0d] SONUC DARBESI: sinif=%0d puan %0d %0d, okunan bayt %0d", cyc, dut.sinif, dut.logit0, dut.logit1, dut.kabul_edilen_bayt);
    end
    reg verbose = 0;
    reg [255*8:1] akis_yol;
    always @(posedge clk) cyc <= cyc + 1;

    // hat cakismasi: ayni anda hem denetleyici hem flas suruyorsa hata
    integer catisma = 0;
    always @(posedge clk) if (f_oe && f_surer) catisma <= catisma + 1;

    // gosterge ornekleme: her an[k] etkinken seg'i karaktere cevir
    reg [8*4:1] ekran;
    function [7:0] karakter; input [6:0] s; begin
        case (s)
            7'b1000000: karakter = "0"; 7'b1111001: karakter = "1"; 7'b0100100: karakter = "2"; 7'b0110000: karakter = "3";
            7'b0011001: karakter = "4"; 7'b0010010: karakter = "5"; 7'b0000010: karakter = "6"; 7'b1111000: karakter = "7";
            7'b0000000: karakter = "8"; 7'b0010000: karakter = "9"; 7'b0111111: karakter = "-"; 7'b0000110: karakter = "E";
            7'b0101111: karakter = "r"; 7'b1111111: karakter = " "; default: karakter = "?";
        endcase end endfunction
    reg dp_onda;
    always @(posedge clk) begin
        if (!an[0]) ekran[8:1]   <= karakter(seg);
        if (!an[1]) begin ekran[16:9]  <= karakter(seg); dp_onda <= !dp; end
        if (!an[2]) ekran[24:17] <= karakter(seg);
        if (!an[3]) ekran[32:25] <= karakter(seg);
    end

    reg [8*4:1] ekran_beklenen;
    task bekle_yenile; begin repeat (70000) @(posedge clk); end endtask
    task ekran_yaz; input [255:0] ad; begin
        bekle_yenile; $display("   gosterge %0s : [%0s]%0s", ad, ekran, dp_onda ? " (nokta: ondalik)" : ""); end endtask

    initial begin
        if (!$value$plusargs("sent=%d", sent_n)) sent_n = SENT_V;
        if ($test$plusargs("ayrinti")) verbose = 1;
        sw = {16'd0} | sent_n[1:0];
        $display("==== KART TESTI: flas (SCK=%0d MHz) -> akis ayristirici -> hizlandirici -> LED/gosterge; cumle %0d ====", 100/(2*BOL), sent_n);
        // sonuc bitene kadar bekle (LED[8])
        begin : bekle
            integer sinir; sinir = 0;
            while (!led[8] && !led[6] && sinir < 40000000) begin @(posedge clk); sinir = sinir + 1; end
            if (!led[8]) begin $display("HATA: sonuc gelmedi (hata LED=%0b, satir=%0d, okunan bayt=%0d)", led[6], led[3:0], dut.kabul_edilen_bayt); errors = errors + 1; end
        end
        repeat (3000) @(posedge clk);
        $display("bitti: cevrim %0d (%0d.%01d ms), sinif=%0d puanlar %0d %0d, okunan bayt %0d", cyc, cyc/100000, (cyc/10000)%10, dut.sinif_k, dut.l0, dut.l1, dut.kabul_edilen_bayt);
        $display("LED = %016b  (satir=%0d, hata=%0b, tasma=%0b, bitti=%0b, sinif1=%0b, sinif0=%0b, esles=%0b, secili cumle=%0d, flas bitti=%0b)",
                 led, led[3:0], led[6], led[7], led[8], led[9], led[10], led[11], led[13:12], led[14]);
        if (led[6] || led[7]) begin $display("HATA: hata veya tasma LED'i yandi"); errors = errors + 1; end
        if (!led[11])         begin $display("HATA: puanlar altin modelle ayni degil"); errors = errors + 1; end
        if (!led[14])         begin $display("HATA: flas okuma bitmedi"); errors = errors + 1; end
        if (led[13:12] != sent_n[1:0]) begin $display("HATA: secili cumle LED'i yanlis"); errors = errors + 1; end
        if (dut.kabul_edilen_bayt != BAYT_CUMLE) begin $display("HATA: kabul edilen bayt %0d != %0d", dut.kabul_edilen_bayt, BAYT_CUMLE); errors = errors + 1; end
        if (catisma != 0)     begin $display("HATA: veri hatti cakismasi %0d cevrim", catisma); errors = errors + 1; end
        // gosterge modlari
        sw[15:14] = 2'd0; ekran_yaz("mod0 (puan0)");
        begin : kont0
            integer v0; v0 = dut.l0; if (v0 < 0) v0 = -v0;
            $sformat(ekran_beklenen, "%0s%03d", (dut.l0 < 0) ? "-" : " ", v0);
            if (ekran !== ekran_beklenen) begin $display("HATA: mod0 gosterge [%0s] beklenen [%0s]", ekran, ekran_beklenen); errors = errors + 1; end
        end
        sw[15:14] = 2'd1; ekran_yaz("mod1 (puan1)");
        begin : kont1
            integer v1; v1 = dut.l1; if (v1 < 0) v1 = -v1;
            $sformat(ekran_beklenen, "%0s%03d", (dut.l1 < 0) ? "-" : " ", v1);
            if (ekran !== ekran_beklenen) begin $display("HATA: mod1 gosterge [%0s] beklenen [%0s]", ekran, ekran_beklenen); errors = errors + 1; end
        end
        sw[15:14] = 2'd2; ekran_yaz("mod2 (sure, ms)");
        if (!dp_onda) begin $display("HATA: sure modunda ondalik nokta yok"); errors = errors + 1; end
        sw[15:14] = 2'd3; ekran_yaz("mod3 (okunan KB)");
        begin : kont3
            $sformat(ekran_beklenen, "%04d", dut.kabul_edilen_bayt >> 10);
            if (ekran !== ekran_beklenen) begin $display("HATA: mod3 gosterge [%0s] beklenen [%0s]", ekran, ekran_beklenen); errors = errors + 1; end
        end
        if ($test$plusargs("degistir")) begin : degistir
            // cumle anahtarini degistir: hesap kendiliginden bastan baslamali ve yeni cumlenin sonucu dogru cikmali
            integer yeni; yeni = (sent_n + 1) % 4; sw[1:0] = yeni;
            begin : g0 integer s0; s0 = 0; while (led[8] !== 1'b0 && s0 < 2000000) begin @(posedge clk); s0 = s0 + 1; end
                  if (led[8] !== 1'b0) begin $display("HATA: anahtar degisince yeniden baslama olmadi"); errors = errors + 1; end end
            begin : g1 integer s1; s1 = 0; while (led[8] !== 1'b1 && led[6] !== 1'b1 && s1 < 40000000) begin @(posedge clk); s1 = s1 + 1; end end
            repeat (3000) @(posedge clk);
            $display("anahtar degisti -> cumle %0d: sinif=%0d puanlar %0d %0d, LED=%016b", yeni, dut.sinif_k, dut.l0, dut.l1, led);
            if (led[13:12] != yeni[1:0] || !led[11] || led[6] || led[7]) begin $display("HATA: yeni cumle sonucu yanlis"); errors = errors + 1; end
        end
        if (errors == 0) $display("KART TESTI: BASARILI  (cumle %0d, sinif %0d, puanlar %0d %0d, %0d cevrim, %0d bayt flastan okundu)", sent_n, dut.sinif_k, dut.l0, dut.l1, cyc, dut.kabul_edilen_bayt);
        else $display("KART TESTI: BASARISIZ  (%0d hata)", errors);
        $finish;
    end
endmodule
