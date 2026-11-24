// lut_dizi_deneme.v -- DENEY (mimari notu icin): 8x8 cikis-sabit MAC dizisi, carpmalar DSP yerine LUT'ta (use_dsp = "no").
// Amac: ikinci/ucuncu bir 8x8 dizinin FPGA'nin bos LUT'larinda kac LUT ve hangi zamanlamayla yapilabilecegini OLCMEK. Tasarima baglanmaz.
`timescale 1ns/1ps
(* use_dsp = "no" *)
module pe_lut (
    input  wire clk, input  wire rst, input wire etkin,
    input  wire signed [8:0] a_giris, input wire signed [7:0] b_giris,
    output reg  signed [8:0] a_cikis, output reg signed [7:0] b_cikis,
    output reg  signed [31:0] birikec
);
    wire signed [16:0] carpim = a_giris * b_giris;
    always @(posedge clk) begin
        if (rst) begin a_cikis <= 0; b_cikis <= 0; birikec <= 0; end
        else if (etkin) begin a_cikis <= a_giris; b_cikis <= b_giris; birikec <= birikec + carpim; end
    end
endmodule

module lut_dizi_deneme (
    input  wire clk, input wire rst, input wire etkin,
    input  wire [8*9-1:0] a_sutunu, input wire [8*8-1:0] b_satiri,
    output wire [8*8*32-1:0] c_matrisi
);
    wire signed [8:0] a_h [0:8][0:8];   // [satir][sutun]
    wire signed [7:0] b_h [0:8][0:8];
    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : g_i
            assign a_h[i][0] = a_sutunu[i*9 +: 9];
            assign b_h[0][i] = b_satiri[i*8 +: 8];
        end
        for (i = 0; i < 8; i = i + 1) begin : g_s
            for (j = 0; j < 8; j = j + 1) begin : g_c
                pe_lut u_pe (.clk(clk), .rst(rst), .etkin(etkin), .a_giris(a_h[i][j]), .b_giris(b_h[i][j]),
                             .a_cikis(a_h[i][j+1]), .b_cikis(b_h[i+1][j]), .birikec(c_matrisi[(i*8+j)*32 +: 32]));
            end
        end
    endgenerate
endmodule
