// -----------------------------------------------------------------------------
// dogrusal_katman_gomulu.v -- dogrusal katman + gomulu sabit parametreler
//   Mevcut dogrusal_katman (degismedi) + parametre_rom + panel_parametre_yukleyici + gelu_yukleyici.
//   Disaridan yalniz agirlik sozcukleri (secici 0) gelir; bias/M0 panel tamponuna gomulu bellekten yazilir,
//   GELU/tanh tablosu gomulu bellekten yuklenir.
//   Panel akisi: agirlik yaz (w_*) -> param_basla (taban, tampon) -> param_bitti -> panel_hazir yukseltilir (cagiran).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module dogrusal_katman_gomulu (
    input  wire         clk,
    input  wire         rst,
    // katman ayarlari (cagiran: cizelge ya da test duzenegi)
    input  wire         calistir,
    input  wire [10:0]  ayar_k,
    input  wire [6:0]   ayar_panel_sayisi,
    input  wire [3:0]   ayar_blok_sayisi,
    input  wire [5:0]   ayar_kaydirma,
    input  wire         a_isaretsiz,
    input  wire         gelu_etkin,
    output wire         mesgul,
    output wire         katman_bitti,
    // aktivasyon yazma
    input  wire         aktivasyon_yaz_etkin,
    input  wire [11:0]  aktivasyon_yaz_adres,
    input  wire [63:0]  aktivasyon_yaz_veri,
    // agirlik sozcugu yazma (yalniz secici 0)
    input  wire         w_yaz_etkin,
    input  wire         w_yaz_tampon,
    input  wire [10:0]  w_yaz_adres,
    input  wire [63:0]  w_yaz_veri,
    // gomulu parametre yukleme
    input  wire         param_basla,
    input  wire [11:0]  param_taban,
    input  wire         param_tampon,
    output wire         param_bitti,
    input  wire         tablo_basla,
    input  wire [1:0]   tablo_sec,
    output wire         tablo_bitti,
    output wire         tablo_mesgul,
    // panel el sikismasi
    input  wire [1:0]   panel_hazir,
    output wire         panel_bitti,
    output wire         panel_bitti_tampon,
    // cikis okuma
    input  wire [11:0]  cikis_oku_adres,
    output wire [63:0]  cikis_oku_veri,
    output wire         tasma_hatasi,
    output wire [31:0]  kirpilan_sayisi
);
    wire [11:0] rom_adres; wire [31:0] rom_bias, rom_m0;
    parametre_rom u_rom (.clk(clk), .adres(rom_adres), .bias(rom_bias), .m0(rom_m0));

    wire        p_yaz_etkin, p_yaz_tampon; wire [1:0] p_yaz_secici; wire [10:0] p_yaz_adres; wire [63:0] p_yaz_veri; wire p_mesgul;
    panel_parametre_yukleyici u_param (.clk(clk), .rst(rst), .basla(param_basla), .taban(param_taban), .tampon(param_tampon),
        .rom_adres(rom_adres), .rom_bias(rom_bias), .rom_m0(rom_m0),
        .panel_yaz_etkin(p_yaz_etkin), .panel_yaz_tampon(p_yaz_tampon), .panel_yaz_secici(p_yaz_secici), .panel_yaz_adres(p_yaz_adres), .panel_yaz_veri(p_yaz_veri),
        .mesgul(p_mesgul), .bitti(param_bitti));

    wire        g_yaz_etkin; wire [7:0] g_yaz_adres, g_yaz_veri;
    gelu_yukleyici u_tablo (.clk(clk), .rst(rst), .basla(tablo_basla), .tablo_sec(tablo_sec),
        .gelu_yaz_etkin(g_yaz_etkin), .gelu_yaz_adres(g_yaz_adres), .gelu_yaz_veri(g_yaz_veri), .mesgul(tablo_mesgul), .bitti(tablo_bitti));

    // panel tamponu yazma yolu: parametre yukleyici etkinse o, degilse agirlik sozcugu
    wire        panel_yaz_etkin  = p_yaz_etkin | w_yaz_etkin;
    wire        panel_yaz_tampon = p_yaz_etkin ? p_yaz_tampon : w_yaz_tampon;
    wire [1:0]  panel_yaz_secici = p_yaz_etkin ? p_yaz_secici : 2'd0;
    wire [10:0] panel_yaz_adres  = p_yaz_etkin ? p_yaz_adres  : w_yaz_adres;
    wire [63:0] panel_yaz_veri   = p_yaz_etkin ? p_yaz_veri   : w_yaz_veri;

    dogrusal_katman u_katman (
        .clk(clk), .rst(rst), .calistir(calistir), .ayar_k(ayar_k), .ayar_panel_sayisi(ayar_panel_sayisi), .ayar_blok_sayisi(ayar_blok_sayisi),
        .ayar_kaydirma(ayar_kaydirma), .a_isaretsiz(a_isaretsiz), .gelu_etkin(gelu_etkin), .mesgul(mesgul), .katman_bitti(katman_bitti),
        .aktivasyon_yaz_etkin(aktivasyon_yaz_etkin), .aktivasyon_yaz_adres(aktivasyon_yaz_adres), .aktivasyon_yaz_veri(aktivasyon_yaz_veri),
        .panel_yaz_etkin(panel_yaz_etkin), .panel_yaz_tampon(panel_yaz_tampon), .panel_yaz_secici(panel_yaz_secici),
        .panel_yaz_adres(panel_yaz_adres), .panel_yaz_veri(panel_yaz_veri),
        .panel_hazir(panel_hazir), .panel_bitti(panel_bitti), .panel_bitti_tampon(panel_bitti_tampon),
        .gelu_yaz_etkin(g_yaz_etkin), .gelu_yaz_adres(g_yaz_adres), .gelu_yaz_veri(g_yaz_veri),
        .cikis_oku_adres(cikis_oku_adres), .cikis_oku_veri(cikis_oku_veri), .tasma_hatasi(tasma_hatasi), .kirpilan_sayisi(kirpilan_sayisi));
endmodule
