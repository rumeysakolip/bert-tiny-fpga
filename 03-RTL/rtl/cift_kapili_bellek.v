// -----------------------------------------------------------------------------
// cift_kapili_bellek.v -- basit cift-kapili (1 yazma, 1 okuma) senkron bellek; okuma KAYITLI (1 cevrim gecikme).
// Vivado'da block RAM olarak cikarilir (ayri okuma adresi, yazma-oncesi okuma davranisi).
// Aktivasyon BRAM'i icin kullanilir: sozcuk = 8 token bayti (bayt i = token i).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module cift_kapili_bellek #(
    parameter ADRES_GENISLIGI = 12,
    parameter VERI_GENISLIGI = 64
) (
    input  wire             clk,
    input  wire             yaz_etkin,
    input  wire [ADRES_GENISLIGI-1:0]    yaz_adres,
    input  wire [VERI_GENISLIGI-1:0]    yaz_veri,
    input  wire [ADRES_GENISLIGI-1:0]    oku_adres,
    output reg  [VERI_GENISLIGI-1:0]    oku_veri
);
    reg [VERI_GENISLIGI-1:0] bellek [0:(1<<ADRES_GENISLIGI)-1];

    always @(posedge clk) begin
        if (yaz_etkin) bellek[yaz_adres] <= yaz_veri;
        oku_veri <= bellek[oku_adres];
    end
endmodule
