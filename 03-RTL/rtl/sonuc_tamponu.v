// -----------------------------------------------------------------------------
// sonuc_tamponu.v -- Softmax/LayerNorm cikis akisini yakalayan bayt tamponu (G13)
// cikis_gecerli/cikis_veri/cikis_son akisi ardisik adreslere yazilir; temizle (birim start'i) isaretciyi ve hazir'i siler.
// Okuma senkron (1 cevrim gecikme): oku_veri, oku_adres'nin bir sonraki kenarda yakalanmis halidir.
// Dizi reset'siz ve tek yazma portlu yazildi -> dagitik RAM / BRAM cikarilabilir.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module sonuc_tamponu #(
    parameter DERINLIK = 64,
    parameter ADRES_GENISLIGI    = 6                  // DERIN = 2**AW
) (
    input  wire          clk,
    input  wire          rst,
    input  wire          temizle,
    input  wire          yaz_gecerli,
    input  wire [7:0]    yaz_veri,
    input  wire          yaz_son,
    output reg           hazir,          // son eleman yazildi (temizle'ye kadar 1)
    input  wire [ADRES_GENISLIGI-1:0] oku_adres,
    output reg  [7:0]    oku_veri
);
    reg [7:0]    bellek [0:DERINLIK-1];
    reg [ADRES_GENISLIGI-1:0] yazma_isaretcisi;

    always @(posedge clk) begin
        if (yaz_gecerli) bellek[yazma_isaretcisi] <= yaz_veri;
        oku_veri <= bellek[oku_adres];
    end

    always @(posedge clk) begin
        if (rst || temizle) begin
            yazma_isaretcisi <= {ADRES_GENISLIGI{1'b0}}; hazir <= 1'b0;
        end else if (yaz_gecerli) begin
            yazma_isaretcisi <= yazma_isaretcisi + 1'b1;
            if (yaz_son) hazir <= 1'b1;
        end
    end
endmodule
