// -----------------------------------------------------------------------------
// komut_cozucu.v -- komut kodunu ve baslik alanlarini cozen birim (yalniz cozme; durum makinesi icermez)
//
// Veri yolundaki komut yazmaci ve baslik yazmaci bu birime verilir. Cevap iki turdur:
//   * kontrol sinyalleri  -> kontrol_birimi   (komut_* hatlari, gecerlilik, uzunluklar)
//   * veri alanlari       -> veri_yolu        (alan_* : ayar degerleri, okuma adresi/adedi gibi baslik alanlari)
//
// Istek paketi: komut(1) uzunluk(2, LE) yuk(uzunluk) crc8(1)   -- bicim host protokolu ile aynidir (bkz. kontrol_birimi.v)
// Komut kodlari (yuk):
//   0x01 AYAR            K(2) panel_sayisi(1) kaydirma(1) bayrak(1: bit0 a_isaretsiz, bit1 gelu_etkin, bit5:2 etkin token blogu sayisi)
//   0x02 AKTIVASYON_YUKLE adres(2, sozcuk) + 8 bayt/sozcuk
//   0x03 PANEL_YUKLE      tampon(1) secici(1: 0 agirlik, 1 bias, 2 m0, 3 GELU tablosu) adres(2) + veri (secici 0: 8 B, 1-2: 4 B, 3: 1 B)
//   0x04 CALISTIR         (bos)
//   0x05 AKTIVASYON_OKU   adres(2) adet(2) -> VERI: adet*8 bayt
//   0x06 DURUM            (bos) -> VERI 2 bayt
//   0x07 PANEL_HAZIR      tampon(1)
//   0x08 SOFTMAX_TABLO    adres(2) + 2 bayt/giris           0x09 SOFTMAX_AYAR  m0(3)          0x0A SOFTMAX_BASLAT (bos)
//   0x0B SOFTMAX_VERI     5 bayt/eleman (skor 4 + maske 1)  0x0C SOFTMAX_OKU  adres(2) adet(2)
//   0x0D LAYERNORM_PARAMETRE adres(2) + 4 bayt/kanal        0x0E LAYERNORM_AYAR epsilon(5) m0(4) kaydirma(1)   0x0F LAYERNORM_BASLAT (bos)
//   0x10 LAYERNORM_VERI   3 bayt/eleman                     0x11 LAYERNORM_OKU adres(2) adet(2)
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module komut_cozucu (
    input  wire         clk,
    // ---- veri yolundan gelenler ----
    input  wire [7:0]   komut_yazmaci,
    input  wire [79:0]  baslik_yazmaci,          // bayt k = baslik_yazmaci[8k +: 8]
    input  wire [15:0]  yuk_uzunlugu,
    input  wire [3:0]   sozcuk_bayt_sirasi,
    // ---- kontrol birimine giden kontrol sinyalleri ----
    output reg          komut_gecerli_kayit,     // komut kodu taninir (bir cevrim gecikmeli yazmac)
    output reg          sekil_gecerli_kayit,     // uzunluk/adres sekli uygun (bir cevrim gecikmeli yazmac)
    output wire         komut_ayar,
    output wire         komut_aktivasyon_yukle,
    output wire         komut_panel_yukle,
    output wire         komut_calistir,
    output wire         komut_aktivasyon_oku,
    output wire         komut_durum,
    output wire         komut_panel_hazir,
    output wire         komut_softmax_tablo,
    output wire         komut_softmax_ayar,
    output wire         komut_softmax_baslat,
    output wire         komut_softmax_veri,
    output wire         komut_softmax_oku,
    output wire         komut_layernorm_parametre,
    output wire         komut_layernorm_ayar,
    output wire         komut_layernorm_baslat,
    output wire         komut_layernorm_veri,
    output wire         komut_layernorm_oku,
    output wire         sozcuk_komutu,           // yuk, sozcuk sozcuk bellege/birime yazilan bir komut
    output wire [3:0]   baslik_bayt_sayisi,
    output wire [3:0]   sozcuk_bayt_sayisi,
    // ---- veri yoluna giden veri alanlari ----
    output wire [10:0]  alan_ayar_k,
    output wire [6:0]   alan_ayar_panel_sayisi,
    output wire [5:0]   alan_ayar_kaydirma,
    output wire [3:0]   alan_ayar_blok_sayisi,
    output wire         alan_a_isaretsiz,
    output wire         alan_gelu_etkin,
    output wire         alan_panel_tampon,       // PANEL_HAZIR / PANEL_YUKLE tampon numarasi
    output wire [1:0]   alan_panel_secici,
    output wire         alan_panel_gelu_tablosu, // PANEL_YUKLE secici bayti 3: sozcuk GELU tablosuna yazilir
    output wire [23:0]  alan_softmax_m0,
    output wire [39:0]  alan_layernorm_epsilon,
    output wire [30:0]  alan_layernorm_m0,
    output wire [5:0]   alan_layernorm_kaydirma,
    output wire [11:0]  alan_okuma_adresi,       // AKTIVASYON_OKU / SOFTMAX_OKU / LAYERNORM_OKU
    output wire [15:0]  alan_okuma_adedi,
    output wire [15:0]  alan_okuma_uzunlugu      // yanit yuk uzunlugu (bayt)
);
    localparam K_AYAR = 8'h01, K_AKT_YUKLE = 8'h02, K_PANEL_YUKLE = 8'h03, K_CALISTIR = 8'h04, K_AKT_OKU = 8'h05, K_DURUM = 8'h06,
               K_PANEL_HAZIR = 8'h07, K_SM_TABLO = 8'h08, K_SM_AYAR = 8'h09, K_SM_BASLAT = 8'h0A, K_SM_VERI = 8'h0B, K_SM_OKU = 8'h0C,
               K_LN_PAR = 8'h0D, K_LN_AYAR = 8'h0E, K_LN_BASLAT = 8'h0F, K_LN_VERI = 8'h10, K_LN_OKU = 8'h11;
    localparam [16:0] SOFTMAX_DERINLIK = 17'd64, LAYERNORM_DERINLIK = 17'd128;   // sonuc tamponu derinlikleri (bayt)

    wire [7:0] b0 = baslik_yazmaci[7:0];
    wire [7:0] b1 = baslik_yazmaci[15:8];
    wire [7:0] b2 = baslik_yazmaci[23:16];
    wire [7:0] b3 = baslik_yazmaci[31:24];
    wire [7:0] b4 = baslik_yazmaci[39:32];

    assign komut_ayar                = (komut_yazmaci == K_AYAR);
    assign komut_aktivasyon_yukle    = (komut_yazmaci == K_AKT_YUKLE);
    assign komut_panel_yukle         = (komut_yazmaci == K_PANEL_YUKLE);
    assign komut_calistir            = (komut_yazmaci == K_CALISTIR);
    assign komut_aktivasyon_oku      = (komut_yazmaci == K_AKT_OKU);
    assign komut_durum               = (komut_yazmaci == K_DURUM);
    assign komut_panel_hazir         = (komut_yazmaci == K_PANEL_HAZIR);
    assign komut_softmax_tablo       = (komut_yazmaci == K_SM_TABLO);
    assign komut_softmax_ayar        = (komut_yazmaci == K_SM_AYAR);
    assign komut_softmax_baslat      = (komut_yazmaci == K_SM_BASLAT);
    assign komut_softmax_veri        = (komut_yazmaci == K_SM_VERI);
    assign komut_softmax_oku         = (komut_yazmaci == K_SM_OKU);
    assign komut_layernorm_parametre = (komut_yazmaci == K_LN_PAR);
    assign komut_layernorm_ayar      = (komut_yazmaci == K_LN_AYAR);
    assign komut_layernorm_baslat    = (komut_yazmaci == K_LN_BASLAT);
    assign komut_layernorm_veri      = (komut_yazmaci == K_LN_VERI);
    assign komut_layernorm_oku       = (komut_yazmaci == K_LN_OKU);

    wire komut_taninir = komut_ayar | komut_aktivasyon_yukle | komut_panel_yukle | komut_calistir | komut_aktivasyon_oku | komut_durum |
                         komut_panel_hazir | komut_softmax_tablo | komut_softmax_ayar | komut_softmax_baslat | komut_softmax_veri |
                         komut_softmax_oku | komut_layernorm_parametre | komut_layernorm_ayar | komut_layernorm_baslat |
                         komut_layernorm_veri | komut_layernorm_oku;

    assign sozcuk_komutu = komut_aktivasyon_yukle | komut_panel_yukle | komut_softmax_tablo | komut_softmax_veri |
                           komut_layernorm_parametre | komut_layernorm_veri;

    // baslik: yukun basindaki sabit alanlar (bayt)
    assign baslik_bayt_sayisi =
        komut_ayar ? 4'd5 : komut_aktivasyon_yukle ? 4'd2 : komut_panel_yukle ? 4'd4 : komut_aktivasyon_oku ? 4'd4 : komut_panel_hazir ? 4'd1 :
        komut_softmax_tablo ? 4'd2 : komut_softmax_ayar ? 4'd3 : komut_softmax_oku ? 4'd4 :
        komut_layernorm_parametre ? 4'd2 : komut_layernorm_ayar ? 4'd10 : komut_layernorm_oku ? 4'd4 : 4'd0;

    // bir sozcugu olusturan bayt sayisi
    assign sozcuk_bayt_sayisi =
        komut_aktivasyon_yukle ? 4'd8 :
        komut_panel_yukle ? ((b1 == 8'd0) ? 4'd8 : (b1 == 8'd3) ? 4'd1 : 4'd4) :
        komut_softmax_tablo ? 4'd2 : komut_softmax_veri ? 4'd5 :
        komut_layernorm_parametre ? 4'd4 : komut_layernorm_veri ? 4'd3 : 4'd8;

    // ---- veri alanlari ----
    assign alan_ayar_k              = {b1[2:0], b0};
    assign alan_ayar_panel_sayisi   = b2[6:0];
    assign alan_ayar_kaydirma       = b3[5:0];
    assign alan_a_isaretsiz         = b4[0];
    assign alan_gelu_etkin          = b4[1];
    assign alan_ayar_blok_sayisi    = b4[5:2];
    assign alan_panel_tampon        = b0[0];
    assign alan_panel_secici        = b1[1:0];
    assign alan_panel_gelu_tablosu  = (b1 == 8'd3);
    assign alan_softmax_m0          = baslik_yazmaci[23:0];
    assign alan_layernorm_epsilon   = baslik_yazmaci[39:0];
    assign alan_layernorm_m0        = baslik_yazmaci[70:40];
    assign alan_layernorm_kaydirma  = baslik_yazmaci[76:72];
    // OKU komutlari: adres b1:b0 (12 bit), adet b3:b2. AKTIVASYON_OKU'da adet sozcuk (yanit 8 bayt/sozcuk), SOFTMAX/LAYERNORM_OKU'da bayt
    assign alan_okuma_adresi        = baslik_yazmaci[11:0];
    assign alan_okuma_adedi         = baslik_yazmaci[31:16];
    assign alan_okuma_uzunlugu      = komut_aktivasyon_oku ? ({b3, b2} * 16'd8) : baslik_yazmaci[31:16];

    // Iki istek baytinin arasi en az 2 cevrim oldugundan (UART'ta >= 80 cevrim) bu yazmaclar CRC baytindan once son degerini alir.
    always @(posedge clk) begin
        komut_gecerli_kayit <= komut_taninir;
        sekil_gecerli_kayit <= !(yuk_uzunlugu < {12'd0, baslik_bayt_sayisi} ||
                                 ((komut_softmax_veri || komut_layernorm_veri) && sozcuk_bayt_sirasi != 4'd0) ||             // yarim eleman
                                 (komut_softmax_oku && {1'b0, baslik_yazmaci[15:0]} + {1'b0, baslik_yazmaci[31:16]} > SOFTMAX_DERINLIK) ||      // tampon disi
                                 (komut_layernorm_oku && {1'b0, baslik_yazmaci[15:0]} + {1'b0, baslik_yazmaci[31:16]} > LAYERNORM_DERINLIK));
    end
endmodule
