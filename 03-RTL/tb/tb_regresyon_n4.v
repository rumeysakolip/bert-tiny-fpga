// tb_regresyon_n4.v -- N=4 yeni akisli dizi == eski systolic_4x4_eski (G4 regresyon)
// Ayni A (INT8) ve B ile iki modul surulur; c_matrisi 512 bit birebir ve altin C.mem ile karsilastirilir.
// Eski vektorler: tb/vektor/{A,B,C,meta}.mem (259 test, K=4). Calistirma kok: 03-RTL
`timescale 1ns/1ps
module tb_regresyon_n4;
    localparam MAXT = 1024;
    reg          clk = 0, rst = 1;
    // eski
    reg          o_start = 0;
    reg  [127:0] o_a = 0, o_b = 0;
    wire [511:0] o_c;
    wire         o_busy, o_done;
    // yeni
    reg          n_start = 0, pay_gecerli = 0;
    reg  [10:0]  n_k = 4;
    reg  [35:0]  n_a = 0;
    reg  [31:0]  n_b = 0;
    wire [511:0] n_c;
    wire         n_busy, n_done;

    systolic_4x4_eski eski (.clk(clk), .rst(rst), .start(o_start), .a_flat(o_a), .b_flat(o_b),
                            .c_flat(o_c), .busy(o_busy), .done(o_done));
    sistolik_dizi #(.DIZI_BOYUTU(4)) yeni (.clk(clk), .rst(rst), .baslat(n_start), .k_uzunlugu(n_k), .giris_gecerli(pay_gecerli),
                                .a_sutunu(n_a), .b_satiri(n_b), .c_matrisi(n_c), .mesgul(n_busy), .bitti(n_done));

    always #5 clk = ~clk;

    reg [7:0]  memA [0:MAXT*16-1];
    reg [7:0]  memB [0:MAXT*16-1];
    reg [31:0] memC [0:MAXT*16-1];
    reg [31:0] memMeta [0:0];
    integer ntest, t, k, q, errors, farkli_eski_yeni, lat_o, lat_n;
    reg [127:0] a_t, b_t;

    initial begin
        errors = 0; farkli_eski_yeni = 0; lat_o = 0; lat_n = 0;
        $readmemh("tb/vektor/meta.mem", memMeta);
        ntest = memMeta[0];
        $readmemh("tb/vektor/A.mem", memA, 0, ntest*16-1);
        $readmemh("tb/vektor/B.mem", memB, 0, ntest*16-1);
        $readmemh("tb/vektor/C.mem", memC, 0, ntest*16-1);
        repeat (3) @(posedge clk);
        @(negedge clk); rst = 0;
        repeat (2) @(posedge clk);
        for (t = 0; t < ntest; t = t + 1) begin
            for (q = 0; q < 16; q = q + 1) begin a_t[q*8 +: 8] = memA[t*16+q]; b_t[q*8 +: 8] = memB[t*16+q]; end
            // eski: tek darbe, her sey start'ta yakalanir; yeni: start + 4 cevrimde sutun/satir akisi
            @(negedge clk); o_start = 1; o_a = a_t; o_b = b_t; n_start = 1; pay_gecerli = 0;
            @(negedge clk); o_start = 0; n_start = 0;
            for (k = 0; k < 4; k = k + 1) begin
                // A sutunu k: A[i][k] (INT8 -> 9 bit isaret genisletme); B satiri k: B[k][j]
                for (q = 0; q < 4; q = q + 1) begin
                    n_a[q*9 +: 9] = {a_t[(q*4+k)*8+7], a_t[(q*4+k)*8 +: 8]};
                    n_b[q*8 +: 8] = b_t[(k*4+q)*8 +: 8];
                end
                pay_gecerli = 1;
                @(negedge clk);
            end
            pay_gecerli = 0;
            lat_o = 0; lat_n = 0;
            while (!o_done || !n_done) begin
                @(posedge clk); #1;
                if (!o_done) lat_o = lat_o + 1;
                if (!n_done) lat_n = lat_n + 1;
            end
            if (o_c !== n_c) begin farkli_eski_yeni = farkli_eski_yeni + 1; errors = errors + 1; end
            for (q = 0; q < 16; q = q + 1)
                if (n_c[q*32 +: 32] !== memC[t*16+q]) errors = errors + 1;
        end
        $display("----------------------------------------------");
        $display("N=4 regresyon: %0d vektor, eski!=yeni: %0d", ntest, farkli_eski_yeni);
        if (errors == 0) $display("REGRESYON N=4 TEST: PASS  (%0d test, eski ve yeni modul birebir, 0 hata)", ntest);
        else             $display("REGRESYON N=4 TEST: FAIL  (%0d hata)", errors);
        $finish;
    end
endmodule
