// tb_kart_net.v -- sentez sonrasi aglistesi (kart_mantik_net.v) + flas modeli; yalniz kapilar uzerinden gozlem
`timescale 1ns/1ps
module tb_kart_net;
    parameter SENT_V = 0;
    parameter AKIS_V = "C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vektor_akis/akis_katman2.hex";
    localparam [23:0] TABAN = 24'h240000;
    localparam NS = 4, BAYT_CUMLE = 419429;
    reg clk = 0; always #5 clk = ~clk;
    reg btn = 0; reg [15:0] sw = SENT_V;
    wire [15:0] led; wire [6:0] seg; wire dp; wire [3:0] an;
    wire f_sck, f_cs_n, f_io0, f_oe; wire [3:0] f_out; wire f_surer;
    kart_mantik dut (.clk(clk), .btn(btn), .sw(sw), .led(led), .seg(seg), .dp(dp), .an(an),
        .flas_sck(f_sck), .flas_cs_n(f_cs_n), .flas_io0_o(f_io0), .flas_io_oe(f_oe), .flas_io_i(f_surer ? f_out : 4'h0));
    flas_modeli #(.BOYUT(NS*BAYT_CUMLE), .DOSYA(AKIS_V), .TABAN(TABAN), .TV(8)) flas (
        .sck(f_sck), .cs_n(f_cs_n), .io0_i(f_oe ? f_io0 : 1'b0), .io_o(f_out), .surer(f_surer));
    reg [8*4:1] ekran; integer cyc = 0; always @(posedge clk) cyc <= cyc + 1;
    function [7:0] karakter; input [6:0] s; begin
        case (s)
            7'b1000000: karakter = "0"; 7'b1111001: karakter = "1"; 7'b0100100: karakter = "2"; 7'b0110000: karakter = "3";
            7'b0011001: karakter = "4"; 7'b0010010: karakter = "5"; 7'b0000010: karakter = "6"; 7'b1111000: karakter = "7";
            7'b0000000: karakter = "8"; 7'b0010000: karakter = "9"; 7'b0111111: karakter = "-"; 7'b0000110: karakter = "E";
            7'b0101111: karakter = "r"; 7'b1111111: karakter = " "; default: karakter = "?";
        endcase end endfunction
    always @(posedge clk) begin
        if (!an[0]) ekran[8:1] <= karakter(seg);   if (!an[1]) ekran[16:9] <= karakter(seg);
        if (!an[2]) ekran[24:17] <= karakter(seg); if (!an[3]) ekran[32:25] <= karakter(seg);
    end
    integer sinir = 0;
    initial begin
        $display("==== AGLISTESI TESTI (sentez sonrasi, cumle %0d) ====", SENT_V);
        while (led[8] !== 1'b1 && led[6] !== 1'b1 && sinir < 30000000) begin @(posedge clk); sinir = sinir + 1; end
        $display("cevrim %0d: LED=%016b (bitti=%0b hata=%0b tasma=%0b esles=%0b)", cyc, led, led[8], led[6], led[7], led[11]);
        sw[15:14] = 2'd0; repeat (70000) @(posedge clk); $display("puan0 gosterge [%0s]", ekran);
        sw[15:14] = 2'd1; repeat (70000) @(posedge clk); $display("puan1 gosterge [%0s]", ekran);
        $display("AGLISTESI TESTI: %0s", (led[11] === 1'b1) ? "BASARILI" : "BASARISIZ");
        $finish;
    end
endmodule
