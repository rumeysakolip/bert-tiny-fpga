// -----------------------------------------------------------------------------
// panel_kopyalayici.v -- bir panelin (K sozcuk) aktivasyon belleginden panel tamponuna kopyalanmasi
//   Dikkatte ikinci operand (anahtarin devrigi) agirlik degil, aktivasyondur. Aktivasyon belleginde anahtar bolgesinin
//   sozcuk duzeni (bir sozcuk = sekiz anahtarin ayni boyuttaki baytlari) zaten panel duzenidir; bu yuzden devrik alma gerekmez,
//   yalnizca kopyalanir. Sapma ve olcek carpani sifir yazilir (dikkatte sapma yoktur).
//   basla darbesi: kaynak_adres'ten K_UZUNLUK sozcuk okunur; panel tamponunun secici 0 alanina yazilir; ardindan secici 1 ve 2 sifirlanir.
//   Sure: K_UZUNLUK + 2 (okuma gecikmesi) + 16 cevrim.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module panel_kopyalayici #(
    parameter K_UZUNLUK   = 64,
    parameter KAYNAK_AW   = 12,
    parameter K_GENISLIGI = 11,
    parameter K_DINAMIK   = 0                // 1: kopyalanan sozcuk sayisi her basla'da `k_uz` girisinden alinir (dolgu atlama); 0: K_UZUNLUK sabit, `k_uz` kullanilmaz
) (
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   basla,
    input  wire [9:0]             k_pad,         // K_DINAMIK=1: panel en az bu kadar sozcuge sifirla tamamlanir (tile'in en kisa guvenli K'si icin); k_uz'dan kucukse etkisiz
    input  wire [9:0]             k_uz,          // K_DINAMIK=1: kopyalanacak sozcuk sayisi (1..K_UZUNLUK; 0 ya da buyuk deger = K_UZUNLUK)
    input  wire [KAYNAK_AW-1:0]   kaynak_adres,
    input  wire                   tampon,
    // kaynak bellek (senkron okuma, 1 cevrim)
    output reg  [KAYNAK_AW-1:0]   k_oku_adres,
    input  wire [63:0]            k_oku_veri,
    // panel tamponu yazma
    output reg                    panel_yaz_etkin,
    output reg                    panel_yaz_tampon,
    output reg  [1:0]             panel_yaz_secici,
    output reg  [K_GENISLIGI-1:0] panel_yaz_adres,
    output reg  [63:0]            panel_yaz_veri,
    output wire                   mesgul,
    output reg                    bitti
);
    localparam S_BOS = 2'd0, S_OKU = 2'd1, S_SIFIR = 2'd2, S_PAD = 2'd3;
    reg [1:0]  durum;
    reg [KAYNAK_AW-1:0] taban;
    reg        tampon_k;
    reg [9:0]  sayac;                      // okuma: 0..K_UZUNLUK+1 ; sifirlama: 0..15
    reg [9:0]  uz_kayit;                   // basla aninda kilitlenen sozcuk sayisi
    wire [9:0] uz_istek = (k_uz == 10'd0 || k_uz > K_UZUNLUK) ? K_UZUNLUK : k_uz;
    wire [9:0] uz_k     = (K_DINAMIK != 0) ? uz_kayit : K_UZUNLUK;
    wire [9:0] pad_k    = (K_DINAMIK != 0 && k_pad > uz_k) ? k_pad : uz_k;
    reg        iss1, iss2;                 // 1. ve 2. cevrim once yayinlanan adres var mi
    reg [K_GENISLIGI-1:0] idx1, idx2;
    assign mesgul = (durum != S_BOS);

    always @(posedge clk) begin
        panel_yaz_etkin <= 1'b0;
        bitti <= 1'b0;
        if (rst) begin
            durum <= S_BOS; sayac <= 10'd0; iss1 <= 1'b0; iss2 <= 1'b0; k_oku_adres <= 0; uz_kayit <= K_UZUNLUK;
        end else begin
            // okuma hattinin 2 cevrimlik gecikmesi: adres yayinlandiktan 2 cevrim sonra veri k_oku_veri'de
            iss2 <= iss1; idx2 <= idx1;
            if (iss2) begin
                panel_yaz_etkin <= 1'b1; panel_yaz_tampon <= tampon_k; panel_yaz_secici <= 2'd0;
                panel_yaz_adres <= idx2; panel_yaz_veri <= k_oku_veri;
            end
            case (durum)
                S_BOS: if (basla) begin taban <= kaynak_adres; tampon_k <= tampon; uz_kayit <= uz_istek; sayac <= 10'd0; durum <= S_OKU; end
                S_OKU: begin
                    if (sayac < uz_k) begin
                        k_oku_adres <= taban + sayac; iss1 <= 1'b1; idx1 <= {{(K_GENISLIGI-10){1'b0}}, sayac};
                        sayac <= sayac + 10'd1;
                    end else begin
                        iss1 <= 1'b0;
                        if (!iss1 && !iss2) begin
                            if (pad_k > uz_k) begin sayac <= uz_k; durum <= S_PAD; end
                            else begin sayac <= 10'd0; durum <= S_SIFIR; end
                        end
                    end
                end
                S_PAD: begin                                   // uz_k..pad_k-1 sozcuklerini sifirla (sistolik dizi tile'i K >= 48 olmali)
                    panel_yaz_etkin <= 1'b1; panel_yaz_tampon <= tampon_k; panel_yaz_secici <= 2'd0;
                    panel_yaz_adres <= {{(K_GENISLIGI-10){1'b0}}, sayac}; panel_yaz_veri <= 64'd0;
                    if (sayac == pad_k - 10'd1) begin sayac <= 10'd0; durum <= S_SIFIR; end
                    else sayac <= sayac + 10'd1;
                end
                S_SIFIR: begin
                    panel_yaz_etkin <= 1'b1; panel_yaz_tampon <= tampon_k; panel_yaz_secici <= sayac[0] ? 2'd2 : 2'd1;
                    panel_yaz_adres <= {{(K_GENISLIGI-3){1'b0}}, sayac[3:1]}; panel_yaz_veri <= 64'd0;
                    if (sayac == 10'd15) begin durum <= S_BOS; bitti <= 1'b1; end
                    else sayac <= sayac + 10'd1;
                end
                default: durum <= S_BOS;
            endcase
        end
    end
endmodule
