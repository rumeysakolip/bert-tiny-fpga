// -----------------------------------------------------------------------------
// ortak_cekirdek.v -- TEK 8x8 dizi + TEK yeniden olcekleme devresi + 48 KB birlesik aktivasyon belleği; dort is turu
//   is_tipi 0: dogrusal katman (agirlik paneli akisla gelir; GELU, devrik yazim secenekleri)
//   is_tipi 1: Q.K^T -> yeniden olcekleme -> Softmax -> olasilik belleğine (K paneli aktivasyon belleğinden kopyalanir)
//   is_tipi 2: olasilik x deger (P.V) -> baglam (deger paneli aktivasyon belleğinden kopyalanir)
//   is_tipi 3: artik toplama + LayerNorm + sonraki girdinin yeniden olceklenmesi (ayni carpma devresi sirayla kullanilir)
// Bellek iki okuma portludur: port 1 dizinin A operandi (ve LayerNorm), port 2 panel kopyalayici (K / V).
// Is tabanlari: taban_giris (A / x), taban_ikinci (K ya da V paneli / a), taban_cikis (cikis). Tabanlar basla'da kilitlenir.
// Yerlesim kurali: Q.K^T ve P.V icin taban_giris ile taban_ikinci FARKLI 1024'luk birimlerde olmalidir.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module ortak_cekirdek #(
    parameter NA = 1,                  // paralel dogrusal hat sayisi (1, 2, 4, 8); NA>1 iken AGIRLIK_ROM=1 olmali
    parameter AGIRLIK_ROM = 0,         // 1: agirlik paneli yonga ici bankalardan (agirlik_rom_b<i>.mem) gelir; 0: bayt akisindan (w_yaz_*)
    parameter ROM_D = 8192,            // banka derinligi (64 bit sozcuk)
    parameter LN_PAR = 0,              // 1: artik + LayerNorm bir blogun 8 satiri icin 8 paralel hatta (artik_ln_par), her hat kendi yeniden olcekleme devresiyle
    parameter SMP = 0,                 // 1: Softmax bir blogun 8 satiri icin 8 paralel birimde (skor bellegi 8 bankaya bolunur)
    parameter ATTP = 0                 // 1: Q.K^T ve P.V de 8 hatta (NA=8 ve SMP=1 gerekir): hat h, panel h'yi hesaplar; skorlar hat bankalarina yazilir
) (
    input  wire         clk,
    input  wire         rst,
    input  wire         basla,                 // 1 cevrim darbe (mesgul degilken)
    input  wire [2:0]   is_tipi,
    input  wire [12:0]  taban_giris,
    input  wire [12:0]  taban_ikinci,
    input  wire [12:0]  taban_cikis,
    // dogrusal katman ayarlari
    input  wire [10:0]  ayar_k,
    input  wire [6:0]   ayar_panel_sayisi,
    input  wire [3:0]   ayar_blok_sayisi,
    input  wire [5:0]   ayar_kaydirma,         // dogrusal: kaydirma ; Q.K^T ve P.V: yeniden olcekleme kaydirmasi
    input  wire         gelu_etkin,
    input  wire         devrik_yaz,
    // dikkat ayarlari
    input  wire [30:0]  ayar_m0,               // Q.K^T ya da P.V yeniden olcekleme carpani
    input  wire [23:0]  ayar_m0_sm,            // Softmax carpani
    input  wire [6:0]   uzunluk,               // gercek token sayisi (anahtar maskesi)
    input  wire [6:0]   cikis_panel_ofset,     // P.V: bas icin panel kaydirma (bas*8)
    input  wire [9:0]   baglam_kanal,          // P.V: baglam bloklarindaki toplam kanal (128)
    // LayerNorm ayari
    input  wire [1:0]   ln_no,
    input  wire         ln_y_yaz,               // 1: LayerNorm yeniden olceklenmemis cikisi (y) ayrica ln_taban_y'ye yazilir
    input  wire [12:0]  ln_taban_y,
    output wire         mesgul,
    output wire         bitti,                 // is bitti (1 cevrim darbe; cikis tamamen yazilmis)
    // bellek dis erisim (yalniz is yokken)
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
    // yonga ici agirlik ROM'u (AGIRLIK_ROM=1): bir panel grubunu panel tamponlarina kopyalama istegi
    input  wire         agr_basla,
    input  wire [15:0]  agr_adres,
    input  wire         agr_tampon,
    input  wire [10:0]  agr_k,
    output wire         agr_bitti,
    input  wire         tablo_basla,
    input  wire [2:0]   tablo_sec,
    output wire         tablo_bitti,
    output wire         tablo_mesgul,
    // dogrusal katman panel el sikismasi
    input  wire [1:0]   panel_hazir,
    output wire         panel_bitti,
    output wire         panel_bitti_tampon,
    // durum
    output wire         tasma_hatasi,
    output reg  [31:0]  kirpilan_sayisi,
    output reg          skor_tasma,
    output wire         ln_tasma,
    output wire         bellek_catisma
);
    // ---------------- is durumu ----------------
    reg [2:0]  tip;
    reg [12:0] tg, ti, tc;
    reg        isyeri, basla_d, devrik_k;
    reg [3:0]  kop_p;                      // ATTP: panel kopyalama hedefi (hat numarasi = panel numarasi)
    reg [3:0]  nb_k;                       // bu isin token blogu sayisi nb (1..8), basla'da kilitlenir (dolgu atlama)
    wire [6:0] kmax = {nb_k, 3'b000};      // 8*nb: etkin token sayisi (blok hizali); nb=8 iken 64
    localparam LOG2NA = (NA == 1) ? 0 : (NA == 2) ? 1 : (NA == 4) ? 2 : 3;
    wire [6:0] npg_lin = (ayar_panel_sayisi + NA - 1) >> LOG2NA;   // dogrusal satirda panel GRUBU sayisi (NA panel birlikte)
    wire [6:0] kpv  = (kmax < 7'd48) ? 7'd48 : kmax;   // P.V'nin K'si: tile suresi K+16 >= 64 olmali (golge akitma 64 cevrim); kisa K sifirla doldurulur
    reg [1:0]  lnk;
    reg        ln_y_yaz_k; reg [12:0] ln_taban_y_k;
    // is turu: tek 3 bitlik `tip` kaydi cok yuklu (fanout ~177) ve kritik yolun basindaydi; bu yuzden bir-sicak ayri kayitlar, her biri sinirli yukle (zamanlama; islev ayni)
    (* max_fanout = 24 *) reg t_lin;       // 0 dogrusal
    (* max_fanout = 24 *) reg t_qk;        // 1 Q.K^T + Softmax
    (* max_fanout = 24 *) reg t_pv;        // 2 P.V
    (* max_fanout = 24 *) reg t_ln;        // 3 artik + LayerNorm
    (* max_fanout = 24 *) reg t_att;       // t_qk | t_pv
    wire bitti_ic;
    wire tile_mesgul;                    // (xsim: kullanimdan once bildirilmeli)
    assign mesgul = isyeri;
    assign bitti  = bitti_ic;
    always @(posedge clk) begin
        basla_d <= 1'b0;
        if (rst) begin
            isyeri <= 1'b0; nb_k <= 4'd8; tip <= 3'd0; t_lin <= 1'b1; t_qk <= 1'b0; t_pv <= 1'b0; t_ln <= 1'b0; t_att <= 1'b0; devrik_k <= 1'b0; tg <= 13'd0; ti <= 13'd0; tc <= 13'd0; lnk <= 2'd0; ln_y_yaz_k <= 1'b0; ln_taban_y_k <= 13'd0;
        end else if (basla && !isyeri) begin
            nb_k <= (ayar_blok_sayisi == 4'd0 || ayar_blok_sayisi > 4'd8) ? 4'd8 : ayar_blok_sayisi; tip <= is_tipi; t_lin <= (is_tipi == 3'd0); t_qk <= (is_tipi == 3'd1); t_pv <= (is_tipi == 3'd2); t_ln <= (is_tipi == 3'd3); t_att <= (is_tipi == 3'd1) || (is_tipi == 3'd2); tg <= taban_giris; ti <= taban_ikinci; tc <= taban_cikis; lnk <= ln_no; ln_y_yaz_k <= ln_y_yaz; ln_taban_y_k <= ln_taban_y;
            devrik_k <= (is_tipi == 3'd0) && devrik_yaz; isyeri <= 1'b1; basla_d <= 1'b1;
        end else if (bitti_ic) isyeri <= 1'b0;
    end

    // ---------------- gomulu parametre ve tablo yukleyiciler ----------------
    wire [11:0] rom_adres; wire [31:0] rom_bias, rom_m0;
    parametre_rom u_rom (.clk(clk), .adres(rom_adres), .bias(rom_bias), .m0(rom_m0));
    wire        p_yaz_etkin_y, p_yaz_tampon_y; wire [1:0] p_yaz_secici_y; wire [10:0] p_yaz_adres_y; wire [63:0] p_yaz_veri_y; wire p_mesgul;
    panel_parametre_yukleyici u_param (.clk(clk), .rst(rst), .basla(param_basla), .taban(param_taban), .tampon(param_tampon),
        .rom_adres(rom_adres), .rom_bias(rom_bias), .rom_m0(rom_m0),
        .panel_yaz_etkin(p_yaz_etkin_y), .panel_yaz_tampon(p_yaz_tampon_y), .panel_yaz_secici(p_yaz_secici_y), .panel_yaz_adres(p_yaz_adres_y), .panel_yaz_veri(p_yaz_veri_y),
        .mesgul(p_mesgul), .bitti(param_bitti));
    wire        g_yaz_etkin; wire [7:0] g_yaz_adres, g_yaz_veri;
    gelu_yukleyici u_tablo (.clk(clk), .rst(rst), .basla(tablo_basla), .tablo_sec(tablo_sec),
        .gelu_yaz_etkin(g_yaz_etkin), .gelu_yaz_adres(g_yaz_adres), .gelu_yaz_veri(g_yaz_veri), .mesgul(tablo_mesgul), .bitti(tablo_bitti));

    // ---------------- panel kopyalayici (K / V paneli: aktivasyon belleğinden) ----------------
    wire        pk_yaz_etkin, pk_yaz_tampon; wire [1:0] pk_yaz_secici; wire [10:0] pk_yaz_adres; wire [63:0] pk_yaz_veri;
    wire        pk_mesgul, pk_bitti;
    reg         pk_basla; reg [12:0] pk_kaynak; reg pk_tampon;
    wire [12:0] k_oku_adres; wire [63:0] k_oku_veri;
    panel_kopyalayici #(.K_UZUNLUK(64), .KAYNAK_AW(13), .K_DINAMIK(1)) u_kop (.clk(clk), .rst(rst), .basla(pk_basla), .k_uz(t_pv ? {3'b000, kmax} : 10'd64), .k_pad(t_pv ? {3'b000, kpv} : 10'd64), .kaynak_adres(pk_kaynak), .tampon(pk_tampon),
        .k_oku_adres(k_oku_adres), .k_oku_veri(k_oku_veri),
        .panel_yaz_etkin(pk_yaz_etkin), .panel_yaz_tampon(pk_yaz_tampon), .panel_yaz_secici(pk_yaz_secici), .panel_yaz_adres(pk_yaz_adres), .panel_yaz_veri(pk_yaz_veri),
        .mesgul(pk_mesgul), .bitti(pk_bitti));

    // ---------------- panel tamponu: kopyalayici | gomulu parametre | agirlik sozcugu ----------------
    // 0. hattin yonga ici agirlik kopyalayicisi (AGIRLIK_ROM=1)
    wire        r0_yaz_etkin, r0_yaz_tampon; wire [1:0] r0_yaz_secici; wire [10:0] r0_yaz_adres; wire [63:0] r0_yaz_veri;
    generate if (AGIRLIK_ROM != 0) begin : g_rom0
        wire [15:0] r0_oku_adres; wire [63:0] r0_oku_veri; wire r0_mesgul;
        agirlik_rom_banka #(.DOSYA("agirlik_rom_b0.mem"), .D(ROM_D), .AW(16)) u_rom0 (.clk(clk), .adres(r0_oku_adres), .veri(r0_oku_veri));
        panel_kopyalayici #(.K_UZUNLUK(512), .KAYNAK_AW(16), .K_DINAMIK(1)) u_rk0 (.clk(clk), .rst(rst), .basla(agr_basla), .k_uz(agr_k[9:0]), .k_pad(10'd0),
            .kaynak_adres(agr_adres), .tampon(agr_tampon), .k_oku_adres(r0_oku_adres), .k_oku_veri(r0_oku_veri),
            .panel_yaz_etkin(r0_yaz_etkin), .panel_yaz_tampon(r0_yaz_tampon), .panel_yaz_secici(r0_yaz_secici), .panel_yaz_adres(r0_yaz_adres), .panel_yaz_veri(r0_yaz_veri),
            .mesgul(r0_mesgul), .bitti(agr_bitti));
    end else begin : g_rom0_yok
        assign r0_yaz_etkin = 1'b0; assign r0_yaz_tampon = 1'b0; assign r0_yaz_secici = 2'd0; assign r0_yaz_adres = 11'd0; assign r0_yaz_veri = 64'd0;
        assign agr_bitti = 1'b0;
    end endgenerate
    wire        pk_etkin_l0 = pk_yaz_etkin & ((ATTP == 0) | (kop_p == 4'd0));      // ATTP: kopyalar yalniz hedef hattin tamponuna gider
    wire        panel_yaz_etkin  = pk_etkin_l0 | r0_yaz_etkin | p_yaz_etkin_y | w_yaz_etkin;
    wire        panel_yaz_tampon = pk_etkin_l0 ? pk_yaz_tampon : (r0_yaz_etkin ? r0_yaz_tampon : (p_yaz_etkin_y ? p_yaz_tampon_y : w_yaz_tampon));
    wire [1:0]  panel_yaz_secici = pk_etkin_l0 ? pk_yaz_secici : (r0_yaz_etkin ? r0_yaz_secici : (p_yaz_etkin_y ? p_yaz_secici_y : 2'd0));
    wire [10:0] panel_yaz_adres  = pk_etkin_l0 ? pk_yaz_adres  : (r0_yaz_etkin ? r0_yaz_adres  : (p_yaz_etkin_y ? p_yaz_adres_y  : w_yaz_adres));
    wire [63:0] panel_yaz_veri   = pk_etkin_l0 ? pk_yaz_veri   : (r0_yaz_etkin ? r0_yaz_veri   : (p_yaz_etkin_y ? p_yaz_veri_y   : w_yaz_veri));
    wire        panel_oku_tampon; wire [10:0] panel_oku_adres; wire [63:0] panel_oku_veri;
    wire        sorgu_tampon; wire [2:0] sorgu_kanal; wire [31:0] sorgu_bias; wire [30:0] sorgu_m0;
    panel_tamponu #(.K_ENFAZLA(512), .K_GENISLIGI(11)) u_panel_tamponu (.clk(clk), .panel_yaz_etkin(panel_yaz_etkin), .panel_yaz_tampon(panel_yaz_tampon), .panel_yaz_secici(panel_yaz_secici),
        .panel_yaz_adres(panel_yaz_adres), .panel_yaz_veri(panel_yaz_veri), .agirlik_oku_tampon(panel_oku_tampon), .agirlik_oku_adres(panel_oku_adres), .agirlik_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias), .sorgu_m0(sorgu_m0));

    // ---------------- birlesik aktivasyon belleği (iki okuma portlu) ----------------
    wire [11:0] akt_oku_adres_g;
    wire [63:0] bellek_oku_veri;
    wire [12:0] ln_oku_adres; wire ln_yaz_etkin; wire [12:0] ln_yaz_adres; wire [63:0] ln_yaz_veri;
    wire        n_yaz_etkin, d_yaz_etkin; wire [11:0] n_yaz_adres, d_yaz_adres; wire [63:0] n_yaz_veri, d_yaz_veri;
    reg         sm_p_yaz_etkin; reg [8:0] sm_p_yaz_adres; reg [63:0] sm_p_yaz_veri;
    wire        c0_etkin = devrik_k ? d_yaz_etkin : n_yaz_etkin;               // 0. hattin cikis sozcugu (normal / devrik)
    wire [11:0] c0_adres = devrik_k ? d_yaz_adres : n_yaz_adres;
    wire [63:0] c0_veri  = devrik_k ? d_yaz_veri  : n_yaz_veri;
    wire        c_yaz_etkin;
    wire [11:0] c_yaz_adres;
    wire [63:0] c_yaz_veri;
    reg         arb_etkin;                                                      // NA>1: hatlarin FIFO'larindan siralanan sozcuk
    reg  [75:0] arb_veri;
    wire [NA-1:0] fifo_bos_v;
    wire [7:0]    hs_et;                      // ATTP: hat basina Q.K^T skor yazma isaretleri (hat 0 cekirdekten)
    wire [23:0]   hs_tk;
    wire [47:0]   hs_ad;
    wire [127:0]  hs_vr;
    wire [NA-1:0] tasma_ek_v;
    generate if (NA == 1) begin : g_yaz1
        assign c_yaz_etkin = c0_etkin; assign c_yaz_adres = c0_adres; assign c_yaz_veri = c0_veri;
        assign fifo_bos_v = 1'b1; assign tasma_ek_v = 1'b0;
        assign hs_et[7:1] = 7'd0; assign hs_tk[23:3] = 21'd0; assign hs_ad[47:6] = 42'd0; assign hs_vr[127:16] = 112'd0;
        initial begin arb_etkin = 1'b0; arb_veri = 76'd0; end
    end else begin : g_yazN
        assign c_yaz_etkin = (c0_etkin & ~(t_lin | ((ATTP != 0) & t_pv))) | arb_etkin;                  // dikkat baglami dogrudan, dogrusal satirlar FIFO uzerinden
        assign c_yaz_adres = arb_etkin ? arb_veri[75:64] : c0_adres;
        assign c_yaz_veri  = arb_etkin ? arb_veri[63:0]  : c0_veri;
    end endgenerate
    wire        b_yaz_etkin = c_yaz_etkin | sm_p_yaz_etkin | ln_yaz_etkin | (dis_yaz_etkin & ~isyeri);
    wire [12:0] b_yaz_adres = c_yaz_etkin ? (tc + {1'b0, c_yaz_adres}) : sm_p_yaz_etkin ? (tc + {4'd0, sm_p_yaz_adres}) : ln_yaz_etkin ? ln_yaz_adres : dis_yaz_adres;
    wire [63:0] b_yaz_veri  = c_yaz_etkin ? c_yaz_veri : sm_p_yaz_etkin ? sm_p_yaz_veri : ln_yaz_etkin ? ln_yaz_veri : dis_yaz_veri;
    // A operandi adresi = taban + tile adresi. Tum tabanlar 512'nin kati (0, 1024, 1536, 4096, 5120), bu yuzden alt 9 bit toplamaya girmez:
    // toplama yalniz ust 4 bitte (13 bitlik tam toplayici yerine; kritik yolu kisaltir)
    wire [12:0] akt_adres_tg = {tg[12:9] + {1'b0, akt_oku_adres_g[11:9]}, akt_oku_adres_g[8:0]};
    // synthesis translate_off
    always @(posedge clk) if (isyeri && !t_ln && tg[8:0] != 9'd0) $display("HATA: taban_giris 512'nin kati degil (%0d); adres toplami dar toplayici ile yanlis olur", tg);
    // synthesis translate_on
    wire [12:0] b_oku1_adres = isyeri ? (t_ln ? ln_oku_adres : akt_adres_tg) : dis_oku_adres;
    birlesik_bellek_2o #(.BIRIM_SAYISI(6), .AW(13)) u_bellek (.clk(clk), .yaz_etkin(b_yaz_etkin), .yaz_adres(b_yaz_adres), .yaz_veri(b_yaz_veri),
        .oku1_etkin(isyeri & (t_ln | tile_mesgul)), .oku1_adres(b_oku1_adres), .oku1_veri(bellek_oku_veri), .oku2_etkin(pk_mesgul), .oku2_adres(k_oku_adres), .oku2_veri(k_oku_veri), .catisma(bellek_catisma));
    assign dis_oku_veri = bellek_oku_veri;

    // ---------------- tile denetleyici + dizi (TEK) ----------------
    reg         calistir_att;
    reg  [1:0]  ph_att;
    wire        calistir_t = (basla_d & t_lin) | calistir_att;
    wire [1:0]  panel_hazir_t = t_att ? ph_att : panel_hazir;
    wire        tile_bitti;
    wire        tasma_l0;
    assign tasma_hatasi = tasma_l0 | (|tasma_ek_v);
    wire        cikis_gecerli, cikis_tile_son;
    wire [2:0]  cikis_token, cikis_kanal;
    wire [3:0]  cikis_blok;
    wire [6:0]  cikis_panel;
    wire signed [31:0] cikis_birikec;
    tile_denetleyici #(.DIZI_BOYUTU(8), .BLOK_SAYISI(8), .K_GENISLIGI(11), .PANEL_GENISLIGI(7), .ADRES_GENISLIGI(12)) u_tile (
        .clk(clk), .rst(rst), .calistir(calistir_t), .ayar_k(t_pv ? {4'b0000, kpv} : (t_qk ? 11'd64 : ayar_k)), .ayar_panel_sayisi(((ATTP != 0) & t_att) ? 7'd1 : (t_qk ? {3'b000, nb_k} : (t_pv ? 7'd8 : npg_lin))),
        .ayar_blok_sayisi(nb_k), .a_isaretsiz(t_pv),
        .mesgul(tile_mesgul), .katman_bitti(tile_bitti), .panel_hazir(panel_hazir_t), .panel_bitti(panel_bitti),
        .panel_bitti_tampon(panel_bitti_tampon), .aktivasyon_oku_adres(akt_oku_adres_g), .aktivasyon_oku_veri(bellek_oku_veri),
        .panel_oku_tampon(panel_oku_tampon), .panel_oku_adres(panel_oku_adres), .panel_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias),
        .cikis_gecerli(cikis_gecerli), .cikis_token(cikis_token), .cikis_kanal(cikis_kanal), .cikis_blok(cikis_blok), .cikis_panel(cikis_panel),
        .cikis_tile_son(cikis_tile_son), .cikis_birikec(cikis_birikec), .cikis_tasma(tasma_l0));

    // ---------------- yeniden olcekleme (TEK carpma devresi; dort is turu sirayla kullanir) ----------------
    reg [30:0] m0_g1, m0_g2;
    always @(posedge clk) begin m0_g1 <= sorgu_m0; m0_g2 <= m0_g1; end
    wire        ln_rs_gir_gecerli, ln_rs_genis; wire signed [31:0] ln_rs_gir_veri; wire [30:0] ln_rs_m0; wire [5:0] ln_rs_n; wire [7:0] ln_rs_meta_gir;
    wire        rs_gecerli, rs_kirp; wire signed [31:0] rs_veri; wire [17:0] rs_meta;
    assign hs_et[0] = rs_gecerli & t_qk; assign hs_tk[2:0] = rs_meta[16:14]; assign hs_ad[5:0] = {rs_meta[9:7], rs_meta[13:11]}; assign hs_vr[15:0] = rs_veri[15:0];
    yeniden_olcekle_ortak #(.META_W(18)) u_rs (.clk(clk), .rst(rst),
        .genis(t_ln ? ln_rs_genis : t_qk),
        .giris_gecerli(t_ln ? ln_rs_gir_gecerli : cikis_gecerli),
        .birikec(t_ln ? ln_rs_gir_veri : cikis_birikec),
        .olcek_m0(t_ln ? ln_rs_m0 : (t_lin ? m0_g2 : ayar_m0)),
        .kaydirma(t_ln ? ln_rs_n : ayar_kaydirma),
        .yan_bilgi_giris(t_ln ? {10'd0, ln_rs_meta_gir} : {cikis_tile_son, cikis_token, cikis_kanal, cikis_blok, cikis_panel}),
        .cikis_gecerli(rs_gecerli), .cikis_veri(rs_veri), .yan_bilgi_cikis(rs_meta), .kirpildi(rs_kirp));
    wire signed [7:0] olcekli_cikis = rs_veri[7:0];

    // ---------------- GELU / tanh tablosu (dogrusal) ----------------
    wire signed [7:0] gelu_cikis;
    gelu_tablosu u_gelu_tablosu (.clk(clk), .gelu_yaz_etkin(g_yaz_etkin), .gelu_yaz_adres(g_yaz_adres), .gelu_yaz_veri(g_yaz_veri), .giris_int8(olcekli_cikis), .cikis_int8(gelu_cikis));
    wire signed [7:0] son_cikis = (t_lin && gelu_etkin) ? gelu_cikis : olcekli_cikis;

    // ---------------- sozcuk toplayicilar: dogrusal (normal / devrik) ve P.V baglami ----------------
    wire        topla_gecerli = rs_gecerli & (t_lin | t_pv);
    cikis_sozcuk_toplayici #(.ADRES_GENISLIGI(12), .PANEL_GENISLIGI(7)) u_toplayici (
        .clk(clk), .rst(rst), .gecerli(topla_gecerli), .veri_int8(son_cikis),
        .token_sirasi(rs_meta[16:14]), .kanal_sirasi(rs_meta[13:11]), .blok_no(rs_meta[10:7]), .panel_no(t_lin ? (rs_meta[6:0] << LOG2NA) : (rs_meta[6:0] + (t_pv ? cikis_panel_ofset : 7'd0))),
        .kanal_toplami(t_pv ? baglam_kanal : {ayar_panel_sayisi, 3'b000}), .yaz_etkin(n_yaz_etkin), .yaz_adres(n_yaz_adres), .yaz_veri(n_yaz_veri));
    cikis_sozcuk_toplayici_devrik #(.ADRES_GENISLIGI(12), .PANEL_GENISLIGI(7)) u_devrik (
        .clk(clk), .rst(rst), .gecerli(rs_gecerli & t_lin), .veri_int8(son_cikis),
        .token_sirasi(rs_meta[16:14]), .kanal_sirasi(rs_meta[13:11]), .blok_no(rs_meta[10:7]), .panel_no(rs_meta[6:0] << LOG2NA),
        .yaz_etkin(d_yaz_etkin), .yaz_adres(d_yaz_adres), .yaz_veri(d_yaz_veri));

    // ---------------- paralel dogrusal hatlar (NA > 1) ve cikis siralayici ----------------
    generate if (NA > 1) begin : g_na
        wire [NA-1:0] pop_v;
        wire [76*NA-1:0] fifo_cikis;
        wire [NA-1:0] tasma_ff;
        yaz_fifo #(.W(76)) u_ff0 (.clk(clk), .rst(rst), .yaz(c0_etkin & (t_lin | ((ATTP != 0) & t_pv))), .giris({c0_adres, c0_veri}), .oku(pop_v[0]), .cikis(fifo_cikis[0 +: 76]), .bos(fifo_bos_v[0]), .tasma(tasma_ff[0]));
        assign tasma_ek_v[0] = tasma_ff[0];
        assign pop_v[0] = ~fifo_bos_v[0];
        genvar h;
        for (h = 1; h < NA; h = h + 1) begin : g_h
            localparam [7:0] HC = 8'd48 + h;
            wire        h_etkin; wire [11:0] h_adr; wire [63:0] h_dat; wire h_tasma, h_rom_bitti, h_param_bitti;
            wire        h_sk_et; wire [2:0] h_sk_tk; wire [5:0] h_sk_ad; wire signed [15:0] h_sk_vr;
            assign hs_et[h] = h_sk_et; assign hs_tk[3*h +: 3] = h_sk_tk; assign hs_ad[6*h +: 6] = h_sk_ad; assign hs_vr[16*h +: 16] = h_sk_vr;
            ek_hat #(.HAT(h), .LOG2NA(LOG2NA), .ROM_DOSYA({"agirlik_rom_b", HC, ".mem"}), .ROM_D(ROM_D)) u_hat (
                .clk(clk), .rst(rst), .calistir(basla_d & t_lin), .ayar_k(ayar_k), .ayar_panel_grup(npg_lin), .ayar_panel_gercek(ayar_panel_sayisi),
                .ayar_blok_sayisi(nb_k), .ayar_kaydirma(ayar_kaydirma), .gelu_etkin(gelu_etkin), .devrik_k(devrik_k), .panel_hazir(panel_hazir), .a_veri(bellek_oku_veri),
                .rom_basla(agr_basla), .rom_adres(agr_adres), .rom_tampon(agr_tampon), .rom_k(agr_k[9:0]), .rom_bitti(h_rom_bitti),
                .param_basla(param_basla), .param_taban(param_taban + (h * 8)), .param_tampon(param_tampon), .param_bitti(h_param_bitti),
                .g_yaz_etkin(g_yaz_etkin), .g_yaz_adres(g_yaz_adres), .g_yaz_veri(g_yaz_veri),
                .yaz_etkin(h_etkin), .yaz_adres(h_adr), .yaz_veri(h_dat), .tasma(h_tasma),
                .att_modu((ATTP != 0) & t_att), .att_qk(t_qk), .att_pv(t_pv), .att_calistir(calistir_att), .att_k(t_pv ? {4'b0000, kpv} : 11'd64), .att_panel_hazir(ph_att),
                .att_m0(ayar_m0), .att_ofs(cikis_panel_ofset), .att_kanal_toplami(baglam_kanal),
                .att_yaz_etkin(pk_yaz_etkin & (kop_p == h)), .att_yaz_tampon(pk_yaz_tampon), .att_yaz_secici(pk_yaz_secici), .att_yaz_adres(pk_yaz_adres), .att_yaz_veri(pk_yaz_veri),
                .sk_etkin(h_sk_et), .sk_token(h_sk_tk), .sk_adres(h_sk_ad), .sk_veri(h_sk_vr));
            yaz_fifo #(.W(76)) u_ff (.clk(clk), .rst(rst), .yaz(h_etkin), .giris({h_adr, h_dat}), .oku(pop_v[h]), .cikis(fifo_cikis[h*76 +: 76]), .bos(fifo_bos_v[h]), .tasma(tasma_ff[h]));
            assign pop_v[h] = ~fifo_bos_v[h] & (&fifo_bos_v[h-1:0]);
            assign tasma_ek_v[h] = h_tasma | tasma_ff[h];
        end
        reg [75:0] sec;
        integer q;
        always @* begin
            sec = 76'd0;
            for (q = 0; q < NA; q = q + 1) if (pop_v[q]) sec = sec | fifo_cikis[q*76 +: 76];
        end
        always @(posedge clk) begin
            if (rst) begin arb_etkin <= 1'b0; arb_veri <= 76'd0; end
            else begin arb_etkin <= |pop_v; arb_veri <= sec; end
        end
    end endgenerate

    // ---------------- Q.K^T skor tamponu: 64 x 64 x 16 bit ----------------
    reg signed [15:0] skor_ram [0:4095];
    wire [11:0] skor_yaz_adres = {rs_meta[9:7], rs_meta[16:14], rs_meta[2:0], rs_meta[13:11]};
    reg  [11:0] skor_ic_adres;
    reg  signed [15:0] skor_ic_veri;
    always @(posedge clk) begin
        if (rs_gecerli && t_qk) skor_ram[skor_yaz_adres] <= rs_veri[15:0];
        skor_ic_veri  <= skor_ram[skor_ic_adres];
        if (rst || basla) skor_tasma <= 1'b0;
        else if (rs_gecerli && t_qk && (rs_veri > 32'sd32767 || rs_veri < -32'sd32768)) skor_tasma <= 1'b1;
    end

    // ---------------- Softmax (gomulu ustel tablo) ----------------
    reg         sm_baslat, sm_giris_gecerli, sm_giris_maske;
    reg         gir_gecerli_d, gir_gecerli_d2;
    reg  signed [31:0] sm_giris_veri;
    wire        sm_giris_hazir, sm_cikis_gecerli, sm_cikis_son, sm_mesgul;
    wire [7:0]  sm_cikis_veri;
    reg  [11:0] skor_blk_adres;                                    // SMP: bankalarin ortak okuma adresi {blok, sutun}
    reg  [127:0] att_oku_bus;                                      // ATTP: 8 token'in ayni sutundaki skoru (hat bankalarindan, 1 cevrim gecikmeli)
    generate if (ATTP != 0) begin : g_attsk
        wire [8*8*16-1:0] rd_all;
        genvar p, tk;
        for (p = 0; p < 8; p = p + 1) begin : g_p
            for (tk = 0; tk < 8; tk = tk + 1) begin : g_t
                reg signed [15:0] m [0:63];                            // hat p (panel p) bankasi, token tk: {blok, kanal}
                always @(posedge clk) if (hs_et[p] && hs_tk[3*p +: 3] == tk) m[hs_ad[6*p +: 6]] <= hs_vr[16*p +: 16];
                assign rd_all[(p*8+tk)*16 +: 16] = m[{skor_blk_adres[8:6], skor_blk_adres[2:0]}];
            end
        end
        integer q;
        always @(posedge clk) begin
            for (q = 0; q < 8; q = q + 1) att_oku_bus[16*q +: 16] <= rd_all[(skor_blk_adres[5:3]*8 + q)*16 +: 16];
        end
    end else begin : g_attsk_yok
        initial att_oku_bus = 128'd0;
    end endgenerate
    wire [63:0] sm_kelime;                                         // SMP: 8 birimin ayni sutunu (bayt i = birim i)
    generate if (SMP == 0) begin : g_sm1
        softmax_birim_gomulu #(.SATIR_UZUNLUGU(64), .TABLO_DOSYASI("exp_l0.mem"), .DINAMIK(1)) u_sm (.clk(clk), .rst(rst), .olcek_m0(ayar_m0_sm), .baslat(sm_baslat), .satir_uz(kmax),
            .giris_hazir(sm_giris_hazir), .giris_gecerli(sm_giris_gecerli), .giris_veri(sm_giris_veri), .giris_maske(sm_giris_maske),
            .cikis_gecerli(sm_cikis_gecerli), .cikis_veri(sm_cikis_veri), .cikis_son(sm_cikis_son), .mesgul(sm_mesgul));
        assign sm_kelime = 64'd0;
    end else begin : g_sm8
        wire [7:0] hz, cg, cs, ms;
        genvar b;
        for (b = 0; b < 8; b = b + 1) begin : g_b
            reg signed [15:0] sk [0:511];                          // bankada yalniz token_sirasi == b olan satirlar: {blok, panel, kanal}
            reg signed [15:0] oku;
            reg signed [31:0] gv;
            wire [7:0] cv;
            always @(posedge clk) begin
                if (rs_gecerli && t_qk && rs_meta[16:14] == b) sk[{rs_meta[9:7], rs_meta[2:0], rs_meta[13:11]}] <= rs_veri[15:0];
                oku <= sk[skor_blk_adres[8:0]];
                if (gir_gecerli_d2) gv <= (ATTP != 0) ? {{16{att_oku_bus[16*b+15]}}, att_oku_bus[16*b +: 16]} : {{16{oku[15]}}, oku};
            end
            softmax_birim_gomulu #(.SATIR_UZUNLUGU(64), .TABLO_DOSYASI("exp_l0.mem"), .DINAMIK(1)) u_sm (.clk(clk), .rst(rst), .olcek_m0(ayar_m0_sm), .baslat(sm_baslat), .satir_uz(kmax),
                .giris_hazir(hz[b]), .giris_gecerli(sm_giris_gecerli), .giris_veri(gv), .giris_maske(sm_giris_maske),
                .cikis_gecerli(cg[b]), .cikis_veri(cv), .cikis_son(cs[b]), .mesgul(ms[b]));
            assign sm_kelime[8*b +: 8] = cv;
        end
        assign sm_giris_hazir = hz[0]; assign sm_cikis_gecerli = cg[0]; assign sm_cikis_son = cs[0]; assign sm_mesgul = ms[0]; assign sm_cikis_veri = 8'd0;
    end endgenerate

    reg [7:0]  pbuf [0:511];
    reg [6:0]  cikis_say;
    reg [2:0]  satir_mod;
    reg        satir_tamam;
    wire       att_basla = basla_d & t_att;
    always @(posedge clk) begin
        satir_tamam <= 1'b0;
        if (rst || att_basla) cikis_say <= 7'd0;
        else if (sm_cikis_gecerli) begin
            pbuf[{satir_mod, cikis_say[5:0]}] <= sm_cikis_veri;
            cikis_say <= (cikis_say == kmax - 7'd1) ? 7'd0 : cikis_say + 7'd1;
            if (sm_cikis_son) satir_tamam <= 1'b1;
        end
    end

    // ---------------- artik toplama + LayerNorm (ortak carpma devresini kullanir) ----------------
    wire ln_bitti;
    generate if (LN_PAR != 0) begin : g_lnp
        artik_ln_par u_ln (.clk(clk), .rst(rst), .basla(basla_d & t_ln), .ln_no(lnk), .taban_x(tg), .taban_a(ti), .taban_cikis(tc), .y_yaz(ln_y_yaz_k), .taban_cikis_y(ln_taban_y_k), .ayar_blok_sayisi(nb_k),
            .mesgul(), .bitti(ln_bitti), .oku_adres(ln_oku_adres), .oku_veri(bellek_oku_veri),
            .yaz_etkin(ln_yaz_etkin), .yaz_adres(ln_yaz_adres), .yaz_veri(ln_yaz_veri), .tasma(ln_tasma));
        assign ln_rs_gir_gecerli = 1'b0; assign ln_rs_genis = 1'b0; assign ln_rs_gir_veri = 32'sd0; assign ln_rs_m0 = 31'd0; assign ln_rs_n = 6'd0; assign ln_rs_meta_gir = 8'd0;
    end else begin : g_lns
        artik_ln_ortak u_ln (.clk(clk), .rst(rst), .basla(basla_d & t_ln), .ln_no(lnk), .taban_x(tg), .taban_a(ti), .taban_cikis(tc), .y_yaz(ln_y_yaz_k), .taban_cikis_y(ln_taban_y_k), .ayar_blok_sayisi(nb_k),
            .mesgul(), .bitti(ln_bitti), .oku_adres(ln_oku_adres), .oku_veri(bellek_oku_veri),
            .yaz_etkin(ln_yaz_etkin), .yaz_adres(ln_yaz_adres), .yaz_veri(ln_yaz_veri), .tasma(ln_tasma),
            .rs_gir_gecerli(ln_rs_gir_gecerli), .rs_genis(ln_rs_genis), .rs_gir_veri(ln_rs_gir_veri), .rs_m0(ln_rs_m0), .rs_n(ln_rs_n), .rs_meta_gir(ln_rs_meta_gir),
            .rs_cik_gecerli(rs_gecerli & t_ln), .rs_cik_veri(rs_veri), .rs_meta_cik(rs_meta[7:0]));
    end endgenerate

    // ---------------- dikkat denetimi (Q.K^T + Softmax ve P.V) ----------------
    localparam D_BOS = 4'd0, D_P0 = 4'd1, D_P0W = 4'd2, D_P1 = 4'd3, D_P1W = 4'd4, D_CAL = 4'd5, D_KOS = 4'd6, D_AKIT = 4'd7,
               S_BASLAT = 4'd8, S_HAZIR = 4'd9, S_GIRIS = 4'd10, S_BEKLE = 4'd11, S_YAZ = 4'd12,
               P_BASLAT = 5'd16, P_HAZIR = 5'd17, P_GIRIS = 5'd18, P_BEKLE = 5'd19, P_YAZ = 5'd20,
               A_K0 = 5'd21, A_K1 = 5'd22, A_CAL = 5'd23, A_KOS = 5'd24, A_PVS = 5'd25;
    reg [4:0]  durum;
    reg [3:0]  blk_p;                    // SMP: islenen token blogu
    reg [3:0]  yuklenen;
    reg [1:0]  bos;
    reg        kop_mesgul, kop_tampon;
    reg [3:0]  akit_say;
    reg [6:0]  satir;
    reg [6:0]  gir_say;
    reg [6:0]  gir_idx_d, gir_idx_d2;
    reg [6:0]  yaz_say;
    reg        att_bitti;
    function [12:0] kaynak_panel; input [3:0] p; begin kaynak_panel = ti + {p, 6'd0}; end endfunction
    reg [1:0] ph;
    wire [3:0] np_att = t_qk ? nb_k : 4'd8;   // panel sayisi: Q.K^T'de anahtar bloklari (nb), P.V'de deger kanal panelleri (8)
    reg [8:0]  grup_taban;                     // P.V'de olasilik bellegi: 8 satirlik grubun taban adresi = grup*8*nb

    always @(posedge clk) begin
        pk_basla <= 1'b0; calistir_att <= 1'b0; sm_baslat <= 1'b0; att_bitti <= 1'b0; sm_p_yaz_etkin <= 1'b0; sm_giris_gecerli <= 1'b0;
        if (rst) begin
            durum <= D_BOS; ph_att <= 2'b00; bos <= 2'b00; yuklenen <= 0; kop_mesgul <= 1'b0; kop_tampon <= 1'b0; satir <= 0; satir_mod <= 0;
            gir_gecerli_d <= 1'b0; gir_gecerli_d2 <= 1'b0; grup_taban <= 9'd0; skor_ic_adres <= 0; pk_kaynak <= 0; pk_tampon <= 1'b0;
        end else begin
            ph = ph_att;
            if (panel_bitti && t_att) begin ph[panel_bitti_tampon] = 1'b0; bos[panel_bitti_tampon] <= 1'b1; end
            if (pk_bitti && kop_mesgul) begin ph[kop_tampon] = 1'b1; kop_mesgul <= 1'b0; end
            ph_att <= ph;

            case (durum)
                D_BOS: if (att_basla) begin yuklenen <= 0; bos <= 2'b00; satir <= 0; satir_mod <= 0; kop_p <= 4'd0; durum <= (ATTP != 0) ? A_K0 : D_P0; end
                D_P0: begin pk_basla <= 1'b1; pk_kaynak <= kaynak_panel(4'd0); pk_tampon <= 1'b0; kop_mesgul <= 1'b1; kop_tampon <= 1'b0; yuklenen <= 4'd1; durum <= D_P0W; end
                D_P0W: if (pk_bitti) durum <= (np_att == 4'd1) ? D_CAL : D_P1;
                D_P1: begin pk_basla <= 1'b1; pk_kaynak <= kaynak_panel(4'd1); pk_tampon <= 1'b1; kop_mesgul <= 1'b1; kop_tampon <= 1'b1; yuklenen <= 4'd2; durum <= D_P1W; end
                D_P1W: if (pk_bitti) durum <= D_CAL;
                D_CAL: begin calistir_att <= 1'b1; durum <= D_KOS; end
                D_KOS: begin
                    if (!kop_mesgul && yuklenen < np_att && bos[yuklenen[0]]) begin
                        pk_basla <= 1'b1; pk_kaynak <= kaynak_panel(yuklenen); pk_tampon <= yuklenen[0];
                        kop_mesgul <= 1'b1; kop_tampon <= yuklenen[0]; bos[yuklenen[0]] <= 1'b0; yuklenen <= yuklenen + 4'd1;
                    end
                    if (tile_bitti) begin akit_say <= 4'd0; durum <= D_AKIT; end
                end
                D_AKIT: begin
                    akit_say <= akit_say + 4'd1;
                    if (akit_say == 4'd12) begin
                        if (t_pv) begin if (ATTP != 0) durum <= A_PVS; else begin att_bitti <= 1'b1; durum <= D_BOS; end end
                        else begin satir <= 0; satir_mod <= 0; grup_taban <= 9'd0; blk_p <= 4'd0; durum <= (SMP != 0) ? P_BASLAT : S_BASLAT; end
                    end
                end
                S_BASLAT: begin sm_baslat <= 1'b1; gir_say <= 7'd0; durum <= S_HAZIR; end
                S_HAZIR: if (sm_giris_hazir) durum <= S_GIRIS;
                S_GIRIS: begin
                    if (gir_say < kmax) begin
                        skor_ic_adres <= {satir[5:0], gir_say[5:0]};
                        gir_gecerli_d <= 1'b1; gir_idx_d <= gir_say; gir_say <= gir_say + 7'd1;
                    end else gir_gecerli_d <= 1'b0;
                    if (gir_say == kmax && !gir_gecerli_d && !gir_gecerli_d2) durum <= S_BEKLE;
                end
                S_BEKLE: if (satir_tamam) begin
                    if (satir_mod == 3'd7) begin yaz_say <= 7'd0; durum <= S_YAZ; end
                    else begin satir <= satir + 7'd1; satir_mod <= satir_mod + 3'd1; durum <= S_BASLAT; end
                end
                S_YAZ: begin
                    sm_p_yaz_etkin <= 1'b1; sm_p_yaz_adres <= grup_taban + {3'b000, yaz_say[5:0]};
                    sm_p_yaz_veri <= (yaz_say < kmax) ? {pbuf[7*64 + yaz_say[5:0]], pbuf[6*64 + yaz_say[5:0]], pbuf[5*64 + yaz_say[5:0]], pbuf[4*64 + yaz_say[5:0]],
                                      pbuf[3*64 + yaz_say[5:0]], pbuf[2*64 + yaz_say[5:0]], pbuf[1*64 + yaz_say[5:0]], pbuf[0*64 + yaz_say[5:0]]} : 64'd0;   // kmax..kpv-1: sifir dolgu
                    if (yaz_say == kpv - 7'd1) begin
                        if (satir == kmax - 7'd1) begin att_bitti <= 1'b1; durum <= D_BOS; end
                        else begin satir <= satir + 7'd1; satir_mod <= 3'd0; grup_taban <= grup_taban + {2'b00, kpv}; durum <= S_BASLAT; end
                    end else yaz_say <= yaz_say + 7'd1;
                end
                // ---- ATTP: K^T / V panelleri hatlara sirayla kopyalanir (hat h = panel h), sonra tum hatlar birlikte hesaplar ----
                A_K0: begin pk_basla <= 1'b1; pk_kaynak <= kaynak_panel(kop_p); pk_tampon <= 1'b0; durum <= A_K1; end
                A_K1: if (pk_bitti) begin
                    if (kop_p + 4'd1 < np_att) begin kop_p <= kop_p + 4'd1; durum <= A_K0; end
                    else durum <= A_CAL;
                end
                A_CAL: begin calistir_att <= 1'b1; ph_att <= 2'b01; durum <= A_KOS; end
                A_KOS: if (tile_bitti) begin akit_say <= 4'd0; durum <= D_AKIT; end
                A_PVS: if ((&fifo_bos_v) && !arb_etkin) begin att_bitti <= 1'b1; durum <= D_BOS; end
                // ---- SMP: bir blogun 8 satiri 8 Softmax biriminde birlikte ----
                P_BASLAT: begin sm_baslat <= 1'b1; gir_say <= 7'd0; durum <= P_HAZIR; end
                P_HAZIR: if (sm_giris_hazir) durum <= P_GIRIS;
                P_GIRIS: begin
                    if (gir_say < kmax) begin
                        skor_blk_adres <= {3'b000, blk_p[2:0], gir_say[5:0]};
                        gir_gecerli_d <= 1'b1; gir_idx_d <= gir_say; gir_say <= gir_say + 7'd1;
                    end else gir_gecerli_d <= 1'b0;
                    if (gir_say == kmax && !gir_gecerli_d && !gir_gecerli_d2) durum <= P_BEKLE;
                end
                P_BEKLE: if (satir_tamam) begin
                    if (kpv > kmax) begin yaz_say <= kmax; durum <= P_YAZ; end
                    else if (blk_p == nb_k - 4'd1) begin att_bitti <= 1'b1; durum <= D_BOS; end
                    else begin blk_p <= blk_p + 4'd1; grup_taban <= grup_taban + {2'b00, kpv}; durum <= P_BASLAT; end
                end
                P_YAZ: begin                                                // kmax..kpv-1 sifir dolgu sozcukleri
                    sm_p_yaz_etkin <= 1'b1; sm_p_yaz_adres <= grup_taban + {3'b000, yaz_say[5:0]}; sm_p_yaz_veri <= 64'd0;
                    if (yaz_say == kpv - 7'd1) begin
                        if (blk_p == nb_k - 4'd1) begin att_bitti <= 1'b1; durum <= D_BOS; end
                        else begin blk_p <= blk_p + 4'd1; grup_taban <= grup_taban + {2'b00, kpv}; durum <= P_BASLAT; end
                    end else yaz_say <= yaz_say + 7'd1;
                end
                default: durum <= D_BOS;
            endcase
            if (SMP != 0 && sm_cikis_gecerli) begin                           // 8 birimin ayni sutunu tek olasilik sozcugu
                sm_p_yaz_etkin <= 1'b1; sm_p_yaz_adres <= grup_taban + {3'b000, cikis_say[5:0]}; sm_p_yaz_veri <= sm_kelime;
            end

            gir_gecerli_d2 <= gir_gecerli_d; gir_idx_d2 <= gir_idx_d;
            if (gir_gecerli_d2) begin
                sm_giris_gecerli <= 1'b1; sm_giris_veri <= {{16{skor_ic_veri[15]}}, skor_ic_veri}; sm_giris_maske <= (gir_idx_d2 < uzunluk);
            end
        end
    end

    // ---------------- dogrusal katman bitisi: boru hatti ve toplayici bosalana kadar ertele ----------------
    reg [15:0] bg;
    always @(posedge clk) begin
        if (rst) bg <= 16'd0; else bg <= {bg[14:0], tile_bitti & t_lin};
        if (rst || basla_d) kirpilan_sayisi <= 32'd0;
        else if (rs_kirp && t_lin) kirpilan_sayisi <= kirpilan_sayisi + 32'd1;
    end
    wire lin_bitti_ham = t_lin & isyeri & (devrik_k ? bg[15] : bg[5]);
    reg  lin_bekle;                                                                  // NA>1: hatlarin FIFO'lari bosalana kadar bekle
    wire lin_bitti_na = lin_bekle & (&fifo_bos_v) & ~arb_etkin;
    always @(posedge clk) begin
        if (rst || basla_d) lin_bekle <= 1'b0;
        else if (lin_bitti_ham) lin_bekle <= 1'b1;
        else if (lin_bitti_na) lin_bekle <= 1'b0;
    end
    wire lin_bitti = (NA == 1) ? lin_bitti_ham : lin_bitti_na;
    assign bitti_ic = lin_bitti | att_bitti | ln_bitti;
endmodule
