// -----------------------------------------------------------------------------
// veri_yolu.v -- hizlandiricinin veri yolu: yazmaclar, bellekler ve islem birimleri
//
// Gelen baytlar once gelen bayt yazmacinda tutulur. Komut, uzunluk ve baslik alanlari ilgili yazmaclara, yuk sozcukleri
// sozcuk toplayiciya alinir; sozcuk tamamlaninca ilgili belleğe (aktivasyon, agirlik paneli, GELU tablosu, Softmax tablosu,
// LayerNorm parametreleri) veya birimin giris akisina yazilir. Hangi yazmacin/belleğin ne zaman degisecegini kontrol_birimi
// sinyalleri belirler; komut yazmaci ve baslik alanlari komut_cozucu'ye verilir, cozucunun veri alanlari bu modulde yazmaclara alinir.
// Islem birimleri (dogrusal katman, Softmax, LayerNorm) ve sonuc tamponlari bu modulun icindedir.
// Yanit baytlari da bu modulde uretilir (yanit yazmaclari, yanit CRC'si, verici yazmaci); siralamayi kontrol_birimi yapar.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module veri_yolu (
    input  wire         clk,
    input  wire         rst,
    // ---- UART bayt arayuzu ----
    input  wire         rx_gecerli,
    input  wire [7:0]   rx_veri,
    output reg          tx_gecerli,
    output reg  [7:0]   tx_veri,
    input  wire         tx_hazir,
    // ---- komut cozucuye ----
    output reg  [7:0]   komut_yazmaci,
    output wire [79:0]  baslik_yazmaci_cikis,
    output wire [15:0]  yuk_uzunlugu,
    output wire [3:0]   sozcuk_bayt_sirasi_cikis,
    // ---- komut cozucuden ----
    input  wire [3:0]   baslik_bayt_sayisi,
    input  wire [3:0]   sozcuk_bayt_sayisi,
    input  wire         komut_aktivasyon_yukle,
    input  wire         komut_panel_yukle,
    input  wire         komut_aktivasyon_oku,
    input  wire         komut_durum,
    input  wire         komut_softmax_tablo,
    input  wire         komut_softmax_veri,
    input  wire         komut_softmax_oku,
    input  wire         komut_layernorm_parametre,
    input  wire         komut_layernorm_veri,
    input  wire         komut_layernorm_oku,
    input  wire [10:0]  alan_ayar_k,
    input  wire [6:0]   alan_ayar_panel_sayisi,
    input  wire [5:0]   alan_ayar_kaydirma,
    input  wire [3:0]   alan_ayar_blok_sayisi,
    input  wire         alan_a_isaretsiz,
    input  wire         alan_gelu_etkin,
    input  wire         alan_panel_tampon,
    input  wire         alan_panel_gelu_tablosu,
    input  wire [1:0]   alan_panel_secici,
    input  wire [23:0]  alan_softmax_m0,
    input  wire [39:0]  alan_layernorm_epsilon,
    input  wire [30:0]  alan_layernorm_m0,
    input  wire [5:0]   alan_layernorm_kaydirma,
    input  wire [11:0]  alan_okuma_adresi,
    input  wire [15:0]  alan_okuma_adedi,
    input  wire [15:0]  alan_okuma_uzunlugu,
    // ---- kontrol birimine: bayraklar ----
    output wire         bayt_geldi,
    output wire         uzunluk_alt_sifir,
    output wire         gelen_bayt_sifir,
    output wire         baslik_bolgesinde,
    output wire         baslik_son_bayt,
    output wire         sozcuk_son_bayt,
    output wire         yuk_son_bayt,
    output wire         crc_dogru,
    output wire         tx_musait,
    output reg  [1:0]   yanit_turu,
    output wire         yanit_uzunluk_sifir,
    output wire         yanit_adet_sifir,
    output wire         yanit_bayt_son,
    output wire         yanit_sozcuk_bayt_son,
    output wire         yanit_son_sozcuk,
    // ---- kontrol biriminden: istek ----
    input  wire         komut_yukle,
    input  wire         crc_baslat,
    input  wire         crc_guncelle,
    input  wire         uzunluk_alt_yukle,
    input  wire         uzunluk_ust_yukle,
    input  wire         sayac_sifirla,
    input  wire         sayac_artir,
    input  wire         baslik_yaz,
    input  wire         adres_yakala,
    input  wire         sozcuk_topla,
    input  wire         sozcuk_yaz,
    input  wire         paket_say,
    input  wire         hata_say,
    input  wire         uygula_ayar,
    input  wire         uygula_calistir_temizle,
    input  wire         uygula_panel_hazir,
    input  wire         uygula_softmax_ayar,
    input  wire         uygula_layernorm_ayar,
    input  wire         uygula_akis_hatasi_temizle,
    input  wire         yanit_ack_yukle,
    input  wire         yanit_hata_yukle,
    input  wire [7:0]   yanit_hata_kodu,
    // ---- kontrol biriminden: birim darbeleri ----
    input  wire         calistir_darbesi,
    input  wire         softmax_iptal,
    input  wire         softmax_baslat,
    input  wire         layernorm_iptal,
    input  wire         layernorm_baslat,
    // ---- kontrol biriminden: yanit ----
    input  wire         yanit_yukle,
    input  wire         yanit_bayt_sun,
    input  wire [2:0]   yanit_bayt_secici,
    input  wire         yanit_crc_baslat,
    input  wire         yanit_crc_guncelle,
    input  wire         yanit_sayac_artir,
    input  wire         okuma_adres_ilk,
    input  wire         okuma_adres_sonraki,
    input  wire         yanit_sozcuk_yukle,
    input  wire         yanit_sozcuk_kaydir,
    input  wire         yanit_sozcuk_sayaci_artir,
    // ---- tanilama ----
    output reg  [15:0]  paket_sayisi,
    output reg  [15:0]  hata_sayisi
);
    function [7:0] crc8;
        input [7:0] onceki;
        input [7:0] bayt;
        reg [7:0] x;
        integer b;
        begin
            x = onceki ^ bayt;
            for (b = 0; b < 8; b = b + 1) x = x[7] ? ((x << 1) ^ 8'h07) : (x << 1);
            crc8 = x;
        end
    endfunction

    // =========================== istek yazmaclari ===========================
    reg [7:0]   gelen_bayt;                  // UART'tan gelen son bayt
    reg         gelen_bayt_var;              // gelen_bayt bu cevrimde yeni
    reg [15:0]  uzunluk_yazmaci;             // yuk uzunlugu
    reg [15:0]  yuk_sayaci;                  // yuk icinde simdiye kadar alinan bayt
    reg [7:0]   crc_yazmaci;
    reg [79:0]  baslik_yazmaci;              // yuk basindaki alanlar (bayt k = baslik_yazmaci[8k +: 8])
    reg [63:0]  sozcuk_toplayici;            // bellege yazilacak sozcuk (bayt0 = en dusuk)
    reg [3:0]   sozcuk_bayt_sirasi;          // sozcukte alinan bayt sayisi
    reg [15:0]  yazma_adresi;                // sozcuk yazma adresi (her sozcukte +1)

    wire [63:0] sozcuk_sonraki = sozcuk_toplayici | ({56'd0, gelen_bayt} << (8 * sozcuk_bayt_sirasi));

    assign bayt_geldi               = gelen_bayt_var;
    assign baslik_yazmaci_cikis     = baslik_yazmaci;
    assign yuk_uzunlugu             = uzunluk_yazmaci;
    assign sozcuk_bayt_sirasi_cikis = sozcuk_bayt_sirasi;
    assign uzunluk_alt_sifir        = (uzunluk_yazmaci[7:0] == 8'd0);
    assign gelen_bayt_sifir         = (gelen_bayt == 8'd0);
    assign baslik_bolgesinde        = (yuk_sayaci < {12'd0, baslik_bayt_sayisi});
    assign baslik_son_bayt          = (yuk_sayaci + 16'd1 == {12'd0, baslik_bayt_sayisi});
    assign sozcuk_son_bayt          = (sozcuk_bayt_sirasi + 4'd1 == sozcuk_bayt_sayisi);
    assign yuk_son_bayt             = (yuk_sayaci + 16'd1 == uzunluk_yazmaci);
    assign crc_dogru                = (gelen_bayt == crc_yazmaci);

    always @(posedge clk) begin
        if (rst) begin
            gelen_bayt <= 8'd0; gelen_bayt_var <= 1'b0; komut_yazmaci <= 8'd0; uzunluk_yazmaci <= 16'd0; yuk_sayaci <= 16'd0;
            crc_yazmaci <= 8'd0; baslik_yazmaci <= 80'd0; sozcuk_toplayici <= 64'd0; sozcuk_bayt_sirasi <= 4'd0; yazma_adresi <= 16'd0;
            paket_sayisi <= 16'd0; hata_sayisi <= 16'd0;
        end else begin
            gelen_bayt_var <= rx_gecerli;
            if (rx_gecerli) gelen_bayt <= rx_veri;
            if (komut_yukle)       komut_yazmaci <= gelen_bayt;
            if (crc_baslat)        crc_yazmaci <= crc8(8'd0, gelen_bayt);
            else if (crc_guncelle) crc_yazmaci <= crc8(crc_yazmaci, gelen_bayt);
            if (uzunluk_alt_yukle) uzunluk_yazmaci[7:0] <= gelen_bayt;
            if (uzunluk_ust_yukle) uzunluk_yazmaci[15:8] <= gelen_bayt;
            if (sayac_sifirla) begin yuk_sayaci <= 16'd0; sozcuk_toplayici <= 64'd0; sozcuk_bayt_sirasi <= 4'd0; end
            if (sayac_artir)   yuk_sayaci <= yuk_sayaci + 16'd1;
            if (baslik_yaz)    baslik_yazmaci[8 * yuk_sayaci[3:0] +: 8] <= gelen_bayt;
            if (adres_yakala)  yazma_adresi <= {gelen_bayt, komut_panel_yukle ? baslik_yazmaci[23:16] : baslik_yazmaci[7:0]};
            if (sozcuk_topla) begin sozcuk_toplayici <= sozcuk_sonraki; sozcuk_bayt_sirasi <= sozcuk_bayt_sirasi + 4'd2; end
            if (sozcuk_yaz) begin yazma_adresi <= yazma_adresi + 16'd1; sozcuk_toplayici <= 64'd0; sozcuk_bayt_sirasi <= 4'd0; end
            if (paket_say) paket_sayisi <= paket_sayisi + 16'd1;
            if (hata_say)  hata_sayisi  <= hata_sayisi + 16'd1;
        end
    end

    // =========================== ayar yazmaclari ===========================
    reg [10:0]  ayar_k;
    reg [6:0]   ayar_panel_sayisi;
    reg [3:0]   ayar_blok_sayisi;
    reg [5:0]   ayar_kaydirma;
    reg         a_isaretsiz, gelu_etkin;
    reg [23:0]  softmax_olcek_m0;
    reg [39:0]  layernorm_epsilon;
    reg [30:0]  layernorm_olcek_m0;
    reg [5:0]   layernorm_olcek_kaydirma;

    always @(posedge clk) begin
        if (rst) begin
            ayar_k <= 11'd0; ayar_panel_sayisi <= 7'd0; ayar_blok_sayisi <= 4'd0; ayar_kaydirma <= 6'd0; a_isaretsiz <= 1'b0; gelu_etkin <= 1'b0;
            softmax_olcek_m0 <= 24'd0; layernorm_epsilon <= 40'd0; layernorm_olcek_m0 <= 31'd0; layernorm_olcek_kaydirma <= 6'd0;
        end else begin
            if (uygula_ayar) begin
                ayar_k <= alan_ayar_k; ayar_panel_sayisi <= alan_ayar_panel_sayisi; ayar_kaydirma <= alan_ayar_kaydirma;
                a_isaretsiz <= alan_a_isaretsiz; gelu_etkin <= alan_gelu_etkin; ayar_blok_sayisi <= alan_ayar_blok_sayisi;
            end
            if (uygula_softmax_ayar)   softmax_olcek_m0 <= alan_softmax_m0;
            if (uygula_layernorm_ayar) begin
                layernorm_epsilon <= alan_layernorm_epsilon; layernorm_olcek_m0 <= alan_layernorm_m0; layernorm_olcek_kaydirma <= alan_layernorm_kaydirma;
            end
        end
    end

    // =========================== bellek/birim yazma yollari ===========================
    // Yazma yollari yazmaclidir: sozcuk_yaz darbesinden bir cevrim sonra etkin olur.
    reg         aktivasyon_yaz_etkin;
    reg [11:0]  aktivasyon_yaz_adres;
    reg [63:0]  aktivasyon_yaz_veri;
    reg         panel_yaz_etkin, panel_yaz_tampon;
    reg [1:0]   panel_yaz_secici;
    reg [10:0]  panel_yaz_adres;
    reg [63:0]  panel_yaz_veri;
    reg         gelu_yaz_etkin;
    reg [7:0]   gelu_yaz_adres, gelu_yaz_veri;
    reg         softmax_tablo_yaz_etkin;
    reg [8:0]   softmax_tablo_yaz_adres;
    reg [15:0]  softmax_tablo_yaz_veri;
    reg         softmax_giris_gecerli, softmax_giris_maske;
    reg [31:0]  softmax_giris_veri;
    reg         layernorm_parametre_yaz_etkin;
    reg [6:0]   layernorm_parametre_yaz_adres;
    reg [15:0]  layernorm_gamma, layernorm_beta;
    reg         layernorm_giris_gecerli;
    reg [17:0]  layernorm_giris_veri;
    reg         akis_hatasi_tutucu;

    wire        softmax_giris_hazir, layernorm_giris_hazir;

    always @(posedge clk) begin
        if (rst) begin
            aktivasyon_yaz_etkin <= 1'b0; panel_yaz_etkin <= 1'b0; gelu_yaz_etkin <= 1'b0;
            softmax_tablo_yaz_etkin <= 1'b0; softmax_giris_gecerli <= 1'b0; layernorm_parametre_yaz_etkin <= 1'b0; layernorm_giris_gecerli <= 1'b0;
            akis_hatasi_tutucu <= 1'b0;
            panel_yaz_tampon <= 1'b0; panel_yaz_secici <= 2'd0; panel_yaz_adres <= 11'd0; panel_yaz_veri <= 64'd0; aktivasyon_yaz_adres <= 12'd0;
            aktivasyon_yaz_veri <= 64'd0; gelu_yaz_adres <= 8'd0; gelu_yaz_veri <= 8'd0; softmax_tablo_yaz_adres <= 9'd0; softmax_tablo_yaz_veri <= 16'd0;
            softmax_giris_veri <= 32'd0; softmax_giris_maske <= 1'b0; layernorm_parametre_yaz_adres <= 7'd0; layernorm_gamma <= 16'd0; layernorm_beta <= 16'd0;
            layernorm_giris_veri <= 18'd0;
        end else begin
            aktivasyon_yaz_etkin <= 1'b0; panel_yaz_etkin <= 1'b0; gelu_yaz_etkin <= 1'b0; softmax_tablo_yaz_etkin <= 1'b0;
            softmax_giris_gecerli <= 1'b0; layernorm_parametre_yaz_etkin <= 1'b0; layernorm_giris_gecerli <= 1'b0;
            if (sozcuk_yaz) begin
                if (komut_aktivasyon_yukle) begin
                    aktivasyon_yaz_etkin <= 1'b1; aktivasyon_yaz_adres <= yazma_adresi[11:0]; aktivasyon_yaz_veri <= sozcuk_sonraki;
                end else if (komut_panel_yukle) begin
                    panel_yaz_etkin <= 1'b1; panel_yaz_tampon <= alan_panel_tampon; panel_yaz_secici <= alan_panel_secici;
                    panel_yaz_adres <= yazma_adresi[10:0]; panel_yaz_veri <= sozcuk_sonraki;
                    if (alan_panel_gelu_tablosu) begin
                        gelu_yaz_etkin <= 1'b1; gelu_yaz_adres <= yazma_adresi[7:0]; gelu_yaz_veri <= sozcuk_sonraki[7:0]; panel_yaz_etkin <= 1'b0;
                    end
                end else if (komut_softmax_tablo) begin
                    softmax_tablo_yaz_etkin <= 1'b1; softmax_tablo_yaz_adres <= yazma_adresi[8:0]; softmax_tablo_yaz_veri <= sozcuk_sonraki[15:0];
                end else if (komut_softmax_veri) begin
                    if (softmax_giris_hazir) begin
                        softmax_giris_gecerli <= 1'b1; softmax_giris_veri <= sozcuk_sonraki[31:0]; softmax_giris_maske <= sozcuk_sonraki[32];
                    end else akis_hatasi_tutucu <= 1'b1;
                end else if (komut_layernorm_parametre) begin
                    layernorm_parametre_yaz_etkin <= 1'b1; layernorm_parametre_yaz_adres <= yazma_adresi[6:0];
                    layernorm_gamma <= sozcuk_sonraki[15:0]; layernorm_beta <= sozcuk_sonraki[31:16];
                end else if (komut_layernorm_veri) begin
                    if (layernorm_giris_hazir) begin
                        layernorm_giris_gecerli <= 1'b1; layernorm_giris_veri <= sozcuk_sonraki[17:0];
                    end else akis_hatasi_tutucu <= 1'b1;
                end
            end
            if (uygula_akis_hatasi_temizle) akis_hatasi_tutucu <= 1'b0;
        end
    end

    // =========================== panel el sikisma ve durum tutuculari ===========================
    reg [1:0]   panel_hazir, panel_bos;
    reg         katman_bitti_tutucu, tasma_tutucu;
    wire        panel_bitti, panel_bitti_tampon, katman_bitti, mesgul, tasma_hatasi;

    always @(posedge clk) begin
        if (rst) begin
            panel_hazir <= 2'b00; panel_bos <= 2'b11; katman_bitti_tutucu <= 1'b0; tasma_tutucu <= 1'b0;
        end else begin
            if (katman_bitti) katman_bitti_tutucu <= 1'b1;
            if (tasma_hatasi) tasma_tutucu <= 1'b1;
            if (panel_bitti) begin
                panel_hazir[panel_bitti_tampon] <= 1'b0; panel_bos[panel_bitti_tampon] <= 1'b1;
            end
            if (uygula_calistir_temizle) begin katman_bitti_tutucu <= 1'b0; tasma_tutucu <= 1'b0; end
            if (uygula_panel_hazir) begin
                panel_hazir[alan_panel_tampon] <= 1'b1; panel_bos[alan_panel_tampon] <= 1'b0;
            end
        end
    end

    // =========================== islem birimleri ===========================
    reg  [11:0] cikis_oku_adres;
    wire [63:0] cikis_oku_veri;
    wire [31:0] kirpilan_sayisi;

    dogrusal_katman u_dogrusal_katman (.clk(clk), .rst(rst), .calistir(calistir_darbesi),
        .ayar_k(ayar_k), .ayar_panel_sayisi(ayar_panel_sayisi), .ayar_blok_sayisi(ayar_blok_sayisi), .ayar_kaydirma(ayar_kaydirma),
        .a_isaretsiz(a_isaretsiz), .gelu_etkin(gelu_etkin), .mesgul(mesgul), .katman_bitti(katman_bitti),
        .aktivasyon_yaz_etkin(aktivasyon_yaz_etkin), .aktivasyon_yaz_adres(aktivasyon_yaz_adres), .aktivasyon_yaz_veri(aktivasyon_yaz_veri),
        .panel_yaz_etkin(panel_yaz_etkin), .panel_yaz_tampon(panel_yaz_tampon), .panel_yaz_secici(panel_yaz_secici),
        .panel_yaz_adres(panel_yaz_adres), .panel_yaz_veri(panel_yaz_veri),
        .panel_hazir(panel_hazir), .panel_bitti(panel_bitti), .panel_bitti_tampon(panel_bitti_tampon),
        .gelu_yaz_etkin(gelu_yaz_etkin), .gelu_yaz_adres(gelu_yaz_adres), .gelu_yaz_veri(gelu_yaz_veri),
        .cikis_oku_adres(cikis_oku_adres), .cikis_oku_veri(cikis_oku_veri),
        .tasma_hatasi(tasma_hatasi), .kirpilan_sayisi(kirpilan_sayisi));

    wire        softmax_cikis_gecerli, softmax_cikis_son, softmax_mesgul, softmax_hazir;
    wire [7:0]  softmax_cikis_veri, softmax_oku_veri;
    softmax_birim #(.SATIR_UZUNLUGU(64), .SATIR_UZUNLUGU_LOG2(6)) u_softmax (.clk(clk), .rst(rst | softmax_iptal),
        .tablo_yaz_etkin(softmax_tablo_yaz_etkin), .tablo_yaz_adres(softmax_tablo_yaz_adres), .tablo_yaz_veri(softmax_tablo_yaz_veri),
        .olcek_m0(softmax_olcek_m0), .baslat(softmax_baslat), .giris_hazir(softmax_giris_hazir),
        .giris_gecerli(softmax_giris_gecerli), .giris_veri(softmax_giris_veri), .giris_maske(softmax_giris_maske),
        .cikis_gecerli(softmax_cikis_gecerli), .cikis_veri(softmax_cikis_veri), .cikis_son(softmax_cikis_son), .mesgul(softmax_mesgul));
    sonuc_tamponu #(.DERINLIK(64), .ADRES_GENISLIGI(6)) u_softmax_sonuc_tamponu (.clk(clk), .rst(rst), .temizle(softmax_baslat),
        .yaz_gecerli(softmax_cikis_gecerli), .yaz_veri(softmax_cikis_veri), .yaz_son(softmax_cikis_son), .hazir(softmax_hazir),
        .oku_adres(cikis_oku_adres[5:0]), .oku_veri(softmax_oku_veri));

    wire        layernorm_cikis_gecerli, layernorm_cikis_son, layernorm_mesgul, layernorm_hazir;
    wire signed [7:0] layernorm_cikis_veri;
    wire [7:0]  layernorm_oku_veri;
    layernorm_birim #(.KANAL_SAYISI(128), .KANAL_SAYISI_LOG2(7), .GIRIS_GENISLIGI(18), .KESIR_BITI(12)) u_layernorm (.clk(clk), .rst(rst | layernorm_iptal),
        .parametre_yaz_etkin(layernorm_parametre_yaz_etkin), .parametre_yaz_adres(layernorm_parametre_yaz_adres),
        .parametre_gamma(layernorm_gamma), .parametre_beta(layernorm_beta),
        .epsilon_q(layernorm_epsilon), .olcek_m0(layernorm_olcek_m0), .olcek_kaydirma(layernorm_olcek_kaydirma),
        .baslat(layernorm_baslat), .giris_hazir(layernorm_giris_hazir), .giris_gecerli(layernorm_giris_gecerli), .giris_veri(layernorm_giris_veri),
        .cikis_gecerli(layernorm_cikis_gecerli), .cikis_veri(layernorm_cikis_veri), .cikis_son(layernorm_cikis_son), .mesgul(layernorm_mesgul));
    sonuc_tamponu #(.DERINLIK(128), .ADRES_GENISLIGI(7)) u_layernorm_sonuc_tamponu (.clk(clk), .rst(rst), .temizle(layernorm_baslat),
        .yaz_gecerli(layernorm_cikis_gecerli), .yaz_veri(layernorm_cikis_veri), .yaz_son(layernorm_cikis_son), .hazir(layernorm_hazir),
        .oku_adres(cikis_oku_adres[6:0]), .oku_veri(layernorm_oku_veri));

    // =========================== yanit yazmaclari ===========================
    // yanit kaydi: komut uygulandiginda doldurulur; yanit calisma yazmaclari yanit baslarken kayittan yuklenir
    reg [1:0]   yanit_kaydi_turu, yanit_kaydi_kaynak;
    reg [7:0]   yanit_kaydi_komut, yanit_kaydi_kod, yanit_kaydi_durum0, yanit_kaydi_durum1;
    reg [15:0]  yanit_kaydi_uzunluk, yanit_kaydi_adet;
    reg [11:0]  yanit_kaydi_adres;

    reg [7:0]   yanit_komut, yanit_kod, yanit_crc, yanit_durum0, yanit_durum1;
    reg [15:0]  yanit_uzunluk, yanit_bayt_sayaci, yanit_adet, yanit_sozcuk_sayaci;
    reg [11:0]  yanit_adres;
    reg [63:0]  yanit_sozcuk;
    reg [3:0]   yanit_sozcuk_bayt_sirasi;
    reg [1:0]   yanit_kaynak;                 // 0 cikis bellegi (8 bayt/sozcuk), 1 Softmax tamponu, 2 LayerNorm tamponu (1 bayt)

    wire tx_alindi = tx_gecerli && tx_hazir;
    assign tx_musait = !tx_gecerli || tx_alindi;
    wire [3:0] yanit_sozcuk_son_bayt_sirasi = (yanit_kaynak == 2'd0) ? 4'd7 : 4'd0;
    assign yanit_uzunluk_sifir   = (yanit_uzunluk == 16'd0);
    assign yanit_adet_sifir      = (yanit_adet == 16'd0);
    assign yanit_bayt_son        = (yanit_bayt_sayaci + 16'd1 == yanit_uzunluk);
    assign yanit_sozcuk_bayt_son = (yanit_sozcuk_bayt_sirasi == yanit_sozcuk_son_bayt_sirasi);
    assign yanit_son_sozcuk      = (yanit_sozcuk_sayaci + 16'd1 == yanit_adet);

    // sunulacak bayt
    reg [7:0] yanit_secilen_bayt;
    always @(*) begin
        case (yanit_bayt_secici)
            3'd0:    yanit_secilen_bayt = (yanit_turu == 2'd0) ? 8'h06 : (yanit_turu == 2'd1) ? 8'h15 : 8'h02;
            3'd1:    yanit_secilen_bayt = yanit_komut;
            3'd2:    yanit_secilen_bayt = yanit_kod;
            3'd3:    yanit_secilen_bayt = yanit_uzunluk[7:0];
            3'd4:    yanit_secilen_bayt = yanit_uzunluk[15:8];
            3'd5:    yanit_secilen_bayt = (yanit_bayt_sayaci == 16'd0) ? yanit_durum0 : yanit_durum1;
            3'd6:    yanit_secilen_bayt = yanit_sozcuk[7:0];
            default: yanit_secilen_bayt = yanit_crc;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            tx_gecerli <= 1'b0; tx_veri <= 8'd0; cikis_oku_adres <= 12'd0;
            yanit_kaydi_turu <= 2'd0; yanit_kaydi_kaynak <= 2'd0; yanit_kaydi_komut <= 8'd0; yanit_kaydi_kod <= 8'd0; yanit_kaydi_durum0 <= 8'd0;
            yanit_kaydi_durum1 <= 8'd0; yanit_kaydi_uzunluk <= 16'd0; yanit_kaydi_adet <= 16'd0; yanit_kaydi_adres <= 12'd0;
            yanit_turu <= 2'd0; yanit_komut <= 8'd0; yanit_kod <= 8'd0; yanit_crc <= 8'd0; yanit_durum0 <= 8'd0; yanit_durum1 <= 8'd0;
            yanit_uzunluk <= 16'd0; yanit_bayt_sayaci <= 16'd0; yanit_adet <= 16'd0; yanit_sozcuk_sayaci <= 16'd0; yanit_adres <= 12'd0;
            yanit_sozcuk <= 64'd0; yanit_sozcuk_bayt_sirasi <= 4'd0; yanit_kaynak <= 2'd0;
        end else begin
            // ---- yanit kaydi (komut uygulandiginda) ----
            if (yanit_hata_yukle) begin
                yanit_kaydi_turu <= 2'd1; yanit_kaydi_komut <= komut_yazmaci; yanit_kaydi_kod <= yanit_hata_kodu;
            end else if (yanit_ack_yukle) begin
                yanit_kaydi_turu <= 2'd0; yanit_kaydi_komut <= komut_yazmaci; yanit_kaydi_kaynak <= 2'd0;
                if (komut_aktivasyon_oku) begin
                    yanit_kaydi_turu <= 2'd2; yanit_kaydi_adres <= alan_okuma_adresi; yanit_kaydi_adet <= alan_okuma_adedi;
                    yanit_kaydi_uzunluk <= alan_okuma_uzunlugu;
                end
                if (komut_durum) begin
                    yanit_kaydi_turu <= 2'd2; yanit_kaydi_uzunluk <= 16'd2; yanit_kaydi_adet <= 16'd0;
                    yanit_kaydi_durum0 <= {akis_hatasi_tutucu, layernorm_hazir, softmax_hazir, layernorm_mesgul, softmax_mesgul, tasma_tutucu, katman_bitti_tutucu, mesgul};
                    yanit_kaydi_durum1 <= {4'd0, panel_hazir, panel_bos};
                end
                if (komut_softmax_oku) begin
                    yanit_kaydi_turu <= 2'd2; yanit_kaydi_kaynak <= 2'd1; yanit_kaydi_adres <= alan_okuma_adresi;
                    yanit_kaydi_adet <= alan_okuma_adedi; yanit_kaydi_uzunluk <= alan_okuma_adedi;
                end
                if (komut_layernorm_oku) begin
                    yanit_kaydi_turu <= 2'd2; yanit_kaydi_kaynak <= 2'd2; yanit_kaydi_adres <= alan_okuma_adresi;
                    yanit_kaydi_adet <= alan_okuma_adedi; yanit_kaydi_uzunluk <= alan_okuma_adedi;
                end
            end

            // ---- yanit calisma yazmaclari ----
            if (tx_alindi) tx_gecerli <= 1'b0;
            if (yanit_yukle) begin
                yanit_turu <= yanit_kaydi_turu; yanit_komut <= yanit_kaydi_komut; yanit_kod <= yanit_kaydi_kod; yanit_uzunluk <= yanit_kaydi_uzunluk;
                yanit_adres <= yanit_kaydi_adres; yanit_adet <= yanit_kaydi_adet; yanit_kaynak <= yanit_kaydi_kaynak;
                yanit_durum0 <= yanit_kaydi_durum0; yanit_durum1 <= yanit_kaydi_durum1; yanit_sozcuk_sayaci <= 16'd0; yanit_bayt_sayaci <= 16'd0;
            end
            if (yanit_bayt_sun) begin tx_veri <= yanit_secilen_bayt; tx_gecerli <= 1'b1; end
            if (yanit_crc_baslat)        yanit_crc <= crc8(8'd0, yanit_secilen_bayt);
            else if (yanit_crc_guncelle) yanit_crc <= crc8(yanit_crc, yanit_secilen_bayt);
            if (yanit_sayac_artir)       yanit_bayt_sayaci <= yanit_bayt_sayaci + 16'd1;
            if (okuma_adres_ilk)         cikis_oku_adres <= yanit_adres;
            if (okuma_adres_sonraki)     cikis_oku_adres <= yanit_adres + yanit_sozcuk_sayaci[11:0] + 12'd1;
            if (yanit_sozcuk_yukle) begin
                yanit_sozcuk <= (yanit_kaynak == 2'd0) ? cikis_oku_veri : (yanit_kaynak == 2'd1) ? {56'd0, softmax_oku_veri} : {56'd0, layernorm_oku_veri};
                yanit_sozcuk_bayt_sirasi <= 4'd0;
            end
            if (yanit_sozcuk_kaydir) begin
                yanit_sozcuk <= {8'd0, yanit_sozcuk[63:8]}; yanit_sozcuk_bayt_sirasi <= yanit_sozcuk_bayt_sirasi + 4'd1;
            end
            if (yanit_sozcuk_sayaci_artir) yanit_sozcuk_sayaci <= yanit_sozcuk_sayaci + 16'd1;
        end
    end
endmodule
