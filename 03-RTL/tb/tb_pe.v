// tb_pe.v -- parametrik pe (A_W=9, B_W=8, ACC_W=32) icin kendi kendini denetleyen testbench (G4)
// Bolumler: (1) reset/en/duraklatma davranisi, (2) uc degerler, (3) UINT8 x INT8 birim testi (A 0..255),
// (4) INT8 x INT8, (5) rastgele 9 bit A. Referans: testbench icinde tamsayi model.
`timescale 1ns/1ps
module tb_pe;
    parameter A_W = 9, B_W = 8, ACC_W = 32;

    reg                         clk = 0;
    reg                         rst = 0;
    reg                         en  = 0;
    reg  signed [A_W-1:0]       a_in = 0;
    reg  signed [B_W-1:0]       b_in = 0;
    wire signed [A_W-1:0]       a_out;
    wire signed [B_W-1:0]       b_out;
    wire signed [ACC_W-1:0]     acc;

    pe #(.A_W(A_W), .B_W(B_W), .ACC_W(ACC_W)) dut (
        .clk(clk), .rst(rst), .en(en), .a_in(a_in), .b_in(b_in),
        .a_out(a_out), .b_out(b_out), .acc(acc));

    always #5 clk = ~clk;

    integer errors = 0, checks = 0, n, bolum;
    integer ref_acc, ref_a, ref_b;
    integer bolum_hata [1:5];

    task adim;
        input r; input e; input integer a; input integer b;
        begin
            @(negedge clk); rst = r; en = e; a_in = a; b_in = b;
            @(posedge clk); #1;
            if (r)      begin ref_acc = 0; ref_a = 0; ref_b = 0; end
            else if (e) begin ref_acc = ref_acc + a * b; ref_a = a; ref_b = b; end
        end
    endtask

    task kontrol;
        begin
            checks = checks + 1;
            if (acc !== ref_acc || a_out !== ref_a || b_out !== ref_b) begin
                errors = errors + 1; bolum_hata[bolum] = bolum_hata[bolum] + 1;
                if (errors < 6)
                    $display("  FAIL bolum %0d: acc=%0d (bek %0d) a_out=%0d (bek %0d) b_out=%0d (bek %0d)",
                             bolum, acc, ref_acc, a_out, ref_a, b_out, ref_b);
            end
        end
    endtask

    integer i, a, b;
    initial begin
        $dumpfile("sim/tb_pe.vcd"); $dumpvars(0, tb_pe);
        for (i = 1; i <= 5; i = i + 1) bolum_hata[i] = 0;

        // (1) reset / enable / duraklatma
        bolum = 1;
        adim(1, 0, 0, 0); kontrol;
        adim(0, 1, 100, 100); kontrol;
        adim(0, 0, 77, 77);   kontrol;               // en=0: tutulur
        adim(0, 1, -3, 5);    kontrol;
        adim(1, 1, 50, 50);   kontrol;               // rst, en'den oncelikli
        adim(0, 1, 7, 9);     kontrol;

        // (2) uc degerler (K=512 en kotu birikim dahil)
        bolum = 2;
        adim(1, 0, 0, 0);
        for (n = 0; n < 512; n = n + 1) begin adim(0, 1, 255, -128); end
        kontrol;                                      // acc = -32640*512
        if (acc !== -16711680) begin errors = errors + 1; bolum_hata[2] = bolum_hata[2] + 1;
            $display("  FAIL K=512 en kotu negatif: %0d", acc); end
        adim(1, 0, 0, 0);
        for (n = 0; n < 512; n = n + 1) begin adim(0, 1, -256, -128); end
        kontrol;                                      // 9 bit alt sinir: 32768*512
        adim(1, 0, 0, 0);
        for (n = 0; n < 512; n = n + 1) begin adim(0, 1, -128, -128); end
        kontrol;                                      // INT8 en kotu pozitif: 16384*512

        // (3) UINT8 (0..255) x INT8: Softmax cikisi x V
        bolum = 3;
        adim(1, 0, 0, 0);
        for (a = 0; a <= 255; a = a + 5)
            for (b = -128; b <= 127; b = b + 51) begin adim(0, 1, a, b); kontrol; end
        for (a = 250; a <= 255; a = a + 1) begin adim(0, 1, a, -128); kontrol; adim(0, 1, a, 127); kontrol; end

        // (4) INT8 x INT8
        bolum = 4;
        adim(1, 0, 0, 0);
        for (n = 0; n < 4000; n = n + 1) begin
            a = ($random % 128); b = ($random % 128);
            adim(0, 1, a, b); kontrol;
        end

        // (5) rastgele 9 bit A, rastgele en/rst
        bolum = 5;
        adim(1, 0, 0, 0);
        for (n = 0; n < 6000; n = n + 1) begin
            a = ({$random} % 512) - 256; b = ({$random} % 256) - 128;
            adim(({$random} % 50) == 0, ({$random} % 5) != 0, a, b); kontrol;
        end

        $display("----------------------------------------------");
        $display("bolum hatalari: 1=%0d 2=%0d 3=%0d 4=%0d 5=%0d", bolum_hata[1], bolum_hata[2],
                 bolum_hata[3], bolum_hata[4], bolum_hata[5]);
        if (errors == 0) $display("PE (9b x 8b -> 32b) TEST: PASS  (%0d kontrol, 0 hata)", checks);
        else             $display("PE (9b x 8b -> 32b) TEST: FAIL  (%0d kontrol, %0d hata)", checks, errors);
        $finish;
    end
endmodule
