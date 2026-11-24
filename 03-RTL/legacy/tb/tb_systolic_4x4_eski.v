// tb_systolic_4x4.v -- systolic_4x4 için kendi kendini denetleyen testbench
// (yalnızca benzetim). Girdiler ve beklenen sonuç tb/gen_vektor.py (numpy)
// tarafından üretilen tb/vektor/*.mem dosyalarından okunur; çalıştırma
// donanim/ dizininden yapılmalıdır (bkz. README.md).
`timescale 1ns/1ps
module tb_systolic_4x4_eski;
    localparam MAXT = 1024;

    reg          clk = 0;
    reg          rst = 1;
    reg          start = 0;
    reg  [127:0] a_flat = 0, b_flat = 0;
    wire [511:0] c_flat;
    wire         busy, done;

    systolic_4x4_eski dut (.clk(clk), .rst(rst), .start(start), .a_flat(a_flat),
                      .b_flat(b_flat), .c_flat(c_flat), .busy(busy), .done(done));

    always #5 clk = ~clk;

    reg [7:0]  memA [0:MAXT*16-1];
    reg [7:0]  memB [0:MAXT*16-1];
    reg [31:0] memC [0:MAXT*16-1];
    reg [31:0] memMeta [0:0];

    integer ntest, t, i, j, lat, errors, bad_tests, lat_min, lat_max, mode;
    reg [127:0] a_t, b_t;
    reg         t_bad;
    reg         reset_yapildi;

    task yukle;                       // t numaralı testin A,B'sini düzleştir
        input integer tt;
        integer q;
        begin
            for (q = 0; q < 16; q = q + 1) begin
                a_t[q*8 +: 8] = memA[tt*16 + q];
                b_t[q*8 +: 8] = memB[tt*16 + q];
            end
        end
    endtask

    task karsilastir;                 // c_flat'ı memC ile bire bir karşılaştır
        input integer tt;
        integer ii, jj;
        reg [31:0] got, exp;
        begin
            for (ii = 0; ii < 4; ii = ii + 1)
                for (jj = 0; jj < 4; jj = jj + 1) begin
                    got = c_flat[(ii*4+jj)*32 +: 32];
                    exp = memC[tt*16 + ii*4 + jj];
                    if (got !== exp) begin
                        t_bad = 1;
                        errors = errors + 1;
                        if (bad_tests < 5)
                            $display("  FAIL test %0d C[%0d][%0d]: dut=%0d beklenen=%0d",
                                     tt, ii, jj, $signed(got), $signed(exp));
                    end
                end
        end
    endtask

    // mode 0: normal | 1: hesap ortasında sahte start (yok sayılmalı)
    //         2: hesap ortasında reset, sonra temiz yeniden çalıştırma
    task calistir;
        input integer tt;
        input integer md;
        begin
            t_bad = 0;
            yukle(tt);
            @(negedge clk); a_flat = a_t; b_flat = b_t; start = 1;
            @(posedge clk);                       // kenar 0: start örneklendi
            @(negedge clk); start = 0;
            a_flat = {4{$random}}; b_flat = {4{$random}};   // girişler bozulsun (yakalama testi)
            lat = 0;
            reset_yapildi = 0;
            while (!done && lat < 40) begin
                @(posedge clk); #1; lat = lat + 1;
                if (md == 1 && lat == 3) begin    // sahte start, farklı veriyle
                    a_flat = {4{$random}}; b_flat = {4{$random}}; start = 1;
                    @(posedge clk); #1; lat = lat + 1; start = 0;
                end
                if (md == 2 && lat == 4 && !reset_yapildi) begin    // ortada reset
                    reset_yapildi = 1;
                    rst = 1; @(posedge clk); #1; rst = 0;
                    if (done !== 1'b0 || busy !== 1'b0) begin
                        t_bad = 1; errors = errors + 1;
                        $display("  FAIL test %0d: reset sonrası done/busy temiz değil", tt);
                    end
                    // temiz yeniden çalıştırma
                    @(negedge clk); a_flat = a_t; b_flat = b_t; start = 1;
                    @(posedge clk);
                    @(negedge clk); start = 0;
                    a_flat = {4{$random}}; b_flat = {4{$random}};
                    lat = 0;
                end
            end
            if (!done) begin
                t_bad = 1; errors = errors + 1;
                $display("  FAIL test %0d: zaman aşımı (done gelmedi)", tt);
            end else begin
                if (md == 0) begin
                    if (lat < lat_min) lat_min = lat;
                    if (lat > lat_max) lat_max = lat;
                    if (lat != 10) begin
                        t_bad = 1; errors = errors + 1;
                        $display("  FAIL test %0d: gecikme %0d (beklenen 10)", tt, lat);
                    end
                end
                karsilastir(tt);
                // done sonrası 3 çevrim: sonuç tutulmalı
                repeat (3) @(posedge clk);
                #1; karsilastir(tt);
            end
            if (t_bad) bad_tests = bad_tests + 1;
        end
    endtask

    initial begin
        $dumpfile("sim/tb_systolic_4x4_eski.vcd");
        $dumpvars(0, tb_systolic_4x4_eski);

        errors = 0; bad_tests = 0; lat_min = 1000; lat_max = 0;
        $readmemh("tb/vektor/meta.mem", memMeta);
        ntest = memMeta[0];
        if (ntest < 1 || ntest > MAXT) begin
            $display("HATA: gecersiz test sayisi (%0d). Once: python3 tb/gen_vektor.py", ntest);
            $display("SYSTOLIC 4x4 TEST: FAIL");
            $finish;
        end
        $readmemh("tb/vektor/A.mem", memA, 0, ntest*16-1);
        $readmemh("tb/vektor/B.mem", memB, 0, ntest*16-1);
        $readmemh("tb/vektor/C.mem", memC, 0, ntest*16-1);

        // reset
        repeat (3) @(posedge clk);
        @(negedge clk); rst = 0;
        repeat (2) @(posedge clk);
        if (done !== 1'b0 || busy !== 1'b0) begin
            errors = errors + 1; $display("FAIL: reset sonrası done/busy 0 değil");
        end

        // vektör testleri (ardışık, aralarında reset yok)
        for (t = 0; t < ntest; t = t + 1) begin
            if (t == 12) $dumpoff;     // VCD'yi küçük tut: uç durumlar + birkaç rastgele test
            calistir(t, 0);
        end

        // ek senaryolar (vektör 8: karışık uç değerler ve 20: rastgele)
        calistir(0, 1);      // sahte start
        calistir(20, 1);
        calistir(8, 2);      // ortada reset
        calistir(30, 2);
        calistir(0, 0);      // reset sonrası normal çalışma sürüyor mu

        $display("----------------------------------------------");
        $display("Test sayisi (vektor)   : %0d (+5 ek senaryo)", ntest);
        $display("Gecikme (start kenarindan sonra done'a) : %0d..%0d cevrim", lat_min, lat_max);
        if (errors == 0 && bad_tests == 0)
            $display("SYSTOLIC 4x4 TEST: PASS  (%0d test, 0 hata)", ntest + 5);
        else
            $display("SYSTOLIC 4x4 TEST: FAIL  (%0d hatali test, %0d hata)", bad_tests, errors);
        $finish;
    end
endmodule
