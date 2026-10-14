// tb_pe.v -- pe.v için kendi kendini denetleyen testbench (yalnızca benzetim)
`timescale 1ns/1ps
module tb_pe;
    reg                clk = 0;
    reg                rst = 0;
    reg                en  = 0;
    reg  signed [7:0]  a_in = 0, b_in = 0;
    wire signed [7:0]  a_out, b_out;
    wire signed [31:0] acc;

    pe dut (.clk(clk), .rst(rst), .en(en), .a_in(a_in), .b_in(b_in),
            .a_out(a_out), .b_out(b_out), .acc(acc));

    always #5 clk = ~clk;

    integer errors = 0;
    integer checks = 0;
    reg signed [31:0] ref_acc;
    integer n;

    // Bir çevrim uygula (negedge'de sür, sonraki posedge'den sonra bak)
    task step;
        input r;
        input e;
        input signed [7:0] a;
        input signed [7:0] b;
        begin
            @(negedge clk);
            rst = r; en = e; a_in = a; b_in = b;
            @(posedge clk); #1;
        end
    endtask

    task check;
        input signed [31:0] exp_acc;
        input signed [7:0]  exp_a;
        input signed [7:0]  exp_b;
        input [255:0]       name;
        begin
            checks = checks + 1;
            if (acc !== exp_acc || a_out !== exp_a || b_out !== exp_b) begin
                errors = errors + 1;
                $display("FAIL [%0s] acc=%0d (beklenen %0d) a_out=%0d (%0d) b_out=%0d (%0d)",
                         name, acc, exp_acc, a_out, exp_a, b_out, exp_b);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_pe.vcd");
        $dumpvars(0, tb_pe);

        // 1) reset
        step(1, 0, 8'sd5, 8'sd5);
        check(0, 0, 0, "reset");

        // 2) enable=0 iken tutma
        step(0, 0, 8'sd7, 8'sd9);
        check(0, 0, 0, "en=0 tut");

        // 3) basit MAC: 3*4 = 12, sonra +(-2*5) = 2
        step(0, 1, 8'sd3, 8'sd4);   check(12, 3, 4, "3*4");
        step(0, 1, -8'sd2, 8'sd5);  check(2, -2, 5, "-2*5 birikim");

        // 4) en=0 -> acc ve a_out/b_out tutulur
        step(0, 0, 8'sd100, 8'sd100);
        check(2, -2, 5, "en=0 tut 2");

        // 5) reset, en=1 ile birlikte gelse de önceliklidir
        step(1, 1, 8'sd10, 8'sd10);
        check(0, 0, 0, "reset > en");

        // 6) uç değerler
        step(0, 1, -8'sd128, -8'sd128); check(16384, -128, -128, "-128*-128");
        step(1, 0, 0, 0);
        step(0, 1,  8'sd127,  8'sd127); check(16129, 127, 127, "127*127");
        step(1, 0, 0, 0);
        step(0, 1, -8'sd128,  8'sd127); check(-16256, -128, 127, "-128*127");
        step(1, 0, 0, 0);
        step(0, 1, -8'sd1, -8'sd1);     check(1, -1, -1, "-1*-1");
        step(0, 1,  8'sd0,  8'sd77);    check(1, 0, 77, "0*77");

        // 7) 1000 rastgele MAC, referans modelle bire bir karşılaştırma
        step(1, 0, 0, 0);
        ref_acc = 0;
        for (n = 0; n < 1000; n = n + 1) begin
            step(0, 1, $random, $random);
            ref_acc = ref_acc + $signed(a_in) * $signed(b_in);
            check(ref_acc, a_in, b_in, "rastgele");
        end

        // 8) en maksimum taşma kontrolü: 512 x (-128*-128) = 8388608 (K=512)
        step(1, 0, 0, 0);
        for (n = 0; n < 512; n = n + 1) step(0, 1, -8'sd128, -8'sd128);
        check(32'sd8388608, -128, -128, "K=512 en kötü durum");

        if (errors == 0) $display("PE TEST: PASS  (%0d kontrol, 0 hata)", checks);
        else             $display("PE TEST: FAIL  (%0d kontrol, %0d hata)", checks, errors);
        $finish;
    end
endmodule
