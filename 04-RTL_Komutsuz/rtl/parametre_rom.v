// -----------------------------------------------------------------------------
// parametre_rom.v -- sabit parametreler: sapma ve olcek carpani M0, TEK birlesik baslangic degerli bellek
//   Her giris 46 bit: {sapma (16 bit isaretli), M0 (30 bit)}. Modelin gercek degerleri bu genisliklere sigar
//   (en buyuk |sapma| 17 268 < 2^15, en buyuk M0 946 046 310 < 2^30); bu yuzden iki ayri 32 bitlik bellek yerine
//   tek 46 bitlik bellek kullanilir (blok bellek tasarrufu). Uretici (uret_parametre_rom.py) sigmayan deger olursa durur.
//   Icerik katman sirasiyla ardisik kanallardir (parametre_harita.vh: katman_taban). Okuma senkron (1 cevrim).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module parametre_rom #(
    parameter DOSYA = "param_birlesik.mem",
    parameter N     = 2440,
    parameter AW    = 12
) (
    input  wire          clk,
    input  wire [AW-1:0] adres,
    output wire [31:0]   bias,        // 32 bite isaretle genisletilmis
    output wire [31:0]   m0
);
    (* ram_style = "block" *) reg [45:0] bellek [0:N-1];
    initial $readmemh(DOSYA, bellek);
    reg [45:0] okunan;
    always @(posedge clk) okunan <= bellek[adres];
    assign bias = {{16{okunan[45]}}, okunan[45:30]};
    assign m0   = {2'b00, okunan[29:0]};
endmodule
