// -----------------------------------------------------------------------------
// gelu_lut.v -- 256 girisli INT8 -> INT8 tablo (GELU/tanh) (G8)
// Tablo host tarafindan yuklenir (<ad>_gelu_lut.mem'den, $readmemh sirasi: indeks = deger+128).
// Okuma anliktir (dagitik RAM: 256x8 = 64 LUT6 civari). Girdi INT8 isaretli.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module gelu_lut (
    input  wire              clk,
    input  wire              lw_en,
    input  wire [7:0]        lw_addr,
    input  wire [7:0]        lw_data,
    input  wire signed [7:0] x,
    output wire signed [7:0] y
);
    reg [7:0] rom [0:255];
    always @(posedge clk) if (lw_en) rom[lw_addr] <= lw_data;
    wire [7:0] idx = x + 8'd128;           // -128 -> 0, 127 -> 255
    assign y = rom[idx];
endmodule
