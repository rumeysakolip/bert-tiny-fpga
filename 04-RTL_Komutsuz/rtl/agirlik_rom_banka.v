// -----------------------------------------------------------------------------
// agirlik_rom_banka.v -- yonga ici agirlik bellegi (bir banka): 64 bit sozcuk, senkron okuma (1 cevrim), baslangic degeri dosyadan
//   Buyuk FPGA senaryosunda model agirliklari (INT8, ~420 KB) yonga ici blok bellekte durur; acilista flastan yuklendigi varsayilir.
//   NA paralel dizinin her biri kendi bankasindan okur: banka i, her satirin i, i+NA, i+2NA ... numarali panellerini tutar
//   (scripts/uret_agirlik_rom.py ile uretilir).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module agirlik_rom_banka #(
    parameter DOSYA = "agirlik_rom_b0.mem",
    parameter D     = 8192,
    parameter AW    = 16
) (
    input  wire          clk,
    input  wire [AW-1:0] adres,
    output reg  [63:0]   veri
);
    (* ram_style = "block" *) reg [63:0] bellek [0:D-1];
    initial $readmemh(DOSYA, bellek);
    always @(posedge clk) veri <= bellek[adres];
endmodule
