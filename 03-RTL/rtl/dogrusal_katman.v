// -----------------------------------------------------------------------------
// dogrusal_katman.v -- bir INT8 dogrusal katmanin uctan uca veri yolu (G7)
//   aktivasyon BRAM -> tile denetleyici + 8x8 dizi -> (+bias) -> yeniden olcekle -> [GELU LUT] -> cikis BRAM
// Ayni modul Q, K, V, attn_out, ffn1, ffn2, pooler, classifier icin kullanilir; katmana ozgu
// degerler (K, np, n, bayraklar) kos oncesi konfigurasyon girislerinden gelir.
//
// Host/TB arayuzu: aktivasyon yazma (aw_*), panel yazma (pw_*, panel_tamponu), GELU LUT yukleme (lw_*),
//   cikis okuma (cikis_oku_adres -> cikis_oku_veri, kayitli). katman_bitti, cikis BRAM'in tamami yazildiktan sonra 1 darbe.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module dogrusal_katman #(
    parameter K_ENFAZLA = 512,
    parameter K_GENISLIGI   = 11,
    parameter PANEL_GENISLIGI   = 7,
    parameter ADRES_GENISLIGI   = 12
) (
    input  wire              clk,
    input  wire              rst,
    // konfigurasyon + denetim
    input  wire              calistir,
    input  wire [K_GENISLIGI-1:0]     ayar_k,
    input  wire [PANEL_GENISLIGI-1:0]     ayar_panel_sayisi,
    input  wire [3:0]        ayar_blok_sayisi,            // etkin token blogu sayisi (1..8); 0 ya da 8den buyuk = NB (eski davranis)
    input  wire [5:0]        ayar_kaydirma,            // KAYDIRMA_<AD>
    input  wire              a_isaretsiz,
    input  wire              gelu_etkin,
    output wire              mesgul,
    output wire              katman_bitti,
    // aktivasyon (girdi) yazma
    input  wire              aktivasyon_yaz_etkin,
    input  wire [ADRES_GENISLIGI-1:0]     aktivasyon_yaz_adres,
    input  wire [63:0]       aktivasyon_yaz_veri,
    // panel yazma / el sikisma
    input  wire              panel_yaz_etkin,
    input  wire              panel_yaz_tampon,
    input  wire [1:0]        panel_yaz_secici,
    input  wire [K_GENISLIGI-1:0]     panel_yaz_adres,
    input  wire [63:0]       panel_yaz_veri,
    input  wire [1:0]        panel_hazir,
    output wire              panel_bitti,
    output wire              panel_bitti_tampon,
    // GELU LUT yukleme
    input  wire              gelu_yaz_etkin,
    input  wire [7:0]        gelu_yaz_adres,
    input  wire [7:0]        gelu_yaz_veri,
    // cikis okuma
    input  wire [ADRES_GENISLIGI-1:0]     cikis_oku_adres,
    output wire [63:0]       cikis_oku_veri,
    // tanilama
    output wire              tasma_hatasi,       // golge ustune yazildi
    output reg  [31:0]       kirpilan_sayisi      // kirpilan eleman sayaci
);
    // ---- bellekler ----
    wire [ADRES_GENISLIGI-1:0] aktivasyon_oku_adres;  wire [63:0] aktivasyon_oku_veri;
    cift_kapili_bellek #(.ADRES_GENISLIGI(ADRES_GENISLIGI), .VERI_GENISLIGI(64)) u_aktivasyon_bellegi (.clk(clk), .yaz_etkin(aktivasyon_yaz_etkin), .yaz_adres(aktivasyon_yaz_adres), .yaz_veri(aktivasyon_yaz_veri),
                                          .oku_adres(aktivasyon_oku_adres), .oku_veri(aktivasyon_oku_veri));
    wire panel_oku_tampon; wire [K_GENISLIGI-1:0] panel_oku_adres; wire [63:0] panel_oku_veri;
    wire sorgu_tampon; wire [2:0] sorgu_kanal; wire [31:0] sorgu_bias; wire [30:0] sorgu_m0;
    panel_tamponu #(.K_ENFAZLA(K_ENFAZLA), .K_GENISLIGI(K_GENISLIGI)) u_panel_tamponu (.clk(clk), .panel_yaz_etkin(panel_yaz_etkin), .panel_yaz_tampon(panel_yaz_tampon), .panel_yaz_secici(panel_yaz_secici),
        .panel_yaz_adres(panel_yaz_adres), .panel_yaz_veri(panel_yaz_veri), .agirlik_oku_tampon(panel_oku_tampon), .agirlik_oku_adres(panel_oku_adres), .agirlik_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias), .sorgu_m0(sorgu_m0));

    // ---- tile denetleyici ----
    wire              cikis_gecerli, cikis_tile_son;
    wire [2:0]        cikis_token, cikis_kanal;
    wire [3:0]        cikis_blok;
    wire [PANEL_GENISLIGI-1:0]     cikis_panel;
    wire signed [31:0] cikis_birikec;
    wire              katman_bitti_ham;
    tile_denetleyici #(.DIZI_BOYUTU(8), .BLOK_SAYISI(8), .K_GENISLIGI(K_GENISLIGI), .PANEL_GENISLIGI(PANEL_GENISLIGI), .ADRES_GENISLIGI(ADRES_GENISLIGI)) u_tile_denetleyici (
        .clk(clk), .rst(rst), .calistir(calistir), .ayar_k(ayar_k), .ayar_panel_sayisi(ayar_panel_sayisi), .ayar_blok_sayisi(ayar_blok_sayisi), .a_isaretsiz(a_isaretsiz),
        .mesgul(mesgul), .katman_bitti(katman_bitti_ham), .panel_hazir(panel_hazir), .panel_bitti(panel_bitti),
        .panel_bitti_tampon(panel_bitti_tampon), .aktivasyon_oku_adres(aktivasyon_oku_adres), .aktivasyon_oku_veri(aktivasyon_oku_veri),
        .panel_oku_tampon(panel_oku_tampon), .panel_oku_adres(panel_oku_adres), .panel_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias),
        .cikis_gecerli(cikis_gecerli), .cikis_token(cikis_token), .cikis_kanal(cikis_kanal), .cikis_blok(cikis_blok), .cikis_panel(cikis_panel),
        .cikis_tile_son(cikis_tile_son), .cikis_birikec(cikis_birikec), .cikis_tasma(tasma_hatasi));

    // ---- olcek_m0'i cikis_birikec ile hizala (ikisi de 1 cevrim kayitli) ----
    reg [30:0] olcek_m0_gecikmis1, olcek_m0_gecikmis2;                   // cikis_birikec artik 2 cevrim kayitli (tile'da ara asama eklendi, Konu 6)
    always @(posedge clk) begin olcek_m0_gecikmis1 <= sorgu_m0; olcek_m0_gecikmis2 <= olcek_m0_gecikmis1; end

    // ---- yeniden olcekle ----
    wire               yeniden_olcekle_gecerli, kirpildi;
    wire signed [7:0]  olcekli_cikis;
    wire [17:0]        olcekli_yan_bilgi;
    yeniden_olcekle #(.META_W(18)) u_yeniden_olcekle (
        .clk(clk), .rst(rst), .giris_gecerli(cikis_gecerli), .birikec(cikis_birikec), .olcek_m0(olcek_m0_gecikmis2), .kaydirma(ayar_kaydirma),
        .yan_bilgi_giris({cikis_tile_son, cikis_token, cikis_kanal, cikis_blok, cikis_panel}),
        .cikis_gecerli(yeniden_olcekle_gecerli), .cikis_int8(olcekli_cikis), .yan_bilgi_cikis(olcekli_yan_bilgi), .kirpildi(kirpildi));

    // ---- [GELU LUT] ----
    wire signed [7:0] gelu_cikis;
    gelu_tablosu u_gelu_tablosu (.clk(clk), .gelu_yaz_etkin(gelu_yaz_etkin), .gelu_yaz_adres(gelu_yaz_adres), .gelu_yaz_veri(gelu_yaz_veri), .giris_int8(olcekli_cikis), .cikis_int8(gelu_cikis));
    wire signed [7:0] son_cikis = gelu_etkin ? gelu_cikis : olcekli_cikis;

    // ---- paketle + cikis BRAM ----
    wire              cikis_yaz_etkin;
    wire [ADRES_GENISLIGI-1:0]     cikis_yaz_adres;
    wire [63:0]       cikis_yaz_veri;
    cikis_sozcuk_toplayici #(.ADRES_GENISLIGI(ADRES_GENISLIGI), .PANEL_GENISLIGI(PANEL_GENISLIGI)) u_cikis_sozcuk_toplayici (
        .clk(clk), .rst(rst), .gecerli(yeniden_olcekle_gecerli), .veri_int8(son_cikis),
        .token_sirasi(olcekli_yan_bilgi[16:14]), .kanal_sirasi(olcekli_yan_bilgi[13:11]), .blok_no(olcekli_yan_bilgi[10:7]), .panel_no(olcekli_yan_bilgi[6:0]),
        .kanal_toplami({ayar_panel_sayisi, 3'b000}), .yaz_etkin(cikis_yaz_etkin), .yaz_adres(cikis_yaz_adres), .yaz_veri(cikis_yaz_veri));
    cift_kapili_bellek #(.ADRES_GENISLIGI(ADRES_GENISLIGI), .VERI_GENISLIGI(64)) u_cikis_bellegi (.clk(clk), .yaz_etkin(cikis_yaz_etkin), .yaz_adres(cikis_yaz_adres), .yaz_veri(cikis_yaz_veri),
                                          .oku_adres(cikis_oku_adres), .oku_veri(cikis_oku_veri));

    // ---- katman_bitti: boru hatti + paketleyici bosalana kadar ertele (4 cevrim) ----
    reg [5:0] bitis_gecikme_kaydirici;                           // yeniden_olcekle 4 asama (Konu 6: +1)
    always @(posedge clk) begin
        if (rst) bitis_gecikme_kaydirici <= 6'd0; else bitis_gecikme_kaydirici <= {bitis_gecikme_kaydirici[4:0], katman_bitti_ham};
    end
    assign katman_bitti = bitis_gecikme_kaydirici[5];

    always @(posedge clk) begin
        if (rst || calistir) kirpilan_sayisi <= 32'd0;
        else if (kirpildi) kirpilan_sayisi <= kirpilan_sayisi + 32'd1;
    end
endmodule
