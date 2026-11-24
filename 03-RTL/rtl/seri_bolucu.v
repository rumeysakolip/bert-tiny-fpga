// -----------------------------------------------------------------------------
// seri_bolucu.v -- isaretsiz ardisik (restoring) bolucu: W bit / W bit, 1 bit/cevrim (G11)
// start (1 cevrim) ile num/den alinir; W cevrim sonra done=1 (1 cevrim), quo/rem tutulur.
// den = 0 verilmez (cagiran garanti eder).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module seri_bolucu #(
    parameter GENISLIK = 32
) (
    input  wire         clk,
    input  wire         rst,
    input  wire         baslat,
    input  wire [GENISLIK-1:0] bolunen,
    input  wire [GENISLIK-1:0] bolen,
    output reg          mesgul,
    output reg          bitti,
    output reg  [GENISLIK-1:0] bolum,
    output reg  [GENISLIK-1:0] kalan
);
    reg [GENISLIK-1:0] bolunen_kaydirilan;        // bolunen, soldan bit cikar
    reg [GENISLIK-1:0] bolen_kayit;
    reg [GENISLIK:0]   kismi_kalan;
    reg [7:0]   adim_sayaci;

    wire [GENISLIK:0] kismi_kalan_kaydirilmis  = {kismi_kalan[GENISLIK-1:0], bolunen_kaydirilan[GENISLIK-1]};
    wire       bolunebilir     = (kismi_kalan_kaydirilmis >= {1'b0, bolen_kayit});
    wire [GENISLIK:0] kismi_kalan_yeni = bolunebilir ? (kismi_kalan_kaydirilmis - {1'b0, bolen_kayit}) : kismi_kalan_kaydirilmis;

    always @(posedge clk) begin
        if (rst) begin
            mesgul <= 1'b0; bitti <= 1'b0; bolum <= {GENISLIK{1'b0}}; kalan <= {GENISLIK{1'b0}};
            bolunen_kaydirilan <= {GENISLIK{1'b0}}; bolen_kayit <= {GENISLIK{1'b0}}; kismi_kalan <= {(GENISLIK+1){1'b0}}; adim_sayaci <= 8'd0;
        end else begin
            bitti <= 1'b0;
            if (baslat && !mesgul) begin
                mesgul <= 1'b1; bolunen_kaydirilan <= bolunen; bolen_kayit <= bolen; kismi_kalan <= {(GENISLIK+1){1'b0}}; bolum <= {GENISLIK{1'b0}}; adim_sayaci <= 8'd0;
            end else if (mesgul) begin
                kismi_kalan    <= kismi_kalan_yeni;
                bolunen_kaydirilan <= {bolunen_kaydirilan[GENISLIK-2:0], 1'b0};
                bolum  <= {bolum[GENISLIK-2:0], bolunebilir};
                adim_sayaci  <= adim_sayaci + 8'd1;
                if (adim_sayaci == GENISLIK - 1) begin
                    mesgul <= 1'b0; bitti <= 1'b1;
                    kalan  <= kismi_kalan_yeni[GENISLIK-1:0];
                    bolum  <= {bolum[GENISLIK-2:0], bolunebilir};
                end
            end
        end
    end
endmodule
