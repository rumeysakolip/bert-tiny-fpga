// -----------------------------------------------------------------------------
// yaz_fifo.v -- paralel dizilerin (lane) cikis sozcuklerini tek bellek yazma portuna siralayan kucuk FIFO (ilk veri hemen okunur)
//   Derinlik 64: bir devrik (V) tile'inda bir dizi 8 sozcugu arka arkaya uretir; NA dizi ayni anda 8*NA sozcuk birakir.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module yaz_fifo #(
    parameter W = 76,
    parameter DERINLIK_LOG2 = 6
) (
    input  wire         clk,
    input  wire         rst,
    input  wire         yaz,
    input  wire [W-1:0] giris,
    input  wire         oku,                 // veri gecerliyken bir sozcuk tuket
    output wire [W-1:0] cikis,
    output wire         bos,
    output reg          tasma                // dolu FIFO'ya yazma denendi (olmamali)
);
    reg [W-1:0] bellek [0:(1<<DERINLIK_LOG2)-1];
    reg [DERINLIK_LOG2:0] yp, op;
    assign bos   = (yp == op);
    assign cikis = bellek[op[DERINLIK_LOG2-1:0]];
    wire dolu = (yp[DERINLIK_LOG2-1:0] == op[DERINLIK_LOG2-1:0]) && (yp[DERINLIK_LOG2] != op[DERINLIK_LOG2]);
    always @(posedge clk) begin
        if (rst) begin yp <= 0; op <= 0; tasma <= 1'b0; end
        else begin
            if (yaz) begin
                if (dolu) tasma <= 1'b1;
                else begin bellek[yp[DERINLIK_LOG2-1:0]] <= giris; yp <= yp + 1'b1; end
            end
            if (oku && !bos) op <= op + 1'b1;
        end
    end
endmodule
