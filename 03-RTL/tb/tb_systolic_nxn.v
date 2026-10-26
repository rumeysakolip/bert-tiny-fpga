// tb_systolic_nxn.v -- systolic_nxn icin kendi kendini denetleyen testbench (G4)
// Parametreler (iverilog -P ile): N, KT.  Calisma zamani argumanlari (vvp +arg):
//   +vdir=tb/vektor_nxn/n8_k64   test vektoru klasoru (A.mem B.mem C.mem meta.mem)
//   +vcd=sim/tb_xxx.vcd          (istege bagli) ilk iki test icin VCD
// Senaryolar: mod 0 normal, mod 1 veri akisinda rastgele bosluklar (in_valid=0),
//   mod 2 hesap ortasinda reset + temiz yeniden kosu, mod 3 hesap ortasinda sahte start (yok sayilmali).
`timescale 1ns/1ps
module tb_systolic_nxn;
    parameter N  = 8;
    parameter KT = 64;
    parameter A_W = 9, B_W = 8, ACC_W = 32, K_W = 11;
    parameter MAXT = 256;

    reg                  clk = 0;
    reg                  rst = 1;
    reg                  start = 0;
    reg  [K_W-1:0]       k_len = 0;
    reg                  in_valid = 0;
    reg  [N*A_W-1:0]     a_col = 0;
    reg  [N*B_W-1:0]     b_row = 0;
    wire [N*N*ACC_W-1:0] c_flat;
    wire                 busy, done;

    systolic_nxn #(.N(N), .A_W(A_W), .B_W(B_W), .ACC_W(ACC_W), .K_W(K_W)) dut (
        .clk(clk), .rst(rst), .start(start), .k_len(k_len), .in_valid(in_valid),
        .a_col(a_col), .b_row(b_row), .c_flat(c_flat), .busy(busy), .done(done));

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
        reg [ACC_W-1:0] got, exp;
        begin
            for (a1 = 0; a1 < N; a1 = a1 + 1)
                for (a2 = 0; a2 < N; a2 = a2 + 1) begin
                    got = c_flat[(a1*N+a2)*ACC_W +: ACC_W];
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
                a_col[q*A_W +: A_W] = memA[tt*N*KT + q*KT + k];
                b_row[q*B_W +: B_W] = memB[tt*KT*N + k*N + q];
            end
            in_valid = 1;
        end
    endtask

    task sur_ve_bekle;                 // start + veri akisi + done; md: senaryo kipi
        input integer tt;
        input integer md;
        integer k, g;
        begin
            @(negedge clk); start = 1; k_len = KT; in_valid = 0;
            @(posedge clk); #1; cyc0 = cyc;                 // kenar 0: start orneklendi
            @(negedge clk); start = 0;
            for (k = 0; k < KT; k = k + 1) begin
                if (md == 2 && k == KT/2) begin               // yarida reset, sonra temiz yeniden kos
                    in_valid = 0; rst = 1;
                    @(negedge clk); rst = 0;
                    if (done !== 1'b0 || busy !== 1'b0) begin
                        t_bad = 1; errors = errors + 1;
                        $display("  FAIL test %0d: reset sonrasi done/busy temiz degil", tt);
                    end
                    yeniden = 1;
                    k = KT;                                   // donguyu bitir
                end else begin
                    if (md == 1 && ({$random} % 4) == 0) begin   // rastgele 1-3 cevrim bosluk
                        in_valid = 0; a_col = {N*A_W{1'bx}}; b_row = {N*B_W{1'bx}};
                        for (g = {$random} % 3; g >= 0; g = g - 1) @(negedge clk);
                    end
                    sutun_surucu(tt, k);
                    if (md == 3 && k == KT/2) begin           // sahte start (farkli k_len), yok sayilmali
                        start = 1; k_len = 3;
                    end
                    @(negedge clk);
                    if (start) begin start = 0; k_len = KT; end
                end
            end
            in_valid = 0; a_col = 0; b_row = 0;
            if (!yeniden) begin
                while (!done && (cyc - cyc0) < 8*KT + 200) begin @(posedge clk); #1; end
                lat = cyc - cyc0;
            end
        end
    endtask

    task kos;
        input integer tt;
        input integer md;
        begin
            t_bad = 0; yeniden = 0;
            sur_ve_bekle(tt, md);
            if (yeniden) begin                                // reset sonrasi tam yeniden kos
                yeniden = 0;
                sur_ve_bekle(tt, 0);
            end
            if (!done) begin
                t_bad = 1; errors = errors + 1;
                $display("  FAIL test %0d: zaman asimi (done gelmedi)", tt);
            end else begin
                if (md == 0) begin
                    if (lat < lat_min) lat_min = lat;
                    if (lat > lat_max) lat_max = lat;
                    if (lat != KT + 2*N - 2) begin
                        t_bad = 1; errors = errors + 1;
                        $display("  FAIL test %0d: tile cevrimi %0d (beklenen %0d)", tt, lat, KT + 2*N - 2);
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
            $display("HATA: +vdir=<klasor> verilmedi"); $display("SYSTOLIC NxN TEST: FAIL"); $finish;
        end
        if ($value$plusargs("vcd=%s", vcdfile)) begin
            $dumpfile(vcdfile); $dumpvars(0, tb_systolic_nxn); vcd_var = 1;
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
        if (done !== 1'b0 || busy !== 1'b0) begin
            errors = errors + 1; $display("FAIL: reset sonrasi done/busy 0 degil");
        end

        for (t = 0; t < ntest; t = t + 1) begin
            if (t == 2 && vcd_var) $dumpoff;                  // VCD'yi kucuk tut
            kos(t, 0);
        end
        kos(0, 1);  kos(ntest-1, 1);  kos(ntest/2, 1);        // veri akisinda bosluklar
        kos(1, 2);  kos(ntest/3, 2);                          // hesap ortasinda reset
        kos(2, 3);  kos(ntest/2, 3);                          // hesap ortasinda sahte start
        kos(0, 0);                                            // sonrasinda normal calisma

        $display("----------------------------------------------");
        $display("TILE_CEVRIM N=%0d K=%0d : olculen %0d..%0d, beklenen K+2N-2 = %0d",
                 N, KT, lat_min, lat_max, KT + 2*N - 2);
        if (errors == 0 && bad_tests == 0)
            $display("SYSTOLIC NxN TEST (N=%0d,K=%0d): PASS  (%0d test, %0d kontrol, 0 hata)", N, KT, ntest + 8, nchk);
        else
            $display("SYSTOLIC NxN TEST (N=%0d,K=%0d): FAIL  (%0d hatali test, %0d hata)", N, KT, bad_tests, errors);
        $finish;
    end
endmodule
