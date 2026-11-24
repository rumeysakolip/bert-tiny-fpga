// -----------------------------------------------------------------------------
// panel_parametre_yukleyici.v -- bir panelin sekiz sapmasini ve sekiz olcek carpanini gomulu bellekten panel tamponuna yazar
//   basla darbesiyle: kanal j = 0..7 icin parametre_rom[taban + j] okunur; panel tamponuna secici 1 (sapma) ve 2 (olcek carpani) yazilir.
//   Panel tamponu ve cizelge degismez: akistaki panel yalniz agirlik tasir.
//   Sure: kanal basina 4 cevrim -> panel basina 32 cevrim + 2.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module panel_parametre_yukleyici #(
    parameter AW = 12,
    parameter K_GENISLIGI = 11
) (
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   basla,                 // 1 cevrim darbe
    input  wire [AW-1:0]          taban,                 // panelin ilk kanalinin genel parametre indeksi
    input  wire                   tampon,
    // parametre_rom
    output reg  [AW-1:0]          rom_adres,
    input  wire [31:0]            rom_bias,
    input  wire [31:0]            rom_m0,
    // panel tamponu yazma
    output reg                    panel_yaz_etkin,
    output reg                    panel_yaz_tampon,
    output reg  [1:0]             panel_yaz_secici,
    output reg  [K_GENISLIGI-1:0] panel_yaz_adres,
    output reg  [63:0]            panel_yaz_veri,
    output wire                   mesgul,
    output reg                    bitti
);
    localparam S_BOS = 3'd0, S_ADRES = 3'd1, S_BEKLE = 3'd2, S_BIAS = 3'd3, S_M0 = 3'd4;
    reg [2:0] durum;
    reg [3:0] j;
    reg [AW-1:0] taban_k;
    reg tampon_k;
    assign mesgul = (durum != S_BOS);

    always @(posedge clk) begin
        panel_yaz_etkin <= 1'b0;
        bitti <= 1'b0;
        if (rst) begin
            durum <= S_BOS; j <= 4'd0; rom_adres <= 0;
        end else begin
            case (durum)
                S_BOS: if (basla) begin taban_k <= taban; tampon_k <= tampon; j <= 4'd0; durum <= S_ADRES; end
                S_ADRES: begin rom_adres <= taban_k + j; durum <= S_BEKLE; end
                S_BEKLE: durum <= S_BIAS;                              // senkron okuma: veri bir cevrim sonra hazir
                S_BIAS: begin
                    panel_yaz_etkin <= 1'b1; panel_yaz_tampon <= tampon_k; panel_yaz_secici <= 2'd1;
                    panel_yaz_adres <= {{(K_GENISLIGI-4){1'b0}}, j}; panel_yaz_veri <= {32'h0, rom_bias};
                    durum <= S_M0;
                end
                S_M0: begin
                    panel_yaz_etkin <= 1'b1; panel_yaz_tampon <= tampon_k; panel_yaz_secici <= 2'd2;
                    panel_yaz_adres <= {{(K_GENISLIGI-4){1'b0}}, j}; panel_yaz_veri <= {32'h0, rom_m0};
                    if (j == 4'd7) begin durum <= S_BOS; bitti <= 1'b1; end
                    else begin j <= j + 4'd1; durum <= S_ADRES; end
                end
                default: durum <= S_BOS;
            endcase
        end
    end
endmodule
