// -----------------------------------------------------------------------------
// akis_ayristirici.v -- komutsuz akis arabirimi: bayt akisini bloklara ayirir, 16 bit CRC denetler
//
// Disaridan yalniz veri gelir (komut yok). Bir "blok" su sirayla gelen baytlardir:
//   veri baytlari (blok turune gore sabit uzunluk)  +  2 bayt CRC-16 (yuksek bayt once)
//   blok turu 0 (aktivasyon): AKT_SOZCUK x 8 bayt                       -> aktivasyon belleginin sozcukleri
//   blok turu 1 (agirlik paneli): K x 8 bayt agirlik, 8 x 4 bayt bias, 8 x 4 bayt olcek carpani M0
//                                 -> panel tamponuna (secici 0, 1, 2)
// Hangi blogun ne zaman, hangi tamponla geldigini cizelge siralayici bilir ve "blok_basla" ile bildirir;
// bayt akisinin kendisinde baslik ya da komut kodu yoktur. Baytlar sozcuklere kucuk-uclu (bayt 0 en dusuk) birlestirilir.
//
// CRC-16/CCITT-FALSE: cok terimli 0x1021, baslangic 0xFFFF, yansitma yok; veri baytlari uzerinden hesaplanir.
// Blok sonunda hesaplanan deger ile gelen deger ayniysa blok_tamam, degilse blok_hatali darbesi verilir.
// Veri, CRC dogrulanmadan once belleklere yazilir; hatali blogu tuketmemek cizelge siralayicinin isidir
// (panel_hazir yukseltilmez).
//
// Akis denetimi: bayt_hazir, blok aktifken 1'dir (yalniz bekleyen blok varsa bayt kabul edilir).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module akis_ayristirici #(
    parameter AKT_SOZCUK      = 1024,                      // aktivasyon blogu: 64 bit sozcuk sayisi (8 token blogu x K=128)
    parameter K_GENISLIGI     = 11,
    parameter ADRES_GENISLIGI = 12,
    parameter GOMULU          = 0,                        // 1: bias ve M0 bitstream'e gomulu; panel blogu yalniz K x 8 bayt agirlik + CRC
    parameter HIZLI_OLCUM     = 0                         // 1: YALNIZ SURE OLCUMU. Agirlik paneli bloklari bayt tuketmeden 1 cevrimde "tamam" sayilir
                                                          //    (agirliklarin hizli bellekte hazir bekledigi varsayilir). Panel verisi yazilmaz, sonuclar ANLAMSIZ olur.
                                                          //    0 iken devre eskisiyle birebir aynidir.
) (
    input  wire                       clk,
    input  wire                       rst,
    // bayt akisi (disaridan)
    input  wire                       bayt_gecerli,
    input  wire [7:0]                 bayt_veri,
    output wire                       bayt_hazir,
    // cizelge siralayicidan blok baslatma
    input  wire                       blok_basla,
    input  wire                       blok_tur,            // 0: aktivasyon, 1: agirlik paneli
    input  wire                       blok_tampon,         // panel icin hedef tampon
    input  wire [K_GENISLIGI-1:0]     blok_k,              // panel icin K (agirlik sozcugu sayisi)
    output reg                        blok_tamam,          // 1 cevrim: CRC dogru
    output reg                        blok_hatali,         // 1 cevrim: CRC yanlis
    // aktivasyon belleği yazma
    output reg                        aktivasyon_yaz_etkin,
    output reg  [ADRES_GENISLIGI-1:0] aktivasyon_yaz_adres,
    output reg  [63:0]                aktivasyon_yaz_veri,
    // panel tamponu yazma
    output reg                        panel_yaz_etkin,
    output reg                        panel_yaz_tampon,
    output reg  [1:0]                 panel_yaz_secici,
    output reg  [K_GENISLIGI-1:0]     panel_yaz_adres,
    output reg  [63:0]                panel_yaz_veri,
    // tanilama
    output reg  [31:0]                hata_sayisi,
    output reg  [31:0]                kabul_edilen_bayt,
    output reg  [6:0]                 cumle_uzunluk        // son dogrulanmis aktivasyon blogundaki cumle uzunlugu (gercek token sayisi)
);
    localparam D_BOS = 2'd0, D_VERI = 2'd1, D_CRC_HI = 2'd2, D_CRC_LO = 2'd3;

    reg [1:0]               durum;
    reg                     tur_r, tampon_r;
    reg [K_GENISLIGI-1:0]   k_r;
    reg [1:0]               faz;                 // panel: 0 agirlik, 1 bias, 2 olcek M0
    reg [K_GENISLIGI+1:0]   sozcuk_no;
    reg [2:0]               bayt_no;
    reg [63:0]              topla;               // sozcukte biriken baytlar (bayt 0..6 kullanilir; 7. bayt dogrudan yeni_sozcuk'e girer)
    reg [15:0]              crc;
    reg [7:0]               crc_hi;
    reg                     uzunluk_alindi;
    reg [6:0]               uzunluk_k;

    assign bayt_hazir = (durum != D_BOS);
    wire kabul = bayt_gecerli && bayt_hazir;

    // CRC-16/CCITT-FALSE, bir bayt icin
    function [15:0] crc16_bayt;
        input [15:0] c;
        input [7:0]  b;
        integer i;
        reg [15:0] r;
        begin
            r = c ^ {b, 8'h00};
            for (i = 0; i < 8; i = i + 1)
                r = r[15] ? ((r << 1) ^ 16'h1021) : (r << 1);
            crc16_bayt = r;
        end
    endfunction

    wire dar_sozcuk = (tur_r == 1'b1) && (faz != 2'd0);          // bias / M0: 4 baytlik sozcuk
    wire sozcuk_son = dar_sozcuk ? (bayt_no == 3'd3) : (bayt_no == 3'd7);
    wire [63:0] sozcuk_8 = {bayt_veri, topla[55:0]};
    wire [63:0] sozcuk_4 = {32'h0, bayt_veri, topla[23:0]};
    wire [63:0] yeni_sozcuk = dar_sozcuk ? sozcuk_4 : sozcuk_8;

    always @(posedge clk) begin
        aktivasyon_yaz_etkin <= 1'b0;
        panel_yaz_etkin      <= 1'b0;
        blok_tamam           <= 1'b0;
        blok_hatali          <= 1'b0;
        if (rst) begin
            durum <= D_BOS; hata_sayisi <= 32'd0; kabul_edilen_bayt <= 32'd0;
            crc <= 16'hFFFF; bayt_no <= 3'd0; sozcuk_no <= 0; faz <= 2'd0; cumle_uzunluk <= 7'd0; uzunluk_alindi <= 1'b0;
        end else begin
            case (durum)
                D_BOS: if (blok_basla && HIZLI_OLCUM != 0 && blok_tur == 1'b1) begin
                    blok_tamam <= 1'b1;                                  // olcum kipi: panel akisi beklenmez, durum D_BOS'ta kalir
                end else if (blok_basla) begin
                    tur_r <= blok_tur; tampon_r <= blok_tampon; k_r <= blok_k;
                    faz <= 2'd0; sozcuk_no <= 0; bayt_no <= 3'd0; crc <= 16'hFFFF;
                    uzunluk_alindi <= (blok_tur == 1'b1);              // panel blogunda uzunluk baytı yok; aktivasyon blogunda ilk bayt uzunluk
                    durum <= D_VERI;
                end
                D_VERI: if (kabul) begin
                    kabul_edilen_bayt <= kabul_edilen_bayt + 32'd1;
                    crc <= crc16_bayt(crc, bayt_veri);
                    if (!uzunluk_alindi) begin
                        uzunluk_k <= bayt_veri[6:0];                  // aktivasyon blogunun ilk baytı: cumlenin gercek uzunlugu (denetim koduna dahil)
                        uzunluk_alindi <= 1'b1;
                    end else begin
                    topla[bayt_no*8 +: 8] <= bayt_veri;
                    if (!sozcuk_son) begin
                        bayt_no <= bayt_no + 3'd1;
                    end else begin
                        bayt_no <= 3'd0;
                        if (tur_r == 1'b0) begin
                            aktivasyon_yaz_etkin <= 1'b1; aktivasyon_yaz_adres <= sozcuk_no[ADRES_GENISLIGI-1:0]; aktivasyon_yaz_veri <= yeni_sozcuk;
                            if (sozcuk_no == AKT_SOZCUK-1) begin durum <= D_CRC_HI; sozcuk_no <= 0; end
                            else sozcuk_no <= sozcuk_no + 1;
                        end else begin
                            panel_yaz_etkin <= 1'b1; panel_yaz_tampon <= tampon_r; panel_yaz_secici <= faz;
                            panel_yaz_adres <= sozcuk_no[K_GENISLIGI-1:0]; panel_yaz_veri <= yeni_sozcuk;
                            case (faz)
                                2'd0: if (sozcuk_no == k_r-1) begin
                                    sozcuk_no <= 0;
                                    if (GOMULU != 0) durum <= D_CRC_HI; else faz <= 2'd1;
                                end else sozcuk_no <= sozcuk_no + 1;
                                2'd1: if (sozcuk_no == 7)     begin faz <= 2'd2; sozcuk_no <= 0; end else sozcuk_no <= sozcuk_no + 1;
                                default: if (sozcuk_no == 7)  begin durum <= D_CRC_HI; sozcuk_no <= 0; end else sozcuk_no <= sozcuk_no + 1;
                            endcase
                        end
                    end
                    end
                end
                D_CRC_HI: if (kabul) begin
                    kabul_edilen_bayt <= kabul_edilen_bayt + 32'd1;
                    crc_hi <= bayt_veri; durum <= D_CRC_LO;
                end
                D_CRC_LO: if (kabul) begin
                    kabul_edilen_bayt <= kabul_edilen_bayt + 32'd1;
                    if ({crc_hi, bayt_veri} == crc) begin blok_tamam <= 1'b1; if (tur_r == 1'b0) cumle_uzunluk <= uzunluk_k; end
                    else begin blok_hatali <= 1'b1; hata_sayisi <= hata_sayisi + 32'd1; end
                    durum <= D_BOS;
                end
            endcase
        end
    end
endmodule
