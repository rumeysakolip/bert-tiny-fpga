// -----------------------------------------------------------------------------
// cikis_sozcuk_toplayici.v -- INT8 cikislari 64 bit sozcuge toplar ve cikis BRAM'ine yazar (G6/G7)
// Giris sirasi: kanal j dis dongu, token i ic dongu (i=0..7 ardisik). Sozcuk (blk, kanal c):
//   bayt i = Y[blk*8+i][c]   -> sonraki katmanin aktivasyon duzeniyle AYNI (b*K' + k, K'=C).
// Yazma adresi = blk*C + panel*8 + j  (C = 8*np).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module cikis_sozcuk_toplayici #(
    parameter ADRES_GENISLIGI = 12,
    parameter PANEL_GENISLIGI = 7
) (
    input  wire              clk,
    input  wire              rst,
    input  wire              gecerli,
    input  wire signed [7:0] veri_int8,
    input  wire [2:0]        token_sirasi,
    input  wire [2:0]        kanal_sirasi,
    input  wire [3:0]        blok_no,
    input  wire [PANEL_GENISLIGI-1:0]     panel_no,
    input  wire [9:0]        kanal_toplami,       // C = 8*np
    output reg               yaz_etkin,
    output reg  [ADRES_GENISLIGI-1:0]     yaz_adres,
    output reg  [63:0]       yaz_veri
);
    reg [55:0] ust_baytlar;                           // i=0..6 baytlari
    always @(posedge clk) begin
        if (rst) begin
            yaz_etkin <= 1'b0; ust_baytlar <= 56'd0;
        end else begin
            yaz_etkin <= 1'b0;
            if (gecerli) begin
                if (token_sirasi == 3'd7) begin
                    yaz_etkin    <= 1'b1;
                    yaz_veri <= {veri_int8, ust_baytlar};
                    yaz_adres <= blok_no * kanal_toplami + {panel_no, 3'b000} + kanal_sirasi;
                end else begin
                    ust_baytlar[token_sirasi*8 +: 8] <= veri_int8;
                end
            end
        end
    end
endmodule
