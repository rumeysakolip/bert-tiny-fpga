// -----------------------------------------------------------------------------
// ortak_ust.v -- komutsuz hizlandirici ust modulu: bayt akisi -> akis ayristirici (CRC-16) -> cizelge -> ortak cekirdek
//   Disaridan yalniz bayt akisi gelir; komut yoktur. Gozlem icin bellek okuma kapisi ve satir sonu bekletmesi vardir.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module ortak_ust #(
    parameter KATMAN_ISLEM = 1,
    parameter SINIFLANDIR  = 1,
    parameter HIZLI_OLCUM  = 0,                   // 1: yalniz sure olcumu (panel akisi beklenmez, sonuclar anlamsiz); 0: normal
    parameter DOLGU_ATLA   = 1,                   // 1: cumlenin gercek blok sayisi kadar hesap (nb = ceil(token/8)); 0: her zaman 8 blok (eski davranis)
    parameter NA           = 1,                   // paralel dogrusal hat sayisi (1, 2, 4, 8)
    parameter AGIRLIK_ROM  = 0,                   // 1: agirliklar yonga ici bankalardan (bayt akisinda yalniz aktivasyon blogu); NA>1 icin zorunlu
    parameter ROM_D        = 8192                 // agirlik bankasi derinligi
) (
    input  wire         clk,
    input  wire         rst,
    input  wire         bayt_gecerli,
    input  wire [7:0]   bayt_veri,
    output wire         bayt_hazir,
    // gozlem
    input  wire         gozlem,
    input  wire         devam,
    output wire         satir_bitti,
    input  wire [12:0]  oku_adres,
    output wire [63:0]  oku_veri,
    // durum
    output wire         hata,
    output wire [3:0]   satir_no,
    output wire [3:0]   katman_no,
    output wire [15:0]  cumle_no,
    output wire         cumle_bitti,
    output wire         sinif,
    output wire         sonuc_gecerli,
    output wire signed [7:0] logit0,
    output wire signed [7:0] logit1,
    output wire [31:0]  hata_sayisi,
    output wire [31:0]  kabul_edilen_bayt,
    output wire [6:0]   cumle_uzunluk,
    output wire         tasma_hatasi,
    output wire         skor_tasma,
    output wire         ln_tasma,
    output wire         bellek_catisma,
    output wire [31:0]  kirpilan_sayisi
);
    wire        blok_basla, blok_tur, blok_tampon, blok_tamam, blok_hatali;
    wire [10:0] blok_k;
    wire        ak_yaz_etkin; wire [11:0] ak_yaz_adres; wire [63:0] ak_yaz_veri;
    wire        pn_yaz_etkin, pn_yaz_tampon; wire [1:0] pn_yaz_secici; wire [10:0] pn_yaz_adres; wire [63:0] pn_yaz_veri;

    wire         c_basla; wire [2:0] c_tip; wire [12:0] c_tg, c_ti, c_tc; wire [10:0] c_k; wire [6:0] c_pan; wire [5:0] c_kay; wire c_gelu, c_devrik;
    wire [30:0]  c_m0; wire [23:0] c_m0sm; wire [6:0] c_uz, c_ofs; wire [9:0] c_bkanal; wire [1:0] c_ln; wire c_y; wire [12:0] c_ty;
    wire         c_bitti, c_pbasla, c_pbitti, c_ptampon, c_tbasla, c_tbitti; wire [11:0] c_ptaban; wire [2:0] c_tsec;
    wire [1:0]   c_phazir; wire c_pbit, c_pbit_t;

    wire        rom_bitti; wire [15:0] c_agirlik_adres;
    wire        ay_blok_tamam;
    wire        blok_basla_ay = blok_basla & ~(blok_tur & (AGIRLIK_ROM != 0));       // agirlik ROM modunda panel bloklari bayt akisindan istenmez
    wire        rom_basla = blok_basla & blok_tur & (AGIRLIK_ROM != 0);
    assign      blok_tamam = ay_blok_tamam | rom_bitti;
    akis_ayristirici #(.GOMULU(1), .HIZLI_OLCUM(HIZLI_OLCUM)) u_ayristirici (
        .clk(clk), .rst(rst), .bayt_gecerli(bayt_gecerli), .bayt_veri(bayt_veri), .bayt_hazir(bayt_hazir),
        .blok_basla(blok_basla_ay), .blok_tur(blok_tur), .blok_tampon(blok_tampon), .blok_k(blok_k),
        .blok_tamam(ay_blok_tamam), .blok_hatali(blok_hatali),
        .aktivasyon_yaz_etkin(ak_yaz_etkin), .aktivasyon_yaz_adres(ak_yaz_adres), .aktivasyon_yaz_veri(ak_yaz_veri),
        .panel_yaz_etkin(pn_yaz_etkin), .panel_yaz_tampon(pn_yaz_tampon), .panel_yaz_secici(pn_yaz_secici),
        .panel_yaz_adres(pn_yaz_adres), .panel_yaz_veri(pn_yaz_veri),
        .hata_sayisi(hata_sayisi), .kabul_edilen_bayt(kabul_edilen_bayt), .cumle_uzunluk(cumle_uzunluk));

    wire        ic_oku; wire [12:0] ic_adres; wire [3:0] c_blok;
    cizelge_ortak #(.KATMAN_ISLEM(KATMAN_ISLEM), .SINIFLANDIR(SINIFLANDIR), .DOLGU_ATLA(DOLGU_ATLA), .NA(NA)) u_cizelge (
        .clk(clk), .rst(rst),
        .blok_basla(blok_basla), .blok_tur(blok_tur), .blok_tampon(blok_tampon), .blok_k(blok_k), .blok_tamam(blok_tamam), .blok_hatali(blok_hatali),
        .cumle_uzunluk(cumle_uzunluk),
        .basla(c_basla), .is_tipi(c_tip), .taban_giris(c_tg), .taban_ikinci(c_ti), .taban_cikis(c_tc), .ayar_k(c_k), .ayar_panel_sayisi(c_pan),
        .agirlik_adres(c_agirlik_adres), .ayar_kaydirma(c_kay), .gelu_etkin(c_gelu), .devrik_yaz(c_devrik), .ayar_m0(c_m0), .ayar_m0_sm(c_m0sm), .uzunluk(c_uz),
        .cikis_panel_ofset(c_ofs), .baglam_kanal(c_bkanal), .ln_no(c_ln), .ln_y_yaz(c_y), .ln_taban_y(c_ty), .bitti(c_bitti),
        .param_basla(c_pbasla), .param_taban(c_ptaban), .param_tampon(c_ptampon), .param_bitti(c_pbitti),
        .tablo_basla(c_tbasla), .tablo_sec(c_tsec), .tablo_bitti(c_tbitti),
        .panel_hazir(c_phazir), .panel_bitti(c_pbit), .panel_bitti_tampon(c_pbit_t),
        .gozlem(gozlem), .satir_bitti(satir_bitti), .devam(devam), .hata(hata), .satir_no(satir_no), .katman_no(katman_no),
        .cumle_no(cumle_no), .cumle_bitti(cumle_bitti), .ayar_blok_sayisi(c_blok),
        .ic_oku(ic_oku), .ic_oku_adres(ic_adres), .oku_veri_ic(oku_veri), .sinif(sinif), .sonuc_gecerli(sonuc_gecerli), .logit0(logit0), .logit1(logit1));

    ortak_cekirdek #(.NA(NA), .AGIRLIK_ROM(AGIRLIK_ROM), .ROM_D(ROM_D)) u_cekirdek (
        .clk(clk), .rst(rst), .basla(c_basla), .is_tipi(c_tip), .taban_giris(c_tg), .taban_ikinci(c_ti), .taban_cikis(c_tc),
        .ayar_k(c_k), .ayar_panel_sayisi(c_pan), .ayar_blok_sayisi(c_blok), .ayar_kaydirma(c_kay), .gelu_etkin(c_gelu), .devrik_yaz(c_devrik),
        .ayar_m0(c_m0), .ayar_m0_sm(c_m0sm), .uzunluk(c_uz), .cikis_panel_ofset(c_ofs), .baglam_kanal(c_bkanal),
        .ln_no(c_ln), .ln_y_yaz(c_y), .ln_taban_y(c_ty), .mesgul(), .bitti(c_bitti),
        .dis_yaz_etkin(ak_yaz_etkin), .dis_yaz_adres({1'b0, ak_yaz_adres}), .dis_yaz_veri(ak_yaz_veri),
        .dis_oku_adres(ic_oku ? ic_adres : oku_adres), .dis_oku_veri(oku_veri),
        .w_yaz_etkin(pn_yaz_etkin), .w_yaz_tampon(pn_yaz_tampon), .w_yaz_adres(pn_yaz_adres), .w_yaz_veri(pn_yaz_veri),
        .param_basla(c_pbasla), .param_taban(c_ptaban), .param_tampon(c_ptampon), .param_bitti(c_pbitti),
        .agr_basla(rom_basla), .agr_adres(c_agirlik_adres), .agr_tampon(blok_tampon), .agr_k(blok_k), .agr_bitti(rom_bitti),
        .tablo_basla(c_tbasla), .tablo_sec(c_tsec), .tablo_bitti(c_tbitti), .tablo_mesgul(),
        .panel_hazir(c_phazir), .panel_bitti(c_pbit), .panel_bitti_tampon(c_pbit_t),
        .tasma_hatasi(tasma_hatasi), .kirpilan_sayisi(kirpilan_sayisi), .skor_tasma(skor_tasma), .ln_tasma(ln_tasma), .bellek_catisma(bellek_catisma));
endmodule
