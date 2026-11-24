// -----------------------------------------------------------------------------
// ek_hat.v -- paralel dogrusal hat (lane): ortak cekirdegin 0. hattina eklenen, ayni aktivasyon akisini paylasan ek 8x8 dizi
//   Dogrusal satirda NA hat birlikte calisir: hat h, her grubun h numarali panelini (genel panel = grup*NA + h) hesaplar.
//   Her hat kendi agirlik bankasi, panel tamponu, parametre okuyucusu, tile denetleyicisi, sistolik dizisi, yeniden olcekleme devresi,
//   GELU tablosu ve cikis sozcuk toplayicisina sahiptir; A operandi (aktivasyon sozcugu) ve panel_hazir isareti tum hatlarda ortaktir,
//   hatlar ayni FSM'yi ayni girdilerle surdugu icin ADIM ADIM esgudumludur (0. hattin adres/denetim isaretleri yeterlidir).
//   Dikkat (Q.K^T, P.V), LayerNorm ve Softmax yalniz 0. hatta calisir.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module ek_hat #(
    parameter HAT      = 1,
    parameter LOG2NA   = 3,
    parameter ROM_DOSYA = "agirlik_rom_b1.mem",
    parameter ROM_D    = 8192
) (
    input  wire         clk,
    input  wire         rst,
    input  wire         calistir,                // 1 cevrim: dogrusal is basladi (basla_d & t_lin)
    input  wire [10:0]  ayar_k,
    input  wire [6:0]   ayar_panel_grup,         // panel grubu sayisi = ceil(np/NA)
    input  wire [6:0]   ayar_panel_gercek,       // gercek panel sayisi np (cikis adresi ve gecerlilik icin)
    input  wire [3:0]   ayar_blok_sayisi,
    input  wire [5:0]   ayar_kaydirma,
    input  wire         gelu_etkin,
    input  wire         devrik_k,
    input  wire [1:0]   panel_hazir,
    input  wire [63:0]  a_veri,                  // paylasilan aktivasyon sozcugu (0. hattin adresiyle okunur)
    // agirlik kopyalama (yonga ici banka -> panel tamponu)
    input  wire         rom_basla,
    input  wire [15:0]  rom_adres,
    input  wire         rom_tampon,
    input  wire [9:0]   rom_k,
    output wire         rom_bitti,
    // sapma / olcek carpani yukleme
    input  wire         param_basla,
    input  wire [11:0]  param_taban,             // bu hattin panelinin ilk kanalinin parametre indeksi
    input  wire         param_tampon,
    output wire         param_bitti,
    // GELU tablosu yazma (yayin)
    input  wire         g_yaz_etkin,
    input  wire [7:0]   g_yaz_adres,
    input  wire [7:0]   g_yaz_veri,
    // cikis: toplanmis sozcuk (normal ya da devrik duzen secili)
    output wire         yaz_etkin,
    output wire [11:0]  yaz_adres,
    output wire [63:0]  yaz_veri,
    output wire         tasma
);
    // ---------------- agirlik bankasi + kopyalayici ----------------
    wire [15:0] k_oku_adres; wire [63:0] k_oku_veri;
    agirlik_rom_banka #(.DOSYA(ROM_DOSYA), .D(ROM_D), .AW(16)) u_rom (.clk(clk), .adres(k_oku_adres), .veri(k_oku_veri));
    wire        rk_yaz_etkin, rk_yaz_tampon; wire [1:0] rk_yaz_secici; wire [10:0] rk_yaz_adres; wire [63:0] rk_yaz_veri; wire rk_mesgul;
    panel_kopyalayici #(.K_UZUNLUK(512), .KAYNAK_AW(16), .K_DINAMIK(1)) u_kop (.clk(clk), .rst(rst), .basla(rom_basla), .k_uz(rom_k), .k_pad(10'd0),
        .kaynak_adres(rom_adres), .tampon(rom_tampon), .k_oku_adres(k_oku_adres), .k_oku_veri(k_oku_veri),
        .panel_yaz_etkin(rk_yaz_etkin), .panel_yaz_tampon(rk_yaz_tampon), .panel_yaz_secici(rk_yaz_secici), .panel_yaz_adres(rk_yaz_adres), .panel_yaz_veri(rk_yaz_veri),
        .mesgul(rk_mesgul), .bitti(rom_bitti));

    // ---------------- sapma ve olcek carpani ----------------
    wire [11:0] prom_adres; wire [31:0] prom_bias, prom_m0;
    parametre_rom u_prom (.clk(clk), .adres(prom_adres), .bias(prom_bias), .m0(prom_m0));
    wire        p_yaz_etkin, p_yaz_tampon; wire [1:0] p_yaz_secici; wire [10:0] p_yaz_adres; wire [63:0] p_yaz_veri; wire p_mesgul;
    panel_parametre_yukleyici u_param (.clk(clk), .rst(rst), .basla(param_basla), .taban(param_taban), .tampon(param_tampon),
        .rom_adres(prom_adres), .rom_bias(prom_bias), .rom_m0(prom_m0),
        .panel_yaz_etkin(p_yaz_etkin), .panel_yaz_tampon(p_yaz_tampon), .panel_yaz_secici(p_yaz_secici), .panel_yaz_adres(p_yaz_adres), .panel_yaz_veri(p_yaz_veri),
        .mesgul(p_mesgul), .bitti(param_bitti));

    // ---------------- panel tamponu ----------------
    wire        py_etkin  = rk_yaz_etkin | p_yaz_etkin;
    wire        py_tampon = rk_yaz_etkin ? rk_yaz_tampon : p_yaz_tampon;
    wire [1:0]  py_secici = rk_yaz_etkin ? rk_yaz_secici : p_yaz_secici;
    wire [10:0] py_adres  = rk_yaz_etkin ? rk_yaz_adres  : p_yaz_adres;
    wire [63:0] py_veri   = rk_yaz_etkin ? rk_yaz_veri   : p_yaz_veri;
    wire        panel_oku_tampon; wire [10:0] panel_oku_adres; wire [63:0] panel_oku_veri;
    wire        sorgu_tampon; wire [2:0] sorgu_kanal; wire [31:0] sorgu_bias; wire [30:0] sorgu_m0;
    panel_tamponu #(.K_ENFAZLA(512), .K_GENISLIGI(11)) u_panel_tamponu (.clk(clk), .panel_yaz_etkin(py_etkin), .panel_yaz_tampon(py_tampon), .panel_yaz_secici(py_secici),
        .panel_yaz_adres(py_adres), .panel_yaz_veri(py_veri), .agirlik_oku_tampon(panel_oku_tampon), .agirlik_oku_adres(panel_oku_adres), .agirlik_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias), .sorgu_m0(sorgu_m0));

    // ---------------- tile denetleyici + sistolik dizi ----------------
    wire        cikis_gecerli, cikis_tile_son; wire [2:0] cikis_token, cikis_kanal; wire [3:0] cikis_blok; wire [6:0] cikis_panel; wire signed [31:0] cikis_birikec;
    wire        t_mesgul, t_bitti, t_panel_bitti, t_panel_bitti_tampon; wire [11:0] t_akt_adres;
    tile_denetleyici #(.DIZI_BOYUTU(8), .BLOK_SAYISI(8), .K_GENISLIGI(11), .PANEL_GENISLIGI(7), .ADRES_GENISLIGI(12)) u_tile (
        .clk(clk), .rst(rst), .calistir(calistir), .ayar_k(ayar_k), .ayar_panel_sayisi(ayar_panel_grup), .ayar_blok_sayisi(ayar_blok_sayisi), .a_isaretsiz(1'b0),
        .mesgul(t_mesgul), .katman_bitti(t_bitti), .panel_hazir(panel_hazir), .panel_bitti(t_panel_bitti), .panel_bitti_tampon(t_panel_bitti_tampon),
        .aktivasyon_oku_adres(t_akt_adres), .aktivasyon_oku_veri(a_veri),
        .panel_oku_tampon(panel_oku_tampon), .panel_oku_adres(panel_oku_adres), .panel_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias),
        .cikis_gecerli(cikis_gecerli), .cikis_token(cikis_token), .cikis_kanal(cikis_kanal), .cikis_blok(cikis_blok), .cikis_panel(cikis_panel),
        .cikis_tile_son(cikis_tile_son), .cikis_birikec(cikis_birikec), .cikis_tasma(tasma));

    // ---------------- yeniden olcekleme + GELU ----------------
    reg [30:0] m0_g1, m0_g2;
    always @(posedge clk) begin m0_g1 <= sorgu_m0; m0_g2 <= m0_g1; end
    wire        rs_gecerli, rs_kirp; wire signed [31:0] rs_veri; wire [17:0] rs_meta;
    yeniden_olcekle_ortak #(.META_W(18)) u_rs (.clk(clk), .rst(rst), .genis(1'b0), .giris_gecerli(cikis_gecerli), .birikec(cikis_birikec),
        .olcek_m0(m0_g2), .kaydirma(ayar_kaydirma), .yan_bilgi_giris({cikis_tile_son, cikis_token, cikis_kanal, cikis_blok, cikis_panel}),
        .cikis_gecerli(rs_gecerli), .cikis_veri(rs_veri), .yan_bilgi_cikis(rs_meta), .kirpildi(rs_kirp));
    wire signed [7:0] gelu_cikis;
    gelu_tablosu u_gelu (.clk(clk), .gelu_yaz_etkin(g_yaz_etkin), .gelu_yaz_adres(g_yaz_adres), .gelu_yaz_veri(g_yaz_veri), .giris_int8(rs_veri[7:0]), .cikis_int8(gelu_cikis));
    wire signed [7:0] son_cikis = gelu_etkin ? gelu_cikis : rs_veri[7:0];

    // ---------------- cikis sozcuk toplayicilar (genel panel numarasi = yerel*NA + HAT) ----------------
    wire [6:0] panel_genel = (rs_meta[6:0] << LOG2NA) | HAT;
    wire       panel_gecerli = (panel_genel < ayar_panel_gercek);          // NA'ya yuvarlamadan gelen bos paneller yazilmaz
    wire        n_etkin, d_etkin; wire [11:0] n_adres, d_adres; wire [63:0] n_veri, d_veri;
    cikis_sozcuk_toplayici #(.ADRES_GENISLIGI(12), .PANEL_GENISLIGI(7)) u_toplayici (
        .clk(clk), .rst(rst), .gecerli(rs_gecerli & panel_gecerli), .veri_int8(son_cikis),
        .token_sirasi(rs_meta[16:14]), .kanal_sirasi(rs_meta[13:11]), .blok_no(rs_meta[10:7]), .panel_no(panel_genel),
        .kanal_toplami({ayar_panel_gercek, 3'b000}), .yaz_etkin(n_etkin), .yaz_adres(n_adres), .yaz_veri(n_veri));
    cikis_sozcuk_toplayici_devrik #(.ADRES_GENISLIGI(12), .PANEL_GENISLIGI(7)) u_devrik (
        .clk(clk), .rst(rst), .gecerli(rs_gecerli & panel_gecerli), .veri_int8(son_cikis),
        .token_sirasi(rs_meta[16:14]), .kanal_sirasi(rs_meta[13:11]), .blok_no(rs_meta[10:7]), .panel_no(panel_genel),
        .yaz_etkin(d_etkin), .yaz_adres(d_adres), .yaz_veri(d_veri));
    assign yaz_etkin = devrik_k ? d_etkin : n_etkin;
    assign yaz_adres = devrik_k ? d_adres : n_adres;
    assign yaz_veri  = devrik_k ? d_veri  : n_veri;
endmodule
