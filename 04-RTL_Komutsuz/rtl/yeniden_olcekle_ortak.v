// -----------------------------------------------------------------------------
// yeniden_olcekle_ortak.v -- INT32 birikec -> 8 bit ya da 32 bit, TEK carpma devresi iki kullanim icin
//   y = kirp( (acc * M0 + 2^(n-1)) >>> n )     (n=0: yuvarlama sabiti 0)
//   genis = 0 : kirpma [-128, 127]      (dogrusal katman cikisi; 03-RTL/yeniden_olcekle ile ayni sonuc)
//   genis = 1 : kirpma [-2^31, 2^31-1]  (dikkat skoru; altin modelde skor_q yeniden olceklemesi)
//   Carpma devresi (DSP) ikisi icin ortaktir: ek carpma blogu harcanmaz.
//   Boru hatti ve yan bilgi esit gecikmeli: 4 asama, cevrimde bir eleman.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module yeniden_olcekle_ortak #(
    parameter META_W = 18
) (
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  genis,              // 0: 8 bit kirpma, 1: 32 bit kirpma (giris ile birlikte gecerli)
    input  wire                  giris_gecerli,
    input  wire signed [31:0]    birikec,
    input  wire [30:0]           olcek_m0,
    input  wire [5:0]            kaydirma,
    input  wire [META_W-1:0]     yan_bilgi_giris,
    output reg                   cikis_gecerli,
    output reg  signed [31:0]    cikis_veri,
    output reg  [META_W-1:0]     yan_bilgi_cikis,
    output reg                   kirpildi
);
    reg                 asama1_gecerli, asama2_gecerli, asama3_gecerli;
    reg [META_W-1:0]    asama1_yan_bilgi, asama2_yan_bilgi, asama3_yan_bilgi;
    reg [5:0]           asama1_kaydirma, asama2_kaydirma;
    reg                 asama1_genis, asama2_genis, asama3_genis;
    reg signed [63:0]   carpim_kayit, yuvarlanmis, kaydirilmis;

    wire signed [63:0] carpim = birikec * $signed({33'd0, olcek_m0});

    wire signed [63:0] ust = asama3_genis ? 64'sd2147483647 : 64'sd127;
    wire signed [63:0] alt = asama3_genis ? -64'sd2147483648 : -64'sd128;

    always @(posedge clk) begin
        if (rst) begin
            asama1_gecerli <= 1'b0; asama2_gecerli <= 1'b0; asama3_gecerli <= 1'b0; cikis_gecerli <= 1'b0; kirpildi <= 1'b0; cikis_veri <= 32'sd0;
        end else begin
            // A1: carpma
            asama1_gecerli <= giris_gecerli; asama1_yan_bilgi <= yan_bilgi_giris; asama1_kaydirma <= kaydirma; asama1_genis <= genis; carpim_kayit <= carpim;
            // A2: yuvarlama sabiti
            asama2_gecerli <= asama1_gecerli; asama2_yan_bilgi <= asama1_yan_bilgi; asama2_kaydirma <= asama1_kaydirma; asama2_genis <= asama1_genis;
            yuvarlanmis <= carpim_kayit + ((asama1_kaydirma == 6'd0) ? 64'sd0 : (64'sd1 <<< (asama1_kaydirma - 6'd1)));
            // A3: kaydirma
            asama3_gecerli <= asama2_gecerli; asama3_yan_bilgi <= asama2_yan_bilgi; asama3_genis <= asama2_genis; kaydirilmis <= yuvarlanmis >>> asama2_kaydirma;
            // A4: kirpma
            cikis_gecerli <= asama3_gecerli; yan_bilgi_cikis <= asama3_yan_bilgi;
            kirpildi <= asama3_gecerli && ((kaydirilmis > ust) || (kaydirilmis < alt));
            if (kaydirilmis > ust)      cikis_veri <= ust[31:0];
            else if (kaydirilmis < alt) cikis_veri <= alt[31:0];
            else                        cikis_veri <= kaydirilmis[31:0];
        end
    end
endmodule
