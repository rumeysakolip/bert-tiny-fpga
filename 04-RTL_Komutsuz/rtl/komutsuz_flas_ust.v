// -----------------------------------------------------------------------------
// komutsuz_flas_ust.v -- bayt kaynagi olarak seri flas: qspi_okuyucu -> komutsuz_ust
//   Reset birakildiktan sonra okuyucu kendiliginden FLAS_ADRES'ten TOPLAM_BAYT bayt okur (komut yok; adres ve uzunluk sabit).
//   Prototipte flas akisi aktivasyon + agirlik bloklarinin hepsini tasir; gercek sistemde aktivasyon seri hattan gelir.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module komutsuz_flas_ust #(
    parameter BOL          = 2,
    parameter [23:0] FLAS_ADRES = 24'h000000,
    parameter [31:0] TOPLAM_BAYT = 32'd60514
) (
    input  wire         clk,
    input  wire         rst,
    // flas pinleri
    output wire         sck,
    output wire         cs_n,
    output wire         io0_o,
    input  wire [3:0]   io_i,
    // gozlem
    output wire         satir_bitti,
    input  wire         devam,
    input  wire [11:0]  cikis_oku_adres,
    output wire [63:0]  cikis_oku_veri,
    output wire         hata,
    output wire [3:0]   satir_no,
    output wire [15:0]  cumle_no,
    output wire [31:0]  hata_sayisi,
    output wire [31:0]  kabul_edilen_bayt,
    output wire [6:0]   cumle_uzunluk,
    output wire         tasma_hatasi,
    output wire         okuma_bitti
);
    wire        bayt_gecerli, bayt_hazir, mesgul;
    wire [7:0]  bayt_veri;
    reg         basla_p;
    reg         rst_d;
    always @(posedge clk) begin rst_d <= rst; basla_p <= rst_d & ~rst; end      // reset birakilinca 1 darbe

    qspi_okuyucu #(.BOL(BOL)) u_qspi (
        .clk(clk), .rst(rst), .basla(basla_p), .adres(FLAS_ADRES), .bayt_sayisi(TOPLAM_BAYT),
        .sck(sck), .cs_n(cs_n), .io0_o(io0_o), .io_i(io_i),
        .bayt_gecerli(bayt_gecerli), .bayt_veri(bayt_veri), .bayt_hazir(bayt_hazir), .mesgul(mesgul), .bitti(okuma_bitti));

    komutsuz_ust u_ust (
        .clk(clk), .rst(rst), .bayt_gecerli(bayt_gecerli), .bayt_veri(bayt_veri), .bayt_hazir(bayt_hazir),
        .satir_bitti(satir_bitti), .devam(devam), .cikis_oku_adres(cikis_oku_adres), .cikis_oku_veri(cikis_oku_veri),
        .hata(hata), .satir_no(satir_no), .cumle_no(cumle_no), .hata_sayisi(hata_sayisi), .kabul_edilen_bayt(kabul_edilen_bayt), .cumle_uzunluk(cumle_uzunluk),
        .tasma_hatasi(tasma_hatasi));
endmodule
