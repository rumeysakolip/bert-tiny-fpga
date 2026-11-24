// tb_sistolik_dizi.v -- sistolik_dizi icin kendi kendini denetleyen testbench (G4)
// Parametreler (iverilog -P ile): N, KT.  Calisma zamani argumanlari (vvp +arg):
//   +vdir=tb/vektor_nxn/n8_k64   test vektoru klasoru (A.mem B.mem C.mem meta.mem)
//   +vcd=sim/tb_xxx.vcd          (istege bagli) ilk iki test icin VCD
// Senaryolar: mod 0 normal, mod 1 veri akisinda rastgele bosluklar (giris_gecerli=0),
//   mod 2 hesap ortasinda reset + temiz yeniden kosu, mod 3 hesap ortasinda sahte start (yok sayilmali).
`timescale 1ns/1ps
module tb_sistolik_dizi;
    parameter N  = 8;
    parameter KT = 64;
    parameter A_GENISLIGI = 9, B_GENISLIGI = 8, BIRIKEC_GENISLIGI = 32, K_GENISLIGI = 11;
    parameter MAXT = 256;
    // +vdir verilmezse (Vivado GUI) bu klasor kullanilir; K=64, N=8 vektorleri. Baska bilgisayarda yolu degistirin.
    parameter VDIR_VARSAYILAN = "C:/Users/rumey/Documents/biitirme-projem/03-RTL/tb/vektor_nxn/n8_k64";

    reg                  clk = 0;
    reg                  rst = 1;
    reg                  baslat = 0;
    reg  [K_GENISLIGI-1:0]       k_uzunlugu = 0;
    reg                  giris_gecerli = 0;
    reg  [N*A_GENISLIGI-1:0]     a_sutunu = 0;
    reg  [N*B_GENISLIGI-1:0]     b_satiri = 0;
    wire [N*N*BIRIKEC_GENISLIGI-1:0] c_matrisi;
    wire                 mesgul, bitti;

    sistolik_dizi #(.DIZI_BOYUTU(N), .A_GENISLIGI(A_GENISLIGI), .B_GENISLIGI(B_GENISLIGI), .BIRIKEC_GENISLIGI(BIRIKEC_GENISLIGI), .K_GENISLIGI(K_GENISLIGI)) dut (
        .clk(clk), .rst(rst), .baslat(baslat), .k_uzunlugu(k_uzunlugu), .giris_gecerli(giris_gecerli),
        .a_sutunu(a_sutunu), .b_satiri(b_satiri), .c_matrisi(c_matrisi), .mesgul(mesgul), .bitti(bitti));

    always #5 clk = ~clk;

    reg [15:0] memA [0:MAXT*N*KT-1];
    reg [7:0]  memB [0:MAXT*N*KT-1];
    reg [31:0] memC [0:MAXT*N*N-1];
    reg [31:0] memMeta [0:0];

    integer ntest, t, errors, bad_tests, lat, lat_min, lat_max, cyc, cyc0;
    integer kk, ii, jj, nchk, yeniden;
    reg     t_bad;
    reg [255*8:1] vdir;
    reg [255*8:1] vcdfile;
    reg [255*8:1] yol;
    integer vcd_var;

    always @(posedge clk) cyc <= cyc + 1;

    task karsilastir;
        input integer tt;
        integer a1, a2;
        reg [BIRIKEC_GENISLIGI-1:0] got, exp;
        begin
            for (a1 = 0; a1 < N; a1 = a1 + 1)
                for (a2 = 0; a2 < N; a2 = a2 + 1) begin
                    got = c_matrisi[(a1*N+a2)*BIRIKEC_GENISLIGI +: BIRIKEC_GENISLIGI];
                    exp = memC[tt*N*N + a1*N + a2];
                    nchk = nchk + 1;
                    if (got !== exp) begin
                        t_bad = 1; errors = errors + 1;
                        if (bad_tests < 5)
                            $display("  FAIL test %0d C[%0d][%0d]: dut=%0d beklenen=%0d",
                                     tt, a1, a2, $signed(got), $signed(exp));
                    end
                end
        end
    endtask

    task sutun_surucu;                 // k. sutun/satiri gecerli bayrakla surer
        input integer tt;
        input integer k;
        integer q;
        begin
            for (q = 0; q < N; q = q + 1) begin
                a_sutunu[q*A_GENISLIGI +: A_GENISLIGI] = memA[tt*N*KT + q*KT + k];
                b_satiri[q*B_GENISLIGI +: B_GENISLIGI] = memB[tt*KT*N + k*N + q];
            end
            giris_gecerli = 1;
        end
    endtask

    task sur_ve_bekle;                 // start + veri akisi + done; md: senaryo kipi
        input integer tt;
        input integer md;
        integer k, g;
        begin
            @(negedge clk); baslat = 1; k_uzunlugu = KT; giris_gecerli = 0;
            @(posedge clk); #1; cyc0 = cyc;                 // kenar 0: start orneklendi
            @(negedge clk); baslat = 0;
            for (k = 0; k < KT; k = k + 1) begin
                if (md == 2 && k == KT/2) begin               // yarida reset, sonra temiz yeniden kos
                    giris_gecerli = 0; rst = 1;
                    @(negedge clk); rst = 0;
                    if (bitti !== 1'b0 || mesgul !== 1'b0) begin
                        t_bad = 1; errors = errors + 1;
                        $display("  FAIL test %0d: reset sonrasi done/busy temiz degil", tt);
                    end
                    yeniden = 1;
                    k = KT;                                   // donguyu bitir
                end else begin
                    if (md == 1 && ({$random} % 4) == 0) begin   // rastgele 1-3 cevrim bosluk
                        giris_gecerli = 0; a_sutunu = {N*A_GENISLIGI{1'bx}}; b_satiri = {N*B_GENISLIGI{1'bx}};
                        for (g = {$random} % 3; g >= 0; g = g - 1) @(negedge clk);
                    end
                    sutun_surucu(tt, k);
                    if (md == 3 && k == KT/2) begin           // sahte start (farkli k_uzunlugu), yok sayilmali
                        baslat = 1; k_uzunlugu = 3;
                    end
                    @(negedge clk);
                    if (baslat) begin baslat = 0; k_uzunlugu = KT; end
                end
            end
            giris_gecerli = 0; a_sutunu = 0; b_satiri = 0;
            if (!yeniden) begin
                while (!bitti && (cyc - cyc0) < 8*KT + 200) begin @(posedge clk); #1; end
                lat = cyc - cyc0;
            end
        end
    endtask

    task calistir;
        input integer tt;
        input integer md;
        begin
            t_bad = 0; yeniden = 0;
            sur_ve_bekle(tt, md);
            if (yeniden) begin                                // reset sonrasi tam yeniden kos
                yeniden = 0;
                sur_ve_bekle(tt, 0);
            end
            if (!bitti) begin
                t_bad = 1; errors = errors + 1;
                $display("  FAIL test %0d: zaman asimi (done gelmedi)", tt);
            end else begin
                if (md == 0) begin
                    if (lat < lat_min) lat_min = lat;
                    if (lat > lat_max) lat_max = lat;
                    if (lat != KT + 2*N - 1) begin
                        t_bad = 1; errors = errors + 1;
                        $display("  FAIL test %0d: tile cevrimi %0d (beklenen %0d)", tt, lat, KT + 2*N - 1);
                    end
                end
                karsilastir(tt);
                repeat (3) @(posedge clk);                    // done sonrasi sonuc tutulmali
                #1; karsilastir(tt);
            end
            if (t_bad) bad_tests = bad_tests + 1;
        end
    endtask

    initial begin
        cyc = 0; errors = 0; bad_tests = 0; lat_min = 1000000; lat_max = 0; nchk = 0; yeniden = 0;
        if (!$value$plusargs("vdir=%s", vdir)) begin
            vdir = VDIR_VARSAYILAN;
            $display("BILGI: +vdir verilmedi, varsayilan klasor: %0s", vdir);
        end
        if ($value$plusargs("vcd=%s", vcdfile)) begin
            $dumpfile(vcdfile); $dumpvars(0, tb_sistolik_dizi); vcd_var = 1;
        end else vcd_var = 0;
        $sformat(yol, "%0s/meta.mem", vdir);  $readmemh(yol, memMeta);
        ntest = memMeta[0];
        if (ntest < 1 || ntest > MAXT) begin
            $display("HATA: gecersiz test sayisi (%0d)", ntest); $display("SYSTOLIC NxN TEST: FAIL"); $finish;
        end
        $sformat(yol, "%0s/A.mem", vdir); $readmemh(yol, memA, 0, ntest*N*KT-1);
        $sformat(yol, "%0s/B.mem", vdir); $readmemh(yol, memB, 0, ntest*N*KT-1);
        $sformat(yol, "%0s/C.mem", vdir); $readmemh(yol, memC, 0, ntest*N*N-1);

        repeat (3) @(posedge clk);
        @(negedge clk); rst = 0;
        repeat (2) @(posedge clk);
        if (bitti !== 1'b0 || mesgul !== 1'b0) begin
            errors = errors + 1; $display("FAIL: reset sonrasi done/busy 0 degil");
        end

        for (t = 0; t < ntest; t = t + 1) begin
            if (t == 2 && vcd_var) $dumpoff;                  // VCD'yi kucuk tut
            calistir(t, 0);
        end
        calistir(0, 1);  calistir(ntest-1, 1);  calistir(ntest/2, 1);        // veri akisinda bosluklar
        calistir(1, 2);  calistir(ntest/3, 2);                          // hesap ortasinda reset
        calistir(2, 3);  calistir(ntest/2, 3);                          // hesap ortasinda sahte start
        calistir(0, 0);                                            // sonrasinda normal calisma

        $display("----------------------------------------------");
        $display("TILE_CEVRIM N=%0d K=%0d : olculen %0d..%0d, beklenen K+2N-1 = %0d",
                 N, KT, lat_min, lat_max, KT + 2*N - 1);
        if (errors == 0 && bad_tests == 0)
            $display("SYSTOLIC NxN TEST (N=%0d,K=%0d): PASS  (%0d test, %0d kontrol, 0 hata)", N, KT, ntest + 8, nchk);
        else
            $display("SYSTOLIC NxN TEST (N=%0d,K=%0d): FAIL  (%0d hatali test, %0d hata)", N, KT, bad_tests, errors);
        $finish;
    end
endmodule
