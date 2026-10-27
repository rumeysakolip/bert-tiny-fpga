// -----------------------------------------------------------------------------
// yeniden_olcekle.v -- INT32 birikec -> INT8 (G6)
//   y = kirp( (acc * M0 + 2^(n-1)) >>> n , -128, 127 )        (n=0: yuvarlama sabiti 0)
// Altin model: nicem.sabit_nokta_carp + nicem.kirp (yuvarla_yukari: yarim -> yukari).
// acc = birikec + bias (tile denetleyici ekler), M0 31 bit isaretsiz (<2^30), n kaydirma (0..62).
//
// Boru hatti (3 asama, akis basina 1 eleman/cevrim, yan bilgi `meta` esit gecikmeyle tasinir):
//   A1: p  = acc * M0                64 bit isaretli  (DSP48E1 carpma; 32x31 -> ~4 DSP tahmini)
//   A2: s  = p + 2^(n-1)             64 bit
//   A3: y  = kirp(s >>> n)           8 bit
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module yeniden_olcekle #(
    parameter META_W = 18
) (
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  vin,
    input  wire signed [31:0]    acc,
    input  wire [30:0]           m0,
    input  wire [5:0]            n,
    input  wire [META_W-1:0]     meta_in,
    output reg                   vout,
    output reg  signed [7:0]     y,
    output reg  [META_W-1:0]     meta_out,
    output reg                   sat          // bu elemanda kirpma oldu (istatistik)
);
    reg                 v1, v2;
    reg [META_W-1:0]    m1, m2;
    reg [5:0]           n1, n2;
    reg signed [63:0]   p, s;

    wire signed [63:0] prod = acc * $signed({33'd0, m0});          // m0 pozitif
    wire signed [63:0] yuv  = (n2 == 6'd0) ? 64'sd0 : (64'sd1 <<< (n2 - 6'd1));
    wire signed [63:0] sh   = s >>> n2;

    always @(posedge clk) begin
        if (rst) begin
            v1 <= 1'b0; v2 <= 1'b0; vout <= 1'b0; sat <= 1'b0; y <= 8'sd0;
        end else begin
            // A1
            v1 <= vin; m1 <= meta_in; n1 <= n; p <= prod;
            // A2
            v2 <= v1; m2 <= m1; n2 <= n1; s <= p + ((n1 == 6'd0) ? 64'sd0 : (64'sd1 <<< (n1 - 6'd1)));
            // A3
            vout <= v2; meta_out <= m2;
            sat  <= v2 && ((sh > 64'sd127) || (sh < -64'sd128));
            if (sh > 64'sd127)       y <= 8'sd127;
            else if (sh < -64'sd128) y <= -8'sd128;
            else                     y <= sh[7:0];
        end
    end
endmodule
