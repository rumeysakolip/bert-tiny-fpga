// -----------------------------------------------------------------------------
// dogrusal_katman_birlesik.v -- dogrusal katman: birlesik aktivasyon belleği (48 KB), adres tabanlari, gomulu sabit parametreler
//   Hesap birimleri (tile denetleyici + 8x8 dizi, panel tamponu, GELU tablosu, cikis sozcuk toplayici) degismedi.
//   Degisen: ayri giris/cikis bellekleri yerine tek birlesik bellek; katman giris tabanindan okur, cikis tabanina yazar.
//   Yeniden olcekleme: dikkat skoruyla ortak carpma devresi (genis=0: 8 bit kirpma).
//   Sapma/olcek carpani ve GELU tablosu gomulu bellekten (dogrusal_katman_gomulu ile ayni).
//   Disaridan bellege erisim (kosmuyorken): dis_yaz_* (cumle girisi), dis_oku_* (sonuc okuma / sonraki birimler).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module dogrusal_katman_birlesik (
    input  wire         clk,
    input  wire         rst,
    // katman ayarlari
    input  wire         calistir,
    input  wire [10:0]  ayar_k,
    input  wire [6:0]   ayar_panel_sayisi,
    input  wire [3:0]   ayar_blok_sayisi,
    input  wire [5:0]   ayar_kaydirma,
    input  wire         a_isaretsiz,
    input  wire         gelu_etkin,
    input  wire         devrik_yaz,          // 1: cikis devrik (panel) duzeninde yazilir (dikkatte deger matrisi icin)
    input  wire [12:0]  taban_giris,
    input  wire [12:0]  taban_cikis,
    output wire         mesgul,
    output wire         katman_bitti,
    // bellek dis erisim (yalniz katman kosmuyorken)
    input  wire         dis_yaz_etkin,
    input  wire [12:0]  dis_yaz_adres,
    input  wire [63:0]  dis_yaz_veri,
    input  wire [12:0]  dis_oku_adres,
    output wire [63:0]  dis_oku_veri,
    // agirlik sozcugu yazma
    input  wire         w_yaz_etkin,
    input  wire         w_yaz_tampon,
    input  wire [10:0]  w_yaz_adres,
    input  wire [63:0]  w_yaz_veri,
    // gomulu parametre / tablo yukleme
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
    output wire         tasma_hatasi,
    output reg  [31:0]  kirpilan_sayisi
);
    // ---- gomulu parametre ve tablo yukleyiciler ----
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

    // ---- panel tamponu (agirlik sozcugu ya da gomulu parametre yazar) ----
    wire        panel_yaz_etkin  = p_yaz_etkin | w_yaz_etkin;
    wire        panel_yaz_tampon = p_yaz_etkin ? p_yaz_tampon : w_yaz_tampon;
    wire [1:0]  panel_yaz_secici = p_yaz_etkin ? p_yaz_secici : 2'd0;
    wire [10:0] panel_yaz_adres  = p_yaz_etkin ? p_yaz_adres  : w_yaz_adres;
    wire [63:0] panel_yaz_veri   = p_yaz_etkin ? p_yaz_veri   : w_yaz_veri;
    wire        panel_oku_tampon; wire [10:0] panel_oku_adres; wire [63:0] panel_oku_veri;
    wire        sorgu_tampon; wire [2:0] sorgu_kanal; wire [31:0] sorgu_bias; wire [30:0] sorgu_m0;
    panel_tamponu #(.K_ENFAZLA(512), .K_GENISLIGI(11)) u_panel_tamponu (.clk(clk), .panel_yaz_etkin(panel_yaz_etkin), .panel_yaz_tampon(panel_yaz_tampon), .panel_yaz_secici(panel_yaz_secici),
        .panel_yaz_adres(panel_yaz_adres), .panel_yaz_veri(panel_yaz_veri), .agirlik_oku_tampon(panel_oku_tampon), .agirlik_oku_adres(panel_oku_adres), .agirlik_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias), .sorgu_m0(sorgu_m0));

    // ---- birlesik aktivasyon belleği ----
    wire [11:0] akt_oku_adres_g;                         // tile'in goreli aktivasyon adresi
    wire [63:0] bellek_oku_veri;
    reg         kosuyor;                                 // calistir'dan, cikis tamamen yazilana kadar
    wire        cikis_yaz_etkin; wire [11:0] cikis_yaz_adres_g; wire [63:0] cikis_yaz_veri;
    wire        n_yaz_etkin, d_yaz_etkin; wire [11:0] n_yaz_adres, d_yaz_adres; wire [63:0] n_yaz_veri, d_yaz_veri;
    reg         devrik_k;                                  // katman kosarken devrik yazim kipi sabit tutulur (calistir anindaki deger)
    assign cikis_yaz_etkin    = devrik_k ? d_yaz_etkin : n_yaz_etkin;
    assign cikis_yaz_adres_g  = devrik_k ? d_yaz_adres : n_yaz_adres;
    assign cikis_yaz_veri     = devrik_k ? d_yaz_veri  : n_yaz_veri;
    wire [12:0] b_yaz_adres = cikis_yaz_etkin ? (taban_cikis + {1'b0, cikis_yaz_adres_g}) : dis_yaz_adres;
    wire        b_yaz_etkin = cikis_yaz_etkin | (dis_yaz_etkin & ~kosuyor);
    wire [63:0] b_yaz_veri  = cikis_yaz_etkin ? cikis_yaz_veri : dis_yaz_veri;
    wire [12:0] b_oku_adres = kosuyor ? (taban_giris + {1'b0, akt_oku_adres_g}) : dis_oku_adres;
    birlesik_bellek #(.BIRIM_SAYISI(6), .AW(13)) u_bellek (.clk(clk), .yaz_etkin(b_yaz_etkin), .yaz_adres(b_yaz_adres), .yaz_veri(b_yaz_veri),
        .oku_adres(b_oku_adres), .oku_veri(bellek_oku_veri));
    assign dis_oku_veri = bellek_oku_veri;

    // ---- tile denetleyici + dizi (mevcut) ----
    wire              cikis_gecerli, cikis_tile_son;
    wire [2:0]        cikis_token, cikis_kanal;
    wire [3:0]        cikis_blok;
    wire [6:0]        cikis_panel;
    wire signed [31:0] cikis_birikec;
    wire              katman_bitti_ham;
    tile_denetleyici #(.DIZI_BOYUTU(8), .BLOK_SAYISI(8), .K_GENISLIGI(11), .PANEL_GENISLIGI(7), .ADRES_GENISLIGI(12)) u_tile_denetleyici (
        .clk(clk), .rst(rst), .calistir(calistir), .ayar_k(ayar_k), .ayar_panel_sayisi(ayar_panel_sayisi), .ayar_blok_sayisi(ayar_blok_sayisi), .a_isaretsiz(a_isaretsiz),
        .mesgul(mesgul), .katman_bitti(katman_bitti_ham), .panel_hazir(panel_hazir), .panel_bitti(panel_bitti),
        .panel_bitti_tampon(panel_bitti_tampon), .aktivasyon_oku_adres(akt_oku_adres_g), .aktivasyon_oku_veri(bellek_oku_veri),
        .panel_oku_tampon(panel_oku_tampon), .panel_oku_adres(panel_oku_adres), .panel_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias),
        .cikis_gecerli(cikis_gecerli), .cikis_token(cikis_token), .cikis_kanal(cikis_kanal), .cikis_blok(cikis_blok), .cikis_panel(cikis_panel),
        .cikis_tile_son(cikis_tile_son), .cikis_birikec(cikis_birikec), .cikis_tasma(tasma_hatasi));

    // ---- yeniden olcekleme (ortak carpma devresi, 8 bit kirpma) ----
    reg [30:0] olcek_m0_gecikmis1, olcek_m0_gecikmis2;
    always @(posedge clk) begin olcek_m0_gecikmis1 <= sorgu_m0; olcek_m0_gecikmis2 <= olcek_m0_gecikmis1; end
    wire               rs_gecerli, kirpildi;
    wire signed [31:0] rs_veri;
    wire [17:0]        rs_meta;
    yeniden_olcekle_ortak #(.META_W(18)) u_yeniden_olcekle (
        .clk(clk), .rst(rst), .genis(1'b0), .giris_gecerli(cikis_gecerli), .birikec(cikis_birikec), .olcek_m0(olcek_m0_gecikmis2), .kaydirma(ayar_kaydirma),
        .yan_bilgi_giris({cikis_tile_son, cikis_token, cikis_kanal, cikis_blok, cikis_panel}),
        .cikis_gecerli(rs_gecerli), .cikis_veri(rs_veri), .yan_bilgi_cikis(rs_meta), .kirpildi(kirpildi));
    wire signed [7:0] olcekli_cikis = rs_veri[7:0];

    // ---- GELU / tanh tablosu ----
    wire signed [7:0] gelu_cikis;
    gelu_tablosu u_gelu_tablosu (.clk(clk), .gelu_yaz_etkin(g_yaz_etkin), .gelu_yaz_adres(g_yaz_adres), .gelu_yaz_veri(g_yaz_veri), .giris_int8(olcekli_cikis), .cikis_int8(gelu_cikis));
    wire signed [7:0] son_cikis = gelu_etkin ? gelu_cikis : olcekli_cikis;

    // ---- sozcuk toplayici -> birlesik belleğe yazma ----
    cikis_sozcuk_toplayici #(.ADRES_GENISLIGI(12), .PANEL_GENISLIGI(7)) u_cikis_sozcuk_toplayici (
        .clk(clk), .rst(rst), .gecerli(rs_gecerli), .veri_int8(son_cikis),
        .token_sirasi(rs_meta[16:14]), .kanal_sirasi(rs_meta[13:11]), .blok_no(rs_meta[10:7]), .panel_no(rs_meta[6:0]),
        .kanal_toplami({ayar_panel_sayisi, 3'b000}), .yaz_etkin(n_yaz_etkin), .yaz_adres(n_yaz_adres), .yaz_veri(n_yaz_veri));
    cikis_sozcuk_toplayici_devrik #(.ADRES_GENISLIGI(12), .PANEL_GENISLIGI(7)) u_devrik (
        .clk(clk), .rst(rst), .gecerli(rs_gecerli), .veri_int8(son_cikis),
        .token_sirasi(rs_meta[16:14]), .kanal_sirasi(rs_meta[13:11]), .blok_no(rs_meta[10:7]), .panel_no(rs_meta[6:0]),
        .yaz_etkin(d_yaz_etkin), .yaz_adres(d_yaz_adres), .yaz_veri(d_yaz_veri));

    // ---- katman_bitti: boru hatti ve toplayici bosalana kadar ertele; kosuyor bayragi ----
    // Devrik yazimda son tile'in 8 sozcugu cikislardan sonra yazilir: bitis 10 cevrim daha ertelenir.
    reg [15:0] bitis_gecikme_kaydirici;
    wire       bitis_hazir = devrik_k ? bitis_gecikme_kaydirici[15] : bitis_gecikme_kaydirici[5];
    always @(posedge clk) begin
        if (rst) bitis_gecikme_kaydirici <= 16'd0; else bitis_gecikme_kaydirici <= {bitis_gecikme_kaydirici[14:0], katman_bitti_ham};
        if (rst) devrik_k <= 1'b0; else if (calistir) devrik_k <= devrik_yaz;
        if (rst) kosuyor <= 1'b0;
        else if (calistir) kosuyor <= 1'b1;
        else if (bitis_hazir) kosuyor <= 1'b0;
        if (rst || calistir) kirpilan_sayisi <= 32'd0;
        else if (kirpildi) kirpilan_sayisi <= kirpilan_sayisi + 32'd1;
    end
    assign katman_bitti = bitis_hazir;
endmodule
