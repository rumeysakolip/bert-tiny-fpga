// -----------------------------------------------------------------------------
// bert_tiny_ust.v -- bayt akisi arayuzlu tam sistem: veri yolu + komut cozucu + kontrol birimi
//
//   rx bayt akisi --> veri_yolu (gelen bayt yazmaci, komut/uzunluk/baslik yazmaclari, bellekler, islem birimleri) --> tx bayt akisi
//   veri_yolu.komut_yazmaci / baslik --> komut_cozucu --> komut hatlari --> kontrol_birimi  (kontrol sinyalleri)
//                                                    \--> alan_* veri alanlari --> veri_yolu (yazmaclara)
//   kontrol_birimi --> veri_yolu (yazma, yukleme, birim darbeleri)
// UART'siz test icin dogrudan bayt portlari vardir; kart icin bert_tiny_uart_ust UART'a sarar.
// Dogrusal katman <-> Softmax/LayerNorm arasinda ic zincirleme YOK: veri host uzerinden tasinir (bkz. TOP_NOTLARI.md).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module bert_tiny_ust (
    input  wire        clk,
    input  wire        rst,
    input  wire        rx_valid,
    input  wire [7:0]  rx_data,
    output wire        tx_valid,
    output wire [7:0]  tx_data,
    input  wire        tx_ready,
    output wire        tx_bos,
    output wire [15:0] paket_sayisi,
    output wire [15:0] hata_sayisi
);
    // ---- veri yolu <-> komut cozucu ----
    wire [7:0]  komut_yazmaci;
    wire [79:0] baslik_yazmaci;
    wire [15:0] yuk_uzunlugu;
    wire [3:0]  sozcuk_bayt_sirasi;
    wire [3:0]  baslik_bayt_sayisi, sozcuk_bayt_sayisi;
    wire        komut_gecerli, sekil_gecerli, sozcuk_komutu;
    wire        komut_ayar, komut_aktivasyon_yukle, komut_panel_yukle, komut_calistir, komut_aktivasyon_oku, komut_durum, komut_panel_hazir;
    wire        komut_softmax_tablo, komut_softmax_ayar, komut_softmax_baslat, komut_softmax_veri, komut_softmax_oku;
    wire        komut_layernorm_parametre, komut_layernorm_ayar, komut_layernorm_baslat, komut_layernorm_veri, komut_layernorm_oku;
    wire [10:0] alan_ayar_k;  wire [6:0] alan_ayar_panel_sayisi;  wire [5:0] alan_ayar_kaydirma;  wire [3:0] alan_ayar_blok_sayisi;
    wire        alan_a_isaretsiz, alan_gelu_etkin, alan_panel_tampon, alan_panel_gelu_tablosu;
    wire [1:0]  alan_panel_secici;
    wire [23:0] alan_softmax_m0;  wire [39:0] alan_layernorm_epsilon;  wire [30:0] alan_layernorm_m0;  wire [5:0] alan_layernorm_kaydirma;
    wire [11:0] alan_okuma_adresi;  wire [15:0] alan_okuma_adedi, alan_okuma_uzunlugu;
    // ---- veri yolu <-> kontrol birimi ----
    wire        bayt_geldi, uzunluk_alt_sifir, gelen_bayt_sifir, baslik_bolgesinde, baslik_son_bayt, sozcuk_son_bayt, yuk_son_bayt, crc_dogru;
    wire        tx_musait, yanit_uzunluk_sifir, yanit_adet_sifir, yanit_bayt_son, yanit_sozcuk_bayt_son, yanit_son_sozcuk;
    wire [1:0]  yanit_turu;
    wire        komut_yukle, crc_baslat, crc_guncelle, uzunluk_alt_yukle, uzunluk_ust_yukle, sayac_sifirla, sayac_artir, baslik_yaz, adres_yakala;
    wire        sozcuk_topla, sozcuk_yaz, paket_say, hata_say;
    wire        uygula_ayar, uygula_calistir_temizle, uygula_panel_hazir, uygula_softmax_ayar, uygula_layernorm_ayar, uygula_akis_hatasi_temizle;
    wire        yanit_ack_yukle, yanit_hata_yukle;
    wire [7:0]  yanit_hata_kodu;
    wire        calistir_darbesi, softmax_iptal, softmax_baslat, layernorm_iptal, layernorm_baslat;
    wire        yanit_aktif, yanit_istegi, yanit_yukle, yanit_bayt_sun, yanit_crc_baslat, yanit_crc_guncelle, yanit_sayac_artir;
    wire        okuma_adres_ilk, okuma_adres_sonraki, yanit_sozcuk_yukle, yanit_sozcuk_kaydir, yanit_sozcuk_sayaci_artir;
    wire [2:0]  yanit_bayt_secici;

    // verici bos: bekleyen yanit yok, yanit uretilmiyor, verici yazmaci bos
    assign tx_bos = !yanit_aktif && !yanit_istegi && !tx_valid;

    veri_yolu u_veri_yolu (.clk(clk), .rst(rst),
        .rx_gecerli(rx_valid), .rx_veri(rx_data), .tx_gecerli(tx_valid), .tx_veri(tx_data), .tx_hazir(tx_ready),
        .komut_yazmaci(komut_yazmaci), .baslik_yazmaci_cikis(baslik_yazmaci), .yuk_uzunlugu(yuk_uzunlugu), .sozcuk_bayt_sirasi_cikis(sozcuk_bayt_sirasi),
        .baslik_bayt_sayisi(baslik_bayt_sayisi), .sozcuk_bayt_sayisi(sozcuk_bayt_sayisi),
        .komut_aktivasyon_yukle(komut_aktivasyon_yukle), .komut_panel_yukle(komut_panel_yukle), .komut_aktivasyon_oku(komut_aktivasyon_oku),
        .komut_durum(komut_durum), .komut_softmax_tablo(komut_softmax_tablo), .komut_softmax_veri(komut_softmax_veri),
        .komut_softmax_oku(komut_softmax_oku), .komut_layernorm_parametre(komut_layernorm_parametre),
        .komut_layernorm_veri(komut_layernorm_veri), .komut_layernorm_oku(komut_layernorm_oku),
        .alan_ayar_k(alan_ayar_k), .alan_ayar_panel_sayisi(alan_ayar_panel_sayisi), .alan_ayar_kaydirma(alan_ayar_kaydirma),
        .alan_ayar_blok_sayisi(alan_ayar_blok_sayisi), .alan_a_isaretsiz(alan_a_isaretsiz), .alan_gelu_etkin(alan_gelu_etkin),
        .alan_panel_tampon(alan_panel_tampon), .alan_panel_gelu_tablosu(alan_panel_gelu_tablosu), .alan_panel_secici(alan_panel_secici),
        .alan_softmax_m0(alan_softmax_m0), .alan_layernorm_epsilon(alan_layernorm_epsilon), .alan_layernorm_m0(alan_layernorm_m0),
        .alan_layernorm_kaydirma(alan_layernorm_kaydirma), .alan_okuma_adresi(alan_okuma_adresi), .alan_okuma_adedi(alan_okuma_adedi),
        .alan_okuma_uzunlugu(alan_okuma_uzunlugu),
        .bayt_geldi(bayt_geldi), .uzunluk_alt_sifir(uzunluk_alt_sifir), .gelen_bayt_sifir(gelen_bayt_sifir), .baslik_bolgesinde(baslik_bolgesinde),
        .baslik_son_bayt(baslik_son_bayt), .sozcuk_son_bayt(sozcuk_son_bayt), .yuk_son_bayt(yuk_son_bayt), .crc_dogru(crc_dogru),
        .tx_musait(tx_musait), .yanit_turu(yanit_turu), .yanit_uzunluk_sifir(yanit_uzunluk_sifir), .yanit_adet_sifir(yanit_adet_sifir),
        .yanit_bayt_son(yanit_bayt_son), .yanit_sozcuk_bayt_son(yanit_sozcuk_bayt_son), .yanit_son_sozcuk(yanit_son_sozcuk),
        .komut_yukle(komut_yukle), .crc_baslat(crc_baslat), .crc_guncelle(crc_guncelle), .uzunluk_alt_yukle(uzunluk_alt_yukle),
        .uzunluk_ust_yukle(uzunluk_ust_yukle), .sayac_sifirla(sayac_sifirla), .sayac_artir(sayac_artir), .baslik_yaz(baslik_yaz),
        .adres_yakala(adres_yakala), .sozcuk_topla(sozcuk_topla), .sozcuk_yaz(sozcuk_yaz), .paket_say(paket_say), .hata_say(hata_say),
        .uygula_ayar(uygula_ayar), .uygula_calistir_temizle(uygula_calistir_temizle), .uygula_panel_hazir(uygula_panel_hazir),
        .uygula_softmax_ayar(uygula_softmax_ayar), .uygula_layernorm_ayar(uygula_layernorm_ayar),
        .uygula_akis_hatasi_temizle(uygula_akis_hatasi_temizle), .yanit_ack_yukle(yanit_ack_yukle), .yanit_hata_yukle(yanit_hata_yukle),
        .yanit_hata_kodu(yanit_hata_kodu),
        .calistir_darbesi(calistir_darbesi), .softmax_iptal(softmax_iptal), .softmax_baslat(softmax_baslat),
        .layernorm_iptal(layernorm_iptal), .layernorm_baslat(layernorm_baslat),
        .yanit_yukle(yanit_yukle), .yanit_bayt_sun(yanit_bayt_sun), .yanit_bayt_secici(yanit_bayt_secici), .yanit_crc_baslat(yanit_crc_baslat),
        .yanit_crc_guncelle(yanit_crc_guncelle), .yanit_sayac_artir(yanit_sayac_artir), .okuma_adres_ilk(okuma_adres_ilk),
        .okuma_adres_sonraki(okuma_adres_sonraki), .yanit_sozcuk_yukle(yanit_sozcuk_yukle), .yanit_sozcuk_kaydir(yanit_sozcuk_kaydir),
        .yanit_sozcuk_sayaci_artir(yanit_sozcuk_sayaci_artir),
        .paket_sayisi(paket_sayisi), .hata_sayisi(hata_sayisi));

    komut_cozucu u_komut_cozucu (.clk(clk),
        .komut_yazmaci(komut_yazmaci), .baslik_yazmaci(baslik_yazmaci), .yuk_uzunlugu(yuk_uzunlugu), .sozcuk_bayt_sirasi(sozcuk_bayt_sirasi),
        .komut_gecerli_kayit(komut_gecerli), .sekil_gecerli_kayit(sekil_gecerli),
        .komut_ayar(komut_ayar), .komut_aktivasyon_yukle(komut_aktivasyon_yukle), .komut_panel_yukle(komut_panel_yukle),
        .komut_calistir(komut_calistir), .komut_aktivasyon_oku(komut_aktivasyon_oku), .komut_durum(komut_durum), .komut_panel_hazir(komut_panel_hazir),
        .komut_softmax_tablo(komut_softmax_tablo), .komut_softmax_ayar(komut_softmax_ayar), .komut_softmax_baslat(komut_softmax_baslat),
        .komut_softmax_veri(komut_softmax_veri), .komut_softmax_oku(komut_softmax_oku),
        .komut_layernorm_parametre(komut_layernorm_parametre), .komut_layernorm_ayar(komut_layernorm_ayar),
        .komut_layernorm_baslat(komut_layernorm_baslat), .komut_layernorm_veri(komut_layernorm_veri), .komut_layernorm_oku(komut_layernorm_oku),
        .sozcuk_komutu(sozcuk_komutu), .baslik_bayt_sayisi(baslik_bayt_sayisi), .sozcuk_bayt_sayisi(sozcuk_bayt_sayisi),
        .alan_ayar_k(alan_ayar_k), .alan_ayar_panel_sayisi(alan_ayar_panel_sayisi), .alan_ayar_kaydirma(alan_ayar_kaydirma),
        .alan_ayar_blok_sayisi(alan_ayar_blok_sayisi), .alan_a_isaretsiz(alan_a_isaretsiz), .alan_gelu_etkin(alan_gelu_etkin),
        .alan_panel_tampon(alan_panel_tampon), .alan_panel_secici(alan_panel_secici), .alan_panel_gelu_tablosu(alan_panel_gelu_tablosu),
        .alan_softmax_m0(alan_softmax_m0), .alan_layernorm_epsilon(alan_layernorm_epsilon), .alan_layernorm_m0(alan_layernorm_m0),
        .alan_layernorm_kaydirma(alan_layernorm_kaydirma), .alan_okuma_adresi(alan_okuma_adresi), .alan_okuma_adedi(alan_okuma_adedi),
        .alan_okuma_uzunlugu(alan_okuma_uzunlugu));

    kontrol_birimi u_kontrol_birimi (.clk(clk), .rst(rst),
        .bayt_geldi(bayt_geldi), .uzunluk_alt_sifir(uzunluk_alt_sifir), .gelen_bayt_sifir(gelen_bayt_sifir), .baslik_bolgesinde(baslik_bolgesinde),
        .baslik_son_bayt(baslik_son_bayt), .sozcuk_son_bayt(sozcuk_son_bayt), .yuk_son_bayt(yuk_son_bayt), .crc_dogru(crc_dogru),
        .komut_gecerli(komut_gecerli), .sekil_gecerli(sekil_gecerli), .sozcuk_komutu(sozcuk_komutu), .komut_ayar(komut_ayar),
        .komut_calistir(komut_calistir), .komut_panel_hazir(komut_panel_hazir), .komut_softmax_ayar(komut_softmax_ayar),
        .komut_softmax_baslat(komut_softmax_baslat), .komut_layernorm_ayar(komut_layernorm_ayar), .komut_layernorm_baslat(komut_layernorm_baslat),
        .tx_musait(tx_musait), .yanit_turu(yanit_turu), .yanit_uzunluk_sifir(yanit_uzunluk_sifir), .yanit_adet_sifir(yanit_adet_sifir),
        .yanit_bayt_son(yanit_bayt_son), .yanit_sozcuk_bayt_son(yanit_sozcuk_bayt_son), .yanit_son_sozcuk(yanit_son_sozcuk),
        .komut_yukle(komut_yukle), .crc_baslat(crc_baslat), .crc_guncelle(crc_guncelle), .uzunluk_alt_yukle(uzunluk_alt_yukle),
        .uzunluk_ust_yukle(uzunluk_ust_yukle), .sayac_sifirla(sayac_sifirla), .sayac_artir(sayac_artir), .baslik_yaz(baslik_yaz),
        .adres_yakala(adres_yakala), .sozcuk_topla(sozcuk_topla), .sozcuk_yaz(sozcuk_yaz), .paket_say(paket_say), .hata_say(hata_say),
        .uygula_ayar(uygula_ayar), .uygula_calistir_temizle(uygula_calistir_temizle), .uygula_panel_hazir(uygula_panel_hazir),
        .uygula_softmax_ayar(uygula_softmax_ayar), .uygula_layernorm_ayar(uygula_layernorm_ayar),
        .uygula_akis_hatasi_temizle(uygula_akis_hatasi_temizle), .yanit_ack_yukle(yanit_ack_yukle), .yanit_hata_yukle(yanit_hata_yukle),
        .yanit_hata_kodu(yanit_hata_kodu),
        .calistir_darbesi(calistir_darbesi), .softmax_iptal(softmax_iptal), .softmax_baslat(softmax_baslat),
        .layernorm_iptal(layernorm_iptal), .layernorm_baslat(layernorm_baslat),
        .yanit_aktif(yanit_aktif), .yanit_istegi(yanit_istegi), .yanit_yukle(yanit_yukle), .yanit_bayt_sun(yanit_bayt_sun),
        .yanit_bayt_secici(yanit_bayt_secici), .yanit_crc_baslat(yanit_crc_baslat), .yanit_crc_guncelle(yanit_crc_guncelle),
        .yanit_sayac_artir(yanit_sayac_artir), .okuma_adres_ilk(okuma_adres_ilk), .okuma_adres_sonraki(okuma_adres_sonraki),
        .yanit_sozcuk_yukle(yanit_sozcuk_yukle), .yanit_sozcuk_kaydir(yanit_sozcuk_kaydir),
        .yanit_sozcuk_sayaci_artir(yanit_sozcuk_sayaci_artir));
endmodule
