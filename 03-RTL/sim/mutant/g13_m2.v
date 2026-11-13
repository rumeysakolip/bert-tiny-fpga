// -----------------------------------------------------------------------------
// kontrol_birimi.v -- hizlandiricinin kontrol birimi (durum makineleri; veri tutmaz)
//
// Veri yolu bir bayt aldiginda `bayt_geldi` darbesi verir. Kontrol birimi paket evresini (komut, uzunluk, yuk, CRC)
// yurutur; veri yoluna yazma/yukleme kontrol sinyalleri gonderir. Veri yolundaki yazmaclar ve bellekler yalniz bu
// sinyallerle degisir. Komutu CRC'si dogruysa uygular (uygula_* ve birim darbeleri), degilse HATA yaniti ister.
// Yanit evresi (yanit_durumu) yanit baytlarini sirayla veri yoluna sundurur.
//
// Protokol (host <-> hizlandirici, bayt akisi):
//   Istek : komut(1) uzunluk(2, LE) yuk(uzunluk) crc8(1)      crc8: polinom 0x07, baslangic 0, komut+uzunluk+yuk uzerinden
//   Yanit : ACK   = 0x06 komut
//           HATA  = 0x15 komut kod        (kod 1 = CRC, 2 = bilinmeyen komut, 3 = uzunluk/sekil hatali)
//           VERI  = 0x02 komut uzunluk(2, LE) veri... crc8   (crc komut+uzunluk+veri uzerinden)
// Akis komutlari (SOFTMAX_VERI, LAYERNORM_VERI) idempotent degildir: CRC hatasi alinirsa host BASLAT'tan yeniden baslar.
// Dur-ve-bekle: host bir yanit tamamlanmadan yeni paket gondermez.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module kontrol_birimi (
    input  wire         clk,
    input  wire         rst,
    // ---- veri yolundan: istek bayraklari ----
    input  wire         bayt_geldi,               // yeni bayt veri yolundaki gelen bayt yazmacinda
    input  wire         uzunluk_alt_sifir,        // uzunluk yazmacinin alt baytı 0
    input  wire         gelen_bayt_sifir,         // gelen bayt 0
    input  wire         baslik_bolgesinde,        // yuk sayaci < baslik bayt sayisi
    input  wire         baslik_son_bayt,          // yuk sayaci + 1 == baslik bayt sayisi
    input  wire         sozcuk_son_bayt,          // sozcuk bayt sirasi + 1 == sozcuk bayt sayisi
    input  wire         yuk_son_bayt,             // yuk sayaci + 1 == yuk uzunlugu
    input  wire         crc_dogru,                // gelen bayt == hesaplanan crc
    // ---- komut cozucuden ----
    input  wire         komut_gecerli,
    input  wire         sekil_gecerli,
    input  wire         sozcuk_komutu,
    input  wire         komut_ayar,
    input  wire         komut_calistir,
    input  wire         komut_panel_hazir,
    input  wire         komut_softmax_ayar,
    input  wire         komut_softmax_baslat,
    input  wire         komut_layernorm_ayar,
    input  wire         komut_layernorm_baslat,
    // ---- veri yolundan: yanit bayraklari ----
    input  wire         tx_musait,                // verici yeni bayt kabul edebilir
    input  wire [1:0]   yanit_turu,               // 0 ACK, 1 HATA, 2 VERI
    input  wire         yanit_uzunluk_sifir,
    input  wire         yanit_adet_sifir,
    input  wire         yanit_bayt_son,
    input  wire         yanit_sozcuk_bayt_son,
    input  wire         yanit_son_sozcuk,
    // ---- veri yoluna: istek kontrol sinyalleri ----
    output reg          komut_yukle,
    output reg          crc_baslat,
    output reg          crc_guncelle,
    output reg          uzunluk_alt_yukle,
    output reg          uzunluk_ust_yukle,
    output reg          sayac_sifirla,
    output reg          sayac_artir,
    output reg          baslik_yaz,
    output reg          adres_yakala,
    output reg          sozcuk_topla,
    output reg          sozcuk_yaz,
    output reg          paket_say,
    output reg          hata_say,
    // ---- veri yoluna: komut uygulama sinyalleri (CRC dogruysa) ----
    output reg          uygula_ayar,
    output reg          uygula_calistir_temizle,
    output reg          uygula_panel_hazir,
    output reg          uygula_softmax_ayar,
    output reg          uygula_layernorm_ayar,
    output reg          uygula_akis_hatasi_temizle,
    output reg          yanit_ack_yukle,
    output reg          yanit_hata_yukle,
    output reg  [7:0]   yanit_hata_kodu,
    // ---- birimlere: darbeler ----
    output reg          calistir_darbesi,
    output reg          softmax_iptal,
    output reg          softmax_baslat,
    output reg          layernorm_iptal,
    output reg          layernorm_baslat,
    // ---- yanit kontrol sinyalleri ----
    output reg          yanit_aktif,
    output reg          yanit_istegi,
    output reg          yanit_yukle,
    output reg          yanit_bayt_sun,
    output reg  [2:0]   yanit_bayt_secici,
    output reg          yanit_crc_baslat,
    output reg          yanit_crc_guncelle,
    output reg          yanit_sayac_artir,
    output reg          okuma_adres_ilk,
    output reg          okuma_adres_sonraki,
    output reg          yanit_sozcuk_yukle,
    output reg          yanit_sozcuk_kaydir,
    output reg          yanit_sozcuk_sayaci_artir
);
    localparam P_KOMUT = 3'd0, P_UZUNLUK_ALT = 3'd1, P_UZUNLUK_UST = 3'd2, P_YUK = 3'd3, P_CRC = 3'd4;
    localparam Y_BOSTA = 4'd0, Y_TUR = 4'd1, Y_KOMUT = 4'd2, Y_KOD_UZ_ALT = 4'd3, Y_UZ_UST = 4'd4, Y_DURUM_BAYT = 4'd5,
               Y_CRC = 4'd6, Y_OKU_BEKLE1 = 4'd7, Y_OKU_BEKLE2 = 4'd8, Y_SOZCUK = 4'd9;
    // yanit_bayt_secici degerleri
    localparam SEC_TUR = 3'd0, SEC_KOMUT = 3'd1, SEC_KOD = 3'd2, SEC_UZ_ALT = 3'd3, SEC_UZ_UST = 3'd4, SEC_DURUM = 3'd5, SEC_SOZCUK = 3'd6, SEC_CRC = 3'd7;

    reg [2:0] istek_durumu, istek_durumu_sonraki;
    reg [3:0] yanit_durumu, yanit_durumu_sonraki;
    reg       yanit_aktif_sonraki, yanit_istegi_set;
    reg       softmax_gecikme, layernorm_gecikme;      // iptalden bir cevrim sonra baslat

    wire tamam = bayt_geldi && (istek_durumu == P_CRC) && komut_gecerli && crc_dogru && sekil_gecerli;

    // ---------------- istek evresi: birlesik mantik ----------------
    always @(*) begin
        istek_durumu_sonraki = istek_durumu;
        komut_yukle = 1'b0; crc_baslat = 1'b0; crc_guncelle = 1'b0; uzunluk_alt_yukle = 1'b0; uzunluk_ust_yukle = 1'b0;
        sayac_sifirla = 1'b0; sayac_artir = 1'b0; baslik_yaz = 1'b0; adres_yakala = 1'b0; sozcuk_topla = 1'b0; sozcuk_yaz = 1'b0;
        paket_say = 1'b0; hata_say = 1'b0;
        uygula_ayar = 1'b0; uygula_calistir_temizle = 1'b0; uygula_panel_hazir = 1'b0; uygula_softmax_ayar = 1'b0; uygula_layernorm_ayar = 1'b0;
        uygula_akis_hatasi_temizle = 1'b0; yanit_ack_yukle = 1'b0; yanit_hata_yukle = 1'b0; yanit_hata_kodu = 8'd0; yanit_istegi_set = 1'b0;
        if (bayt_geldi) begin
            case (istek_durumu)
                P_KOMUT: begin komut_yukle = 1'b1; crc_baslat = 1'b1; istek_durumu_sonraki = P_UZUNLUK_ALT; end
                P_UZUNLUK_ALT: begin uzunluk_alt_yukle = 1'b1; crc_guncelle = 1'b1; istek_durumu_sonraki = P_UZUNLUK_UST; end
                P_UZUNLUK_UST: begin
                    uzunluk_ust_yukle = 1'b1; crc_guncelle = 1'b1; sayac_sifirla = 1'b1;
                    istek_durumu_sonraki = (uzunluk_alt_sifir && gelen_bayt_sifir) ? P_CRC : P_YUK;
                end
                P_YUK: begin
                    crc_guncelle = 1'b1; sayac_artir = 1'b1;
                    if (baslik_bolgesinde) begin
                        baslik_yaz = 1'b1;
                        if (baslik_son_bayt) adres_yakala = 1'b1;
                    end else if (sozcuk_komutu) begin
                        if (sozcuk_son_bayt) sozcuk_yaz = 1'b1; else sozcuk_topla = 1'b1;
                    end
                    if (yuk_son_bayt) istek_durumu_sonraki = P_CRC;
                end
                P_CRC: begin
                    istek_durumu_sonraki = P_KOMUT; paket_say = 1'b1; yanit_istegi_set = 1'b1;
                    if (!komut_gecerli) begin yanit_hata_yukle = 1'b1; yanit_hata_kodu = 8'd2; hata_say = 1'b1; end
                    else if (!crc_dogru) begin yanit_hata_yukle = 1'b1; yanit_hata_kodu = 8'd1; hata_say = 1'b1; end
                    else if (!sekil_gecerli) begin yanit_hata_yukle = 1'b1; yanit_hata_kodu = 8'd3; hata_say = 1'b1; end
                    else begin
                        yanit_ack_yukle = 1'b1;
                        uygula_ayar                = komut_ayar;
                        uygula_calistir_temizle    = komut_calistir;
                        uygula_panel_hazir         = komut_panel_hazir;
                        uygula_softmax_ayar        = komut_softmax_ayar;
                        uygula_layernorm_ayar      = komut_layernorm_ayar;
                        uygula_akis_hatasi_temizle = komut_softmax_baslat | komut_layernorm_baslat;
                    end
                end
                default: istek_durumu_sonraki = P_KOMUT;
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            istek_durumu <= P_KOMUT; calistir_darbesi <= 1'b0; yanit_istegi <= 1'b0;
            softmax_iptal <= 1'b0; softmax_baslat <= 1'b0; softmax_gecikme <= 1'b0;
            layernorm_iptal <= 1'b0; layernorm_baslat <= 1'b0; layernorm_gecikme <= 1'b0;
        end else begin
            istek_durumu <= istek_durumu_sonraki;
            calistir_darbesi <= tamam & komut_calistir;
            // baslat komutlari birimi bir cevrim sifirlar (iptal) ve bir cevrim sonra baslatir
            softmax_iptal    <= 1'b0;   softmax_gecikme   <= tamam & komut_softmax_baslat;   softmax_baslat   <= softmax_gecikme;
            layernorm_iptal  <= tamam & komut_layernorm_baslat; layernorm_gecikme <= tamam & komut_layernorm_baslat; layernorm_baslat <= layernorm_gecikme;
            if (yanit_aktif) yanit_istegi <= 1'b0;
            if (yanit_istegi_set) yanit_istegi <= 1'b1;
        end
    end

    // ---------------- yanit evresi: birlesik mantik ----------------
    always @(*) begin
        yanit_durumu_sonraki = yanit_durumu; yanit_aktif_sonraki = yanit_aktif;
        yanit_yukle = 1'b0; yanit_bayt_sun = 1'b0; yanit_bayt_secici = SEC_TUR; yanit_crc_baslat = 1'b0; yanit_crc_guncelle = 1'b0;
        yanit_sayac_artir = 1'b0; okuma_adres_ilk = 1'b0; okuma_adres_sonraki = 1'b0; yanit_sozcuk_yukle = 1'b0;
        yanit_sozcuk_kaydir = 1'b0; yanit_sozcuk_sayaci_artir = 1'b0;
        case (yanit_durumu)
            Y_BOSTA: if (yanit_istegi && !yanit_aktif) begin
                yanit_yukle = 1'b1; yanit_aktif_sonraki = 1'b1; yanit_durumu_sonraki = Y_TUR;
            end
            Y_TUR: if (tx_musait) begin
                yanit_bayt_sun = 1'b1; yanit_bayt_secici = SEC_TUR; yanit_durumu_sonraki = Y_KOMUT;
            end
            Y_KOMUT: if (tx_musait) begin
                yanit_bayt_sun = 1'b1; yanit_bayt_secici = SEC_KOMUT; yanit_crc_baslat = 1'b1;
                if (yanit_turu == 2'd0) begin yanit_durumu_sonraki = Y_BOSTA; yanit_aktif_sonraki = 1'b0; end
                else yanit_durumu_sonraki = Y_KOD_UZ_ALT;
            end
            Y_KOD_UZ_ALT: if (tx_musait) begin
                if (yanit_turu == 2'd1) begin
                    yanit_bayt_sun = 1'b1; yanit_bayt_secici = SEC_KOD; yanit_durumu_sonraki = Y_BOSTA; yanit_aktif_sonraki = 1'b0;
                end else begin
                    yanit_bayt_sun = 1'b1; yanit_bayt_secici = SEC_UZ_ALT; yanit_crc_guncelle = 1'b1; yanit_durumu_sonraki = Y_UZ_UST;
                end
            end
            Y_UZ_UST: if (tx_musait) begin
                yanit_bayt_sun = 1'b1; yanit_bayt_secici = SEC_UZ_UST; yanit_crc_guncelle = 1'b1;
                if (yanit_uzunluk_sifir) yanit_durumu_sonraki = Y_CRC;
                else if (yanit_adet_sifir) yanit_durumu_sonraki = Y_DURUM_BAYT;       // DURUM yaniti
                else begin okuma_adres_ilk = 1'b1; yanit_durumu_sonraki = Y_OKU_BEKLE1; end   // OKU yaniti: ilk sozcuk
            end
            Y_DURUM_BAYT: if (tx_musait) begin
                yanit_bayt_sun = 1'b1; yanit_bayt_secici = SEC_DURUM; yanit_crc_guncelle = 1'b1; yanit_sayac_artir = 1'b1;
                if (yanit_bayt_son) yanit_durumu_sonraki = Y_CRC;
            end
            Y_OKU_BEKLE1: yanit_durumu_sonraki = Y_OKU_BEKLE2;                           // bellek okuma gecikmesi
            Y_OKU_BEKLE2: begin yanit_sozcuk_yukle = 1'b1; yanit_durumu_sonraki = Y_SOZCUK; end
            Y_SOZCUK: if (tx_musait) begin
                yanit_bayt_sun = 1'b1; yanit_bayt_secici = SEC_SOZCUK; yanit_crc_guncelle = 1'b1; yanit_sozcuk_kaydir = 1'b1;
                if (yanit_sozcuk_bayt_son) begin
                    yanit_sozcuk_sayaci_artir = 1'b1;
                    if (yanit_son_sozcuk) yanit_durumu_sonraki = Y_CRC;
                    else begin okuma_adres_sonraki = 1'b1; yanit_durumu_sonraki = Y_OKU_BEKLE1; end
                end
            end
            Y_CRC: if (tx_musait) begin
                yanit_bayt_sun = 1'b1; yanit_bayt_secici = SEC_CRC; yanit_durumu_sonraki = Y_BOSTA; yanit_aktif_sonraki = 1'b0;
            end
            default: yanit_durumu_sonraki = Y_BOSTA;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            yanit_durumu <= Y_BOSTA; yanit_aktif <= 1'b0;
        end else begin
            yanit_durumu <= yanit_durumu_sonraki; yanit_aktif <= yanit_aktif_sonraki;
        end
    end
endmodule
