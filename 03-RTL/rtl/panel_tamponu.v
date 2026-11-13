// -----------------------------------------------------------------------------
// panel_tamponu.v -- cift tamponlu agirlik paneli (host'tan akitilir) (G5)
//   Her tampon: W[K] (64 bit sozcuk: bayt j = kanal j), bias[8] INT32, olcek_m0[8] (31 bit).
//   Host bir tamponu yazarken denetleyici digerini okur (ping-pong).
//
// Yazma portu : panel_yaz_etkin, panel_yaz_tampon, panel_yaz_secici (0=W, 1=bias, 2=olcek_m0), panel_yaz_adres (W: k ; bias/olcek_m0: j), panel_yaz_veri[63:0]
// W okuma     : agirlik_oku_tampon, agirlik_oku_adres -> agirlik_oku_veri (KAYITLI, 1 cevrim gecikme; BRAM)
// bias/olcek_m0     : rbuf, rj -> rbias, sorgu_m0 (birlesik/anlik; 2x8 yazmac)
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module panel_tamponu #(
    parameter K_ENFAZLA = 512,
    parameter K_GENISLIGI   = 11
) (
    input  wire             clk,
    input  wire             panel_yaz_etkin,
    input  wire             panel_yaz_tampon,
    input  wire [1:0]       panel_yaz_secici,
    input  wire [K_GENISLIGI-1:0]    panel_yaz_adres,
    input  wire [63:0]      panel_yaz_veri,

    input  wire             agirlik_oku_tampon,
    input  wire [K_GENISLIGI-1:0]    agirlik_oku_adres,
    output reg  [63:0]      agirlik_oku_veri,

    input  wire             sorgu_tampon,
    input  wire [2:0]       sorgu_kanal,
    output wire [31:0]      sorgu_bias,
    output wire [30:0]      sorgu_m0
);
    // Agirlik tamponlari tek bellekte: adres = {tampon, k}; senkron okuma -> BRAM (eskiden 2 ayri dizi + okuma cogullayicisi, dagitik RAM idi)
    localparam K_ADRES_BITI = 9;                       // KMAX = 512 -> k 9 bit
    (* ram_style = "block" *) reg [63:0] agirlik [0:2*K_ENFAZLA-1];
    reg [31:0] bias_tampon0 [0:7];
    reg [31:0] bias_tampon1 [0:7];
    reg [30:0] m0_tampon0 [0:7];
    reg [30:0] m0_tampon1 [0:7];

    always @(posedge clk) begin
        if (panel_yaz_etkin && panel_yaz_secici == 2'd0) begin
            agirlik[{panel_yaz_tampon, panel_yaz_adres[K_ADRES_BITI-1:0]}] <= panel_yaz_veri;
        end
        if (panel_yaz_etkin && panel_yaz_secici == 2'd1) begin
            if (panel_yaz_tampon) bias_tampon1[panel_yaz_adres[2:0]] <= panel_yaz_veri[31:0]; else bias_tampon0[panel_yaz_adres[2:0]] <= panel_yaz_veri[31:0];
        end
        if (panel_yaz_etkin && panel_yaz_secici == 2'd2) begin
            if (panel_yaz_tampon) m0_tampon1[panel_yaz_adres[2:0]] <= panel_yaz_veri[30:0]; else m0_tampon0[panel_yaz_adres[2:0]] <= panel_yaz_veri[30:0];
        end
        agirlik_oku_veri <= agirlik[{agirlik_oku_tampon, agirlik_oku_adres[K_ADRES_BITI-1:0]}];
    end

    assign sorgu_bias = sorgu_tampon ? bias_tampon1[sorgu_kanal] : bias_tampon0[sorgu_kanal];
    assign sorgu_m0   = sorgu_tampon ? m0_tampon1[sorgu_kanal]   : m0_tampon0[sorgu_kanal];
endmodule
