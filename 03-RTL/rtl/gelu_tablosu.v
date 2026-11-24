// -----------------------------------------------------------------------------
// gelu_tablosu.v -- 256 girisli INT8 -> INT8 tablo (GELU/tanh) (G8)
// Tablo host tarafindan yuklenir (<ad>_gelu_lut.mem'den, $readmemh sirasi: indeks = deger+128).
// Okuma anliktir (dagitik RAM: 256x8 = 64 LUT6 civari). Girdi INT8 isaretli.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module gelu_tablosu (
    input  wire              clk,
    input  wire              gelu_yaz_etkin,
    input  wire [7:0]        gelu_yaz_adres,
    input  wire [7:0]        gelu_yaz_veri,
    input  wire signed [7:0] giris_int8,
    output wire signed [7:0] cikis_int8
);
    reg [7:0] tablo [0:255];
    always @(posedge clk) if (gelu_yaz_etkin) tablo[gelu_yaz_adres] <= gelu_yaz_veri;
    wire [7:0] tablo_adresi = giris_int8 + 8'd128;           // -128 -> 0, 127 -> 255
    assign cikis_int8 = tablo[tablo_adresi];
endmodule
