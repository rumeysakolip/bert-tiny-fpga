// -----------------------------------------------------------------------------
// yeniden_olcekle.v -- INT32 birikec -> INT8 (G6)
//   y = kirp( (acc * M0 + 2^(n-1)) >>> n , -128, 127 )        (n=0: yuvarlama sabiti 0)
// Altin model: nicem.sabit_nokta_carp + nicem.kirp (yuvarla_yukari: yarim -> yukari).
// acc = birikec + bias (tile denetleyici ekler), M0 31 bit isaretsiz (<2^30), n kaydirma (0..62).
//
// Boru hatti (4 asama, akis basina 1 eleman/cevrim, yan bilgi `meta` esit gecikmeyle tasinir):
//   A1: p  = acc * M0                64 bit isaretli  (DSP48E1 carpma; 32x31 -> ~4 DSP tahmini)
//   A2: s  = p + 2^(n-1)             64 bit
//   A3: sh = s >>> n                 64 bit (Konu 6: kaydirma ile kirpma ayri asamalarda)
//   A4: y  = kirp(sh)                8 bit
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module yeniden_olcekle #(
    parameter META_W = 18
) (
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  giris_gecerli,
    input  wire signed [31:0]    birikec,
    input  wire [30:0]           olcek_m0,
    input  wire [5:0]            kaydirma,
    input  wire [META_W-1:0]     yan_bilgi_giris,
    output reg                   cikis_gecerli,
    output reg  signed [7:0]     cikis_int8,
    output reg  [META_W-1:0]     yan_bilgi_cikis,
    output reg                   kirpildi          // bu elemanda kirpma oldu (istatistik)
);
    reg                 asama1_gecerli, asama2_gecerli, asama3_gecerli;
    reg [META_W-1:0]    asama1_yan_bilgi, asama2_yan_bilgi, asama3_yan_bilgi;
    reg [5:0]           asama1_kaydirma, asama2_kaydirma;
    reg signed [63:0]   carpim_kayit, yuvarlanmis, kaydirilmis;

    wire signed [63:0] carpim = birikec * $signed({33'd0, olcek_m0});          // olcek_m0 pozitif
    wire signed [63:0] yuvarlama_sabiti  = (asama2_kaydirma == 6'd0) ? 64'sd0 : (64'sd1 <<< (asama2_kaydirma - 6'd1));

    always @(posedge clk) begin
        if (rst) begin
            asama1_gecerli <= 1'b0; asama2_gecerli <= 1'b0; asama3_gecerli <= 1'b0; cikis_gecerli <= 1'b0; kirpildi <= 1'b0; cikis_int8 <= 8'sd0;
        end else begin
            // A1
            asama1_gecerli <= giris_gecerli; asama1_yan_bilgi <= yan_bilgi_giris; asama1_kaydirma <= kaydirma; carpim_kayit <= carpim;
            // A2
            asama2_gecerli <= asama1_gecerli; asama2_yan_bilgi <= asama1_yan_bilgi; asama2_kaydirma <= asama1_kaydirma; yuvarlanmis <= carpim_kayit + ((asama1_kaydirma == 6'd0) ? 64'sd0 : (64'sd1 <<< (asama1_kaydirma - 6'd1)));
            // A3
            asama3_gecerli <= asama2_gecerli; asama3_yan_bilgi <= asama2_yan_bilgi; kaydirilmis <= yuvarlanmis >>> asama2_kaydirma;
            // A4
            cikis_gecerli <= asama3_gecerli; yan_bilgi_cikis <= asama3_yan_bilgi;
            kirpildi  <= asama3_gecerli && ((kaydirilmis > 64'sd127) || (kaydirilmis < -64'sd128));
            if (kaydirilmis > 64'sd127)       cikis_int8 <= 8'sd127;
            else if (kaydirilmis < -64'sd128) cikis_int8 <= -8'sd128;
            else                     cikis_int8 <= kaydirilmis[7:0];
        end
    end
endmodule
