// -----------------------------------------------------------------------------
// cikis_sozcuk_toplayici_devrik.v -- cikislari DEVRIK (transpoze) duzende sozcuklere toplar: dikkatte "olasilik x deger" icin
//   Normal toplayici: sozcuk (blok, kanal), bayt i = token 8*blok+i  (aktivasyon duzeni).
//   Bu toplayici   : sozcuk (panel, token), bayt j = kanal 8*panel+j  (panel duzeni: B operandi olarak dogrudan kullanilir).
//   Dizinin cikisi kanal j dis, token i ic dongude gelir; bir tile (8 token x 8 kanal) tamamlaninca 8 sozcuk yazilir.
//   Yazma adresi (goreli) = panel*64 + (blok*8 + token)   (64 token, panel basina 64 sozcuk)
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module cikis_sozcuk_toplayici_devrik #(
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
    output reg               yaz_etkin,
    output reg  [ADRES_GENISLIGI-1:0]     yaz_adres,
    output reg  [63:0]       yaz_veri
);
    reg [7:0] tampon [0:63];                         // [kanal*8 + token]
    reg       yaziyor;
    reg [2:0] yaz_token;
    reg [PANEL_GENISLIGI-1:0] panel_k;
    reg [3:0] blok_k;
    always @(posedge clk) begin
        yaz_etkin <= 1'b0;
        if (rst) yaziyor <= 1'b0;
        else begin
            if (gecerli) begin
                tampon[{kanal_sirasi, token_sirasi}] <= veri_int8;
                if (kanal_sirasi == 3'd7 && token_sirasi == 3'd7) begin yaziyor <= 1'b1; yaz_token <= 3'd0; panel_k <= panel_no; blok_k <= blok_no; end
            end
            if (yaziyor) begin
                yaz_etkin <= 1'b1;
                yaz_adres <= panel_k * 64 + blok_k * 8 + yaz_token;
                yaz_veri <= {tampon[{3'd7, yaz_token}], tampon[{3'd6, yaz_token}], tampon[{3'd5, yaz_token}], tampon[{3'd4, yaz_token}],
                             tampon[{3'd3, yaz_token}], tampon[{3'd2, yaz_token}], tampon[{3'd1, yaz_token}], tampon[{3'd0, yaz_token}]};
                if (yaz_token == 3'd7) yaziyor <= 1'b0; else yaz_token <= yaz_token + 3'd1;
            end
        end
    end
endmodule
