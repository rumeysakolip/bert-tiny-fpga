// -----------------------------------------------------------------------------
// komutsuz_ust.v -- komutsuz prototip ust modulu
//   bayt akisi -> akis_ayristirici (CRC-16) -> bellekler -> dogrusal_katman (mevcut hesap birimleri, degismedi)
//   cizelge_siralayici blok sirasini ve katman ayarlarini sabit tablodan verir.
// Disariya yalniz: bayt girisi (gecerli/hazir), gozlem kancasi (satir_bitti/devam, cikis okuma), hata.
// Bayt akisi kaynagi (seri hat ya da flas okuyucu) bu arabirimin arkasinda degistirilebilir.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module komutsuz_ust (
    input  wire         clk,
    input  wire         rst,
    input  wire         bayt_gecerli,
    input  wire [7:0]   bayt_veri,
    output wire         bayt_hazir,
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
    output wire         tasma_hatasi
);
    wire        blok_basla, blok_tur, blok_tampon, blok_tamam, blok_hatali;
    wire [10:0] blok_k;
    wire        ak_yaz_etkin; wire [11:0] ak_yaz_adres; wire [63:0] ak_yaz_veri;
    wire        pn_yaz_etkin, pn_yaz_tampon; wire [1:0] pn_yaz_secici; wire [10:0] pn_yaz_adres; wire [63:0] pn_yaz_veri;
    wire        calistir, gelu_etkin, katman_bitti, panel_bitti, panel_bitti_tampon, mesgul;
    wire [10:0] ayar_k; wire [6:0] ayar_panel_sayisi; wire [5:0] ayar_kaydirma; wire [1:0] panel_hazir;
    wire [31:0] kirpilan_sayisi;

    akis_ayristirici u_ayristirici (
        .clk(clk), .rst(rst), .bayt_gecerli(bayt_gecerli), .bayt_veri(bayt_veri), .bayt_hazir(bayt_hazir),
        .blok_basla(blok_basla), .blok_tur(blok_tur), .blok_tampon(blok_tampon), .blok_k(blok_k),
        .blok_tamam(blok_tamam), .blok_hatali(blok_hatali),
        .aktivasyon_yaz_etkin(ak_yaz_etkin), .aktivasyon_yaz_adres(ak_yaz_adres), .aktivasyon_yaz_veri(ak_yaz_veri),
        .panel_yaz_etkin(pn_yaz_etkin), .panel_yaz_tampon(pn_yaz_tampon), .panel_yaz_secici(pn_yaz_secici),
        .panel_yaz_adres(pn_yaz_adres), .panel_yaz_veri(pn_yaz_veri),
        .hata_sayisi(hata_sayisi), .kabul_edilen_bayt(kabul_edilen_bayt), .cumle_uzunluk(cumle_uzunluk));

    cizelge_siralayici u_cizelge (
        .clk(clk), .rst(rst),
        .blok_basla(blok_basla), .blok_tur(blok_tur), .blok_tampon(blok_tampon), .blok_k(blok_k),
        .blok_tamam(blok_tamam), .blok_hatali(blok_hatali),
        .calistir(calistir), .ayar_k(ayar_k), .ayar_panel_sayisi(ayar_panel_sayisi), .ayar_kaydirma(ayar_kaydirma), .gelu_etkin(gelu_etkin),
        .panel_hazir(panel_hazir), .panel_bitti(panel_bitti), .panel_bitti_tampon(panel_bitti_tampon), .katman_bitti(katman_bitti),
        .satir_bitti(satir_bitti), .devam(devam), .hata(hata), .satir_no(satir_no), .cumle_no(cumle_no));

    dogrusal_katman u_katman (
        .clk(clk), .rst(rst), .calistir(calistir), .ayar_k(ayar_k), .ayar_panel_sayisi(ayar_panel_sayisi), .ayar_blok_sayisi(4'd0),
        .ayar_kaydirma(ayar_kaydirma), .a_isaretsiz(1'b0), .gelu_etkin(gelu_etkin), .mesgul(mesgul), .katman_bitti(katman_bitti),
        .aktivasyon_yaz_etkin(ak_yaz_etkin), .aktivasyon_yaz_adres(ak_yaz_adres), .aktivasyon_yaz_veri(ak_yaz_veri),
        .panel_yaz_etkin(pn_yaz_etkin), .panel_yaz_tampon(pn_yaz_tampon), .panel_yaz_secici(pn_yaz_secici),
        .panel_yaz_adres(pn_yaz_adres), .panel_yaz_veri(pn_yaz_veri),
        .panel_hazir(panel_hazir), .panel_bitti(panel_bitti), .panel_bitti_tampon(panel_bitti_tampon),
        .gelu_yaz_etkin(1'b0), .gelu_yaz_adres(8'd0), .gelu_yaz_veri(8'd0),
        .cikis_oku_adres(cikis_oku_adres), .cikis_oku_veri(cikis_oku_veri), .tasma_hatasi(tasma_hatasi), .kirpilan_sayisi(kirpilan_sayisi));
endmodule
