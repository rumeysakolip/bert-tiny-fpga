// tb_ters_bolucu.v -- ters_bolucu'i Python referans vektorlerine (tam tamsayi bolme) karsi sinar (Konu 4a)
// -P tb_ters_bolucu.NW= .DW= .QB=     vvp: +vdir=<klasor> +ad=<on ek> +nden=<bolen sayisi>
// Dosyalar (<vdir>/<ad>_*.mem, satir basina bir hex sayi): den, n (her bolen icin NPER bolunen), q (beklenen bolum, doyurulmus),
//   kal (beklenen kalan_var), tas (beklenen tasma).
// Akis: her bolen icin ters_baslat -> ters_hazir -> NPER eleman (ilk yari art arda, ikinci yari rastgele bosluklu) -> bosalt.
// Denetlenen: q, kalan_var, tasma, yan bilgi (eleman sirasi) ve sira (her cikis beklenen sirada).
`timescale 1ns/1ps
module tb_ters_bolucu;
    parameter PAY_GENISLIGI = 24, BOLEN_GENISLIGI = 22, BOLUM_GENISLIGI = 8;
    parameter NPER = 8;
    parameter MAXD = 130000;
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    reg              ters_baslat = 0;
    reg  [BOLEN_GENISLIGI-1:0]    bolen = 1;
    wire             ters_hazir;
    reg              pay_gecerli = 0;
    reg  [PAY_GENISLIGI-1:0]    pay_veri = 0;
    reg  [3:0]       yan_bilgi_giris = 0;
    wire             bolum_gecerli, kalan_var, tasma;
    wire [BOLUM_GENISLIGI-1:0]    bolum;
    wire [3:0]       yan_bilgi_cikis;

    ters_bolucu #(.PAY_GENISLIGI(PAY_GENISLIGI), .BOLEN_GENISLIGI(BOLEN_GENISLIGI), .BOLUM_GENISLIGI(BOLUM_GENISLIGI), .YAN_GENISLIGI(4)) dut (.clk(clk), .rst(rst), .ters_baslat(ters_baslat), .bolen(bolen),
        .ters_hazir(ters_hazir), .pay_gecerli(pay_gecerli), .pay_veri(pay_veri), .yan_bilgi_giris(yan_bilgi_giris), .bolum_gecerli(bolum_gecerli), .bolum(bolum),
        .kalan_var(kalan_var), .tasma(tasma), .yan_bilgi_cikis(yan_bilgi_cikis));

    reg [31:0] mDen [0:MAXD-1];
    reg [31:0] mN   [0:MAXD*NPER-1];
    reg [31:0] mQ   [0:MAXD*NPER-1];
    reg [7:0]  mKal [0:MAXD*NPER-1];
    reg [7:0]  mTas [0:MAXD*NPER-1];
    reg [255*8:1] vdir, ad, yol;
    integer nden, d, k, hata, kontrol, oi, bekle, cyc, gap;
    always @(posedge clk) cyc <= cyc + 1;

    // cikis denetleyicisi
    always @(posedge clk) if (bolum_gecerli && !rst) begin
        kontrol = kontrol + 1;
        if (bolum !== mQ[oi][BOLUM_GENISLIGI-1:0] || kalan_var !== mKal[oi][0] || tasma !== mTas[oi][0] || yan_bilgi_cikis !== (oi % NPER)) begin
            hata = hata + 1;
            if (hata < 6) $display("  FAIL #%0d (bolen %0d n %0d): q=%0d/%0d kalan=%0d/%0d tasma=%0d/%0d yan=%0d/%0d", oi, mDen[oi/NPER], mN[oi],
                bolum, mQ[oi][BOLUM_GENISLIGI-1:0], kalan_var, mKal[oi][0], tasma, mTas[oi][0], yan_bilgi_cikis, oi % NPER);
        end
        oi = oi + 1;
    end

    initial begin
        cyc = 0; hata = 0; kontrol = 0; oi = 0;
        if (!$value$plusargs("vdir=%s", vdir)) vdir = "sim/ters_vek";
        if (!$value$plusargs("ad=%s", ad)) ad = "sm";
        if (!$value$plusargs("nden=%d", nden)) nden = 1000;
        $sformat(yol, "%0s/%0s_den.mem", vdir, ad); $readmemh(yol, mDen);
        $sformat(yol, "%0s/%0s_n.mem", vdir, ad);   $readmemh(yol, mN);
        $sformat(yol, "%0s/%0s_q.mem", vdir, ad);   $readmemh(yol, mQ);
        $sformat(yol, "%0s/%0s_kal.mem", vdir, ad); $readmemh(yol, mKal);
        $sformat(yol, "%0s/%0s_tas.mem", vdir, ad); $readmemh(yol, mTas);
        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;
        repeat (3) @(posedge clk);
        for (d = 0; d < nden; d = d + 1) begin
            @(negedge clk); ters_baslat = 1; bolen = mDen[d][BOLEN_GENISLIGI-1:0];
            @(negedge clk); ters_baslat = 0;
            bekle = 0;
            while (!ters_hazir && bekle < 200) begin @(posedge clk); #1; bekle = bekle + 1; end
            if (bekle >= 200) begin hata = hata + 1; $display("  FAIL: ters_hazir gelmedi (bolen %0d)", mDen[d]); end
            for (k = 0; k < NPER; k = k + 1) begin
                if (k >= NPER/2) begin gap = $random & 3; repeat (gap) begin @(negedge clk); pay_gecerli = 0; end end   // ikinci yari: rastgele bosluk
                @(negedge clk); pay_gecerli = 1; pay_veri = mN[d*NPER + k][PAY_GENISLIGI-1:0]; yan_bilgi_giris = k;
            end
            @(negedge clk); pay_gecerli = 0;
            bekle = 0;
            while (oi < (d + 1) * NPER && bekle < 200) begin @(posedge clk); #1; bekle = bekle + 1; end
            if (oi < (d + 1) * NPER) begin hata = hata + 1; $display("  FAIL: cikis eksik (bolen %0d, %0d/%0d)", mDen[d], oi, (d + 1) * NPER); oi = (d + 1) * NPER; end
        end
        repeat (4) @(posedge clk);
        $display("BOLUCU_TERS TEST (NW=%0d DW=%0d QB=%0d): %0s  (%0d bolen, %0d kontrol, %0d hata, %0d cevrim)",
                 PAY_GENISLIGI, BOLEN_GENISLIGI, BOLUM_GENISLIGI, (hata == 0 && kontrol == nden * NPER) ? "PASS" : "FAIL", nden, kontrol, hata, cyc);
        $finish;
    end
endmodule
