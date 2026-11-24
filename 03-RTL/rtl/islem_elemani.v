// -----------------------------------------------------------------------------
// pe.v -- parametrik islem hucresi (PE): A_GENISLIGI bit isaretli x B_GENISLIGI bit isaretli -> BIRIKEC_GENISLIGI bit MAC
// BIL 401 bitirme tasarimi: FPGA tabanli BERT-Tiny INT8 hizlandirici (G4)
//
// Cikis-sabit (output-stationary): acc PE icinde kalir, yalnizca a (soldan saga) ve
// b (yukaridan asagi) isleneni akar.
//
// A_GENISLIGI = 9 (varsayilan): A girisi 9 bit isaretli; araligi [-256, 255]. Hem INT8
//   aktivasyon [-128,127] hem de Softmax cikisi UINT8 [0,255] bu araliga tam sigar,
//   olcek degismez. B_GENISLIGI = 8: agirlik / V degeri INT8. BIRIKEC_GENISLIGI = 32.
//   En kotu durum: K=512, |a*b| <= 255*128 = 32640 -> |acc| <= 16 711 680 < 2^24.
//
// Davranis (yukselen kenar, senkron):
//   rst=1 : acc, a_cikis, b_cikis sifirlanir (en'den onceliklidir)
//   en=1  : acc <= acc + a_giris*b_giris ; a_cikis <= a_giris ; b_cikis <= b_giris
//   en=0  : her sey tutulur
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
(* use_dsp = "yes" *)   // sentez ipucu: carp-biriktir DSP48E1'e eslensin (davranis degismez)
module islem_elemani #(
    parameter A_GENISLIGI   = 9,
    parameter B_GENISLIGI   = 8,
    parameter BIRIKEC_GENISLIGI = 32
) (
    input  wire                      clk,
    input  wire                      rst,     // senkron reset, aktif-yuksek
    input  wire                      etkin,
    input  wire signed [A_GENISLIGI-1:0]     a_giris,
    input  wire signed [B_GENISLIGI-1:0]     b_giris,
    output reg  signed [A_GENISLIGI-1:0]     a_cikis,
    output reg  signed [B_GENISLIGI-1:0]     b_cikis,
    output reg  signed [BIRIKEC_GENISLIGI-1:0]   birikec
);

    wire signed [A_GENISLIGI+B_GENISLIGI-1:0] carpim = a_giris * b_giris;

    always @(posedge clk) begin
        if (rst) begin
            a_cikis <= {A_GENISLIGI{1'b0}};
            b_cikis <= {B_GENISLIGI{1'b0}};
            birikec   <= {BIRIKEC_GENISLIGI{1'b0}};
        end else if (etkin) begin
            a_cikis <= a_giris;
            b_cikis <= b_giris;
            birikec   <= birikec + carpim;    // prod isaretli: isaret genisletilerek eklenir
        end
    end

endmodule
