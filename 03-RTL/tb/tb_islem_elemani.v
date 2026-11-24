// tb_islem_elemani.v -- parametrik pe (A_GENISLIGI=9, B_GENISLIGI=8, BIRIKEC_GENISLIGI=32) icin kendi kendini denetleyen testbench (G4)
// Bolumler: (1) reset/en/duraklatma davranisi, (2) uc degerler, (3) UINT8 x INT8 birim testi (A 0..255),
// (4) INT8 x INT8, (5) rastgele 9 bit A. Referans: testbench icinde tamsayi model.
`timescale 1ns/1ps
module tb_islem_elemani;
    parameter A_GENISLIGI = 9, B_GENISLIGI = 8, BIRIKEC_GENISLIGI = 32;

    reg                         clk = 0;
    reg                         rst = 0;
    reg                         etkin  = 0;
    reg  signed [A_GENISLIGI-1:0]       a_giris = 0;
    reg  signed [B_GENISLIGI-1:0]       b_giris = 0;
    wire signed [A_GENISLIGI-1:0]       a_cikis;
    wire signed [B_GENISLIGI-1:0]       b_cikis;
    wire signed [BIRIKEC_GENISLIGI-1:0]     birikec;

    islem_elemani #(.A_GENISLIGI(A_GENISLIGI), .B_GENISLIGI(B_GENISLIGI), .BIRIKEC_GENISLIGI(BIRIKEC_GENISLIGI)) dut (
        .clk(clk), .rst(rst), .etkin(etkin), .a_giris(a_giris), .b_giris(b_giris),
        .a_cikis(a_cikis), .b_cikis(b_cikis), .birikec(birikec));

    always #5 clk = ~clk;

    integer errors = 0, checks = 0, n, bolum;
    integer ref_acc, ref_a, ref_b;
    integer bolum_hata [1:5];

    task adim;
        input r; input e; input integer a; input integer b;
        begin
            @(negedge clk); rst = r; etkin = e; a_giris = a; b_giris = b;
            @(posedge clk); #1;
            if (r)      begin ref_acc = 0; ref_a = 0; ref_b = 0; end
            else if (e) begin ref_acc = ref_acc + a * b; ref_a = a; ref_b = b; end
        end
    endtask

    task kontrol;
        begin
            checks = checks + 1;
            if (birikec !== ref_acc || a_cikis !== ref_a || b_cikis !== ref_b) begin
                errors = errors + 1; bolum_hata[bolum] = bolum_hata[bolum] + 1;
                if (errors < 6)
                    $display("  FAIL bolum %0d: acc=%0d (bek %0d) a_cikis=%0d (bek %0d) b_cikis=%0d (bek %0d)",
                             bolum, birikec, ref_acc, a_cikis, ref_a, b_cikis, ref_b);
            end
        end
    endtask

    integer i, a, b;
    reg [255*8:1] vcdf;
    initial begin
        // VCD yalnizca +vcd=<dosya> verilirse yazilir (Vivado'da gerek yok; orada dalga penceresi var)
        if ($value$plusargs("vcd=%s", vcdf)) begin $dumpfile(vcdf); $dumpvars(0, tb_islem_elemani); end
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
        if (birikec !== -16711680) begin errors = errors + 1; bolum_hata[2] = bolum_hata[2] + 1;
            $display("  FAIL K=512 en kotu negatif: %0d", birikec); end
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
