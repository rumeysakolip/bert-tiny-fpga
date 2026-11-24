// tb_softmax.v -- softmax_birim'i altin modelin softmax_tam vektorlerine karsi sinar (G11)
// +vdir=tb/vektor_g11   (sm_skor/sm_mask/sm_m0/sm_cikis/sm_lut/sm_meta .mem)
`timescale 1ns/1ps
module tb_softmax_gomulu;
    parameter L = 64;
    // +vdir verilmezse (Vivado GUI) bu klasor kullanilir. Baska bilgisayarda yolu degistirin.
    parameter VDIR_VARSAYILAN = "C:/Users/rumey/Documents/biitirme-projem/03-RTL/tb/vektor_g11";
    parameter TABLO_VARSAYILAN = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/rtl/exp_l0.mem";
    parameter MAXR = 512;
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg  [23:0] olcek_m0 = 0;
    reg         baslat = 0, giris_gecerli = 0, giris_maske = 0;
    reg  signed [31:0] giris_veri = 0;
    wire        giris_hazir, cikis_gecerli, cikis_son, mesgul;
    wire [7:0]  cikis_veri;

    softmax_birim_gomulu #(.SATIR_UZUNLUGU(L), .TABLO_DOSYASI(TABLO_VARSAYILAN)) dut (.clk(clk), .rst(rst),
        .olcek_m0(olcek_m0), .baslat(baslat), .giris_hazir(giris_hazir), .giris_gecerli(giris_gecerli), .giris_veri(giris_veri), .giris_maske(giris_maske),
        .cikis_gecerli(cikis_gecerli), .cikis_veri(cikis_veri), .cikis_son(cikis_son), .mesgul(mesgul));

    reg [31:0] mSkor [0:MAXR*L-1];
    reg [31:0] mMask [0:MAXR*L-1];
    reg [31:0] mCik  [0:MAXR*L-1];
    reg [31:0] mM0   [0:MAXR-1];
    reg [31:0] mMeta [0:1];
    reg [255*8:1] vdir, yol;
    reg [255*8:1] vcdf; reg vcd_ac = 0;
    integer nrow, r, i, hata, kontrol, bad_rows, cyc, cyc_min, cyc_max, got, h0;   // xsim: kullanimdan once bildirilmeli
    integer cnt_out;

    // faz sayaclari (satir 0 icin): dut.st her durumda kac cevrim kaldi
    integer stsay [0:15]; integer k_;
    initial for (k_ = 0; k_ < 16; k_ = k_ + 1) stsay[k_] = 0;
    reg say_ac = 0;
    always @(posedge clk) if (say_ac && dut.durum != 0) stsay[dut.durum] = stsay[dut.durum] + 1;

    always @(posedge clk) if (cikis_gecerli) begin
        if (cikis_veri !== mCik[r*L + cnt_out][7:0]) begin
            hata = hata + 1;
            if (hata < 10) $display("  HATA satir %0d eleman %0d: rtl=%0d beklenen=%0d", r, cnt_out, cikis_veri, mCik[r*L+cnt_out][7:0]);
        end
        kontrol = kontrol + 1; cnt_out = cnt_out + 1;
    end

    initial begin
        $display("==== SOFTMAX (gomulu ustel tablo) SINAMASI ====");
        $display("Ustel tablo, devre icinde baslangic degeriyle yuklu; disaridan yazma yok.");
        hata = 0; kontrol = 0; bad_rows = 0; cyc_min = 1000000; cyc_max = 0; cnt_out = 0;
        if (!$value$plusargs("vdir=%s", vdir)) begin vdir = VDIR_VARSAYILAN; $display("BILGI: +vdir verilmedi, varsayilan klasor: %0s", vdir); end
        $sformat(yol, "%0s/sm_meta.mem", vdir); $readmemh(yol, mMeta); nrow = mMeta[0];
        $sformat(yol, "%0s/sm_skor.mem", vdir); $readmemh(yol, mSkor);
        $sformat(yol, "%0s/sm_mask.mem", vdir); $readmemh(yol, mMask);
        $sformat(yol, "%0s/sm_cikis.mem", vdir); $readmemh(yol, mCik);
        $sformat(yol, "%0s/sm_m0.mem", vdir);   $readmemh(yol, mM0);
        if ($value$plusargs("vcd=%s", vcdf)) begin $dumpfile(vcdf); $dumpvars(0, tb_softmax_gomulu); vcd_ac = 1; end
        repeat (4) @(posedge clk); @(negedge clk); rst = 0;
        for (r = 0; r < nrow; r = r + 1) begin
            h0 = hata; cnt_out = 0; cyc = 0; say_ac = (r == 0);
            @(negedge clk); olcek_m0 = mM0[r][23:0]; baslat = 1;
            @(negedge clk); baslat = 0;
            for (i = 0; i < L; i = i + 1) begin
                @(negedge clk); giris_gecerli = 1; giris_veri = mSkor[r*L+i]; giris_maske = mMask[r*L+i][0];
            end
            @(negedge clk); giris_gecerli = 0;
            while (cnt_out < L && cyc < 200000) begin @(negedge clk); cyc = cyc + 1; end
            if (cnt_out != L) begin hata = hata + 1; $display("  HATA satir %0d: cikis sayisi %0d", r, cnt_out); end
            if (r == 0) begin say_ac = 0; for (k_ = 1; k_ < 16; k_ = k_ + 1) if (stsay[k_] != 0) $display("FAZ %0d %0d", k_, stsay[k_]); end
            if (hata != h0) bad_rows = bad_rows + 1;
            if (cyc < cyc_min) cyc_min = cyc; if (cyc > cyc_max) cyc_max = cyc;
            repeat (2) @(negedge clk);
            if ((r + 1) % 50 == 0 || r == nrow - 1) $display("  [ilerleme] %0d / %0d satir islendi, hata=%0d", r + 1, nrow, hata);
            if (vcd_ac && r == 0) begin $dumpoff; end
        end
        $display("SOFTMAX GOMULU TEST: %s  (%0d satir, %0d kontrol, %0d hata)  hesap_cevrimi=%0d..%0d",
                 (hata == 0) ? "BASARILI" : "BASARISIZ", nrow, kontrol, hata, cyc_min, cyc_max);
        $finish;
    end
endmodule
