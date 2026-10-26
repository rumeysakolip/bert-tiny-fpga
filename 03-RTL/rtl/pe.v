// -----------------------------------------------------------------------------
// pe.v -- parametrik islem hucresi (PE): A_W bit isaretli x B_W bit isaretli -> ACC_W bit MAC
// BIL 401 bitirme tasarimi: FPGA tabanli BERT-Tiny INT8 hizlandirici (G4)
//
// Cikis-sabit (output-stationary): acc PE icinde kalir, yalnizca a (soldan saga) ve
// b (yukaridan asagi) isleneni akar.
//
// A_W = 9 (varsayilan): A girisi 9 bit isaretli; araligi [-256, 255]. Hem INT8
//   aktivasyon [-128,127] hem de Softmax cikisi UINT8 [0,255] bu araliga tam sigar,
//   olcek degismez. B_W = 8: agirlik / V degeri INT8. ACC_W = 32.
//   En kotu durum: K=512, |a*b| <= 255*128 = 32640 -> |acc| <= 16 711 680 < 2^24.
//
// Davranis (yukselen kenar, senkron):
//   rst=1 : acc, a_out, b_out sifirlanir (en'den onceliklidir)
//   en=1  : acc <= acc + a_in*b_in ; a_out <= a_in ; b_out <= b_in
//   en=0  : her sey tutulur
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module pe #(
    parameter A_W   = 9,
    parameter B_W   = 8,
    parameter ACC_W = 32
) (
    input  wire                      clk,
    input  wire                      rst,     // senkron reset, aktif-yuksek
    input  wire                      en,
    input  wire signed [A_W-1:0]     a_in,
    input  wire signed [B_W-1:0]     b_in,
    output reg  signed [A_W-1:0]     a_out,
    output reg  signed [B_W-1:0]     b_out,
    output reg  signed [ACC_W-1:0]   acc
);

    wire signed [A_W+B_W-1:0] prod = a_in * b_in;

    always @(posedge clk) begin
        if (rst) begin
            a_out <= {A_W{1'b0}};
            b_out <= {B_W{1'b0}};
            acc   <= {ACC_W{1'b0}};
        end else if (en) begin
            a_out <= a_in;
            b_out <= b_in;
            acc   <= acc + prod;    // prod isaretli: isaret genisletilerek eklenir
        end
    end

endmodule
