// -----------------------------------------------------------------------------
// dikkat_cekirdegi.v -- bir dikkat basi icin Q.K^T -> yeniden olcekleme -> Softmax -> olasilik belleği, cip icinde zincir
//   1. 8 anahtar panelini (her biri 64 sozcuk) aktivasyon belleginden panel tamponuna kopyalar (panel_kopyalayici), iki tampon dönüşümlü.
//   2. Cizelge siralayicidan bagimsiz kosan mevcut tile_denetleyici + sistolik dizi 64x64 skor birikecini hesaplar (degismedi).
//   3. Birikec, ortak yeniden olcekleme birimiyle (genis kirpma) skor olcegine getirilir; 16 bitlik skor tamponuna yazilir.
//   4. Her satir (sorgu) icin 64 skor, anahtar maskesiyle birlikte Softmax birimine (gomulu ustel tablo) verilir.
//   5. Sekiz satirin olasilik baytlari birikince 64 sozcuk olarak olasilik belleğine yazilir (bayt j = sorgu 8b+j).
// Duzenler: Q ve K, 64 sozcuk/blok: Q[blk*64 + d] (bayt i = token 8blk+i), K paneli [p*k_adim + k_taban + d] (bayt j = anahtar 8p+j).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module dikkat_cekirdegi (
    input  wire         clk,
    input  wire         rst,
    // Q (A operandi) ve K (panel duzeni) yazma
    input  wire         q_yaz_etkin,
    input  wire [11:0]  q_yaz_adres,
    input  wire [63:0]  q_yaz_veri,
    input  wire         k_yaz_etkin,
    input  wire [11:0]  k_yaz_adres,
    input  wire [63:0]  k_yaz_veri,
    // ayarlar
    input  wire [11:0]  ayar_k_taban,
    input  wire [11:0]  ayar_k_adim,
    input  wire [30:0]  ayar_m0_qk,
    input  wire [5:0]   ayar_n_qk,
    input  wire [23:0]  ayar_m0_sm,
    input  wire [6:0]   uzunluk,              // gercek token sayisi (anahtar maskesi: anahtar < uzunluk)
    input  wire         basla,
    input  wire         mod,                  // 0: Q.K^T + Softmax -> olasilik belleği ; 1: olasilik x deger (P.V) -> baglam belleği
    input  wire [30:0]  ayar_m0_pv,           // P.V yeniden olcekleme (8 bit kirpma)
    input  wire [5:0]   ayar_n_pv,
    output reg          skor_hazir,           // 1 cevrim: tum skorlar tampona yazildi
    output reg          bitti,                // 1 cevrim: tum olasiliklar yazildi
    output wire         mesgul,
    // okuma portlari (test/gozlem)
    input  wire [11:0]  skor_oku_adres,
    output reg  signed [15:0] skor_oku_veri,
    input  wire [8:0]   p_oku_adres,
    output reg  [63:0]  p_oku_veri,
    input  wire [8:0]   c_oku_adres,          // baglam belleği okuma: sozcuk (blok*64 + kanal), bayt i = token 8*blok+i
    output reg  [63:0]  c_oku_veri,
    output reg          skor_tasma,           // skor 16 bite sigmadi (sticky, basla ile temizlenir)
    output wire         tile_tasma
);
    // ---------------- bellekler ----------------
    wire [11:0] akt_oku_adres; wire [63:0] q_oku_veri_w; wire [63:0] akt_oku_veri;
    reg         pv_mod;                                   // basla anindaki mod (kosu boyunca sabit)
    cift_kapili_bellek #(.ADRES_GENISLIGI(12), .VERI_GENISLIGI(64)) u_q (.clk(clk), .yaz_etkin(q_yaz_etkin), .yaz_adres(q_yaz_adres), .yaz_veri(q_yaz_veri),
        .oku_adres(akt_oku_adres), .oku_veri(q_oku_veri_w));
    assign akt_oku_veri = pv_mod ? p_oku_veri : q_oku_veri_w;      // A operandi: Q (mod 0) ya da olasilik (mod 1)

    reg [63:0] k_ram [0:4095];
    reg [63:0] k_oku_veri;
    wire [11:0] k_oku_adres;
    always @(posedge clk) begin
        if (k_yaz_etkin) k_ram[k_yaz_adres] <= k_yaz_veri;
        k_oku_veri <= k_ram[k_oku_adres];
    end

    // panel tamponu + kopyalayici
    wire        pk_yaz_etkin, pk_yaz_tampon; wire [1:0] pk_yaz_secici; wire [10:0] pk_yaz_adres; wire [63:0] pk_yaz_veri;
    wire        pk_mesgul, pk_bitti;
    reg         pk_basla; reg [11:0] pk_kaynak; reg pk_tampon;
    panel_kopyalayici #(.K_UZUNLUK(64)) u_kop (.clk(clk), .rst(rst), .basla(pk_basla), .kaynak_adres(pk_kaynak), .tampon(pk_tampon),
        .k_oku_adres(k_oku_adres), .k_oku_veri(k_oku_veri),
        .panel_yaz_etkin(pk_yaz_etkin), .panel_yaz_tampon(pk_yaz_tampon), .panel_yaz_secici(pk_yaz_secici), .panel_yaz_adres(pk_yaz_adres), .panel_yaz_veri(pk_yaz_veri),
        .mesgul(pk_mesgul), .bitti(pk_bitti));

    wire        panel_oku_tampon; wire [10:0] panel_oku_adres; wire [63:0] panel_oku_veri;
    wire        sorgu_tampon; wire [2:0] sorgu_kanal; wire [31:0] sorgu_bias; wire [30:0] sorgu_m0;
    panel_tamponu #(.K_ENFAZLA(512), .K_GENISLIGI(11)) u_pan (.clk(clk), .panel_yaz_etkin(pk_yaz_etkin), .panel_yaz_tampon(pk_yaz_tampon), .panel_yaz_secici(pk_yaz_secici),
        .panel_yaz_adres(pk_yaz_adres), .panel_yaz_veri(pk_yaz_veri), .agirlik_oku_tampon(panel_oku_tampon), .agirlik_oku_adres(panel_oku_adres), .agirlik_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias), .sorgu_m0(sorgu_m0));

    // ---------------- tile denetleyici (mevcut, degismedi) ----------------
    reg         calistir;
    reg  [1:0]  panel_hazir;
    wire        tile_mesgul, tile_bitti, panel_bitti, panel_bitti_tampon;
    wire        cikis_gecerli, cikis_tile_son;
    wire [2:0]  cikis_token, cikis_kanal;
    wire [3:0]  cikis_blok;
    wire [6:0]  cikis_panel;
    wire signed [31:0] cikis_birikec;
    tile_denetleyici #(.DIZI_BOYUTU(8), .BLOK_SAYISI(8), .K_GENISLIGI(11), .PANEL_GENISLIGI(7), .ADRES_GENISLIGI(12)) u_tile (
        .clk(clk), .rst(rst), .calistir(calistir), .ayar_k(11'd64), .ayar_panel_sayisi(7'd8), .ayar_blok_sayisi(4'd0), .a_isaretsiz(pv_mod),
        .mesgul(tile_mesgul), .katman_bitti(tile_bitti), .panel_hazir(panel_hazir), .panel_bitti(panel_bitti), .panel_bitti_tampon(panel_bitti_tampon),
        .aktivasyon_oku_adres(akt_oku_adres), .aktivasyon_oku_veri(akt_oku_veri),
        .panel_oku_tampon(panel_oku_tampon), .panel_oku_adres(panel_oku_adres), .panel_oku_veri(panel_oku_veri),
        .sorgu_tampon(sorgu_tampon), .sorgu_kanal(sorgu_kanal), .sorgu_bias(sorgu_bias),
        .cikis_gecerli(cikis_gecerli), .cikis_token(cikis_token), .cikis_kanal(cikis_kanal), .cikis_blok(cikis_blok), .cikis_panel(cikis_panel),
        .cikis_tile_son(cikis_tile_son), .cikis_birikec(cikis_birikec), .cikis_tasma(tile_tasma));

    // ---------------- ortak yeniden olcekleme (genis kirpma) ----------------
    wire        rs_gecerli, rs_kirp;
    wire signed [31:0] rs_veri;
    wire [17:0] rs_meta;
    yeniden_olcekle_ortak #(.META_W(18)) u_rs (.clk(clk), .rst(rst), .genis(~pv_mod), .giris_gecerli(cikis_gecerli), .birikec(cikis_birikec),
        .olcek_m0(pv_mod ? ayar_m0_pv : ayar_m0_qk), .kaydirma(pv_mod ? ayar_n_pv : ayar_n_qk), .yan_bilgi_giris({cikis_tile_son, cikis_token, cikis_kanal, cikis_blok, cikis_panel}),
        .cikis_gecerli(rs_gecerli), .cikis_veri(rs_veri), .yan_bilgi_cikis(rs_meta), .kirpildi(rs_kirp));

    // ---------------- skor tamponu: 64 x 64 x 16 bit ----------------
    reg signed [15:0] skor_ram [0:4095];
    // adres = { sorgu sirasi (blok*8 + token), anahtar sirasi (panel*8 + kanal) }; meta = {tile_son, token[16:14], kanal[13:11], blok[10:7], panel[6:0]}
    wire [11:0] skor_yaz_adres = {rs_meta[9:7], rs_meta[16:14], rs_meta[2:0], rs_meta[13:11]};
    reg  [11:0] skor_ic_adres;
    reg  signed [15:0] skor_ic_veri;
    always @(posedge clk) begin
        if (rs_gecerli && !pv_mod) skor_ram[skor_yaz_adres] <= rs_veri[15:0];
        skor_ic_veri  <= skor_ram[skor_ic_adres];
        skor_oku_veri <= skor_ram[skor_oku_adres];
        if (rst || basla) skor_tasma <= 1'b0;
        else if (rs_gecerli && !pv_mod && (rs_veri > 32'sd32767 || rs_veri < -32'sd32768)) skor_tasma <= 1'b1;
    end

    // ---------------- Softmax (gomulu ustel tablo) ----------------
    reg         sm_baslat, sm_giris_gecerli, sm_giris_maske;
    reg  signed [31:0] sm_giris_veri;
    wire        sm_giris_hazir, sm_cikis_gecerli, sm_cikis_son, sm_mesgul;
    wire [7:0]  sm_cikis_veri;
    softmax_birim_gomulu #(.SATIR_UZUNLUGU(64), .TABLO_DOSYASI("exp_l0.mem")) u_sm (.clk(clk), .rst(rst), .olcek_m0(ayar_m0_sm), .baslat(sm_baslat),
        .giris_hazir(sm_giris_hazir), .giris_gecerli(sm_giris_gecerli), .giris_veri(sm_giris_veri), .giris_maske(sm_giris_maske),
        .cikis_gecerli(sm_cikis_gecerli), .cikis_veri(sm_cikis_veri), .cikis_son(sm_cikis_son), .mesgul(sm_mesgul));

    // ---------------- olasilik toplayici ve olasilik belleği ----------------
    reg [7:0]  pbuf [0:511];
    reg [6:0]  cikis_say;
    reg [2:0]  satir_mod;
    reg        satir_tamam;
    reg [63:0] p_ram [0:511];
    reg [63:0] c_ram [0:511];                          // baglam belleği (P.V cikisi)
    wire c_yaz_etkin; wire [11:0] c_yaz_adres; wire [63:0] c_yaz_veri;
    reg        p_yaz_etkin; reg [8:0] p_yaz_adres; reg [63:0] p_yaz_veri;
    always @(posedge clk) begin
        satir_tamam <= 1'b0;
        if (rst || basla) cikis_say <= 7'd0;
        else if (sm_cikis_gecerli) begin
            pbuf[{satir_mod, cikis_say[5:0]}] <= sm_cikis_veri;
            cikis_say <= (cikis_say == 7'd63) ? 7'd0 : cikis_say + 7'd1;
            if (sm_cikis_son) satir_tamam <= 1'b1;
        end
        if (p_yaz_etkin) p_ram[p_yaz_adres] <= p_yaz_veri;
        p_oku_veri <= p_ram[pv_mod ? akt_oku_adres[8:0] : p_oku_adres];          // mod 1: tile olasiliklari buradan okur
        if (c_yaz_etkin) c_ram[c_yaz_adres[8:0]] <= c_yaz_veri;
        c_oku_veri <= c_ram[c_oku_adres];
    end

    // ---------------- baglam belleği (P.V cikisi, normal aktivasyon duzeni, 64 kanal) ----------------
    cikis_sozcuk_toplayici #(.ADRES_GENISLIGI(12), .PANEL_GENISLIGI(7)) u_ctx (.clk(clk), .rst(rst), .gecerli(rs_gecerli & pv_mod), .veri_int8(rs_veri[7:0]),
        .token_sirasi(rs_meta[16:14]), .kanal_sirasi(rs_meta[13:11]), .blok_no(rs_meta[10:7]), .panel_no(rs_meta[6:0]), .kanal_toplami(10'd64),
        .yaz_etkin(c_yaz_etkin), .yaz_adres(c_yaz_adres), .yaz_veri(c_yaz_veri));

    // ---------------- ana denetim ----------------
    localparam D_BOS = 4'd0, D_P0 = 4'd1, D_P0W = 4'd2, D_P1 = 4'd3, D_P1W = 4'd4, D_CAL = 4'd5, D_KOS = 4'd6, D_AKIT = 4'd7,
               S_BASLAT = 4'd8, S_HAZIR = 4'd9, S_GIRIS = 4'd10, S_BEKLE = 4'd11, S_YAZ = 4'd12, D_SON = 4'd13;
    reg [3:0]  durum;
    reg [3:0]  yuklenen;
    reg [1:0]  bos;
    reg        kop_mesgul, kop_tampon;
    reg [3:0]  akit_say;
    reg [6:0]  satir;                       // 0..63
    reg [6:0]  gir_say;                     // girilen skor sayisi
    reg        gir_gecerli_d, gir_gecerli_d2;
    reg [6:0]  gir_idx_d, gir_idx_d2;
    reg [6:0]  yaz_say;
    reg [1:0]  ph_dummy;
    assign mesgul = (durum != D_BOS);

    function [11:0] kaynak_panel; input [3:0] p; begin kaynak_panel = ayar_k_taban + p * ayar_k_adim; end endfunction

    reg [1:0] ph;
    reg [7:0] i8;
    always @(posedge clk) begin
        pk_basla <= 1'b0; calistir <= 1'b0; sm_baslat <= 1'b0; skor_hazir <= 1'b0; bitti <= 1'b0; p_yaz_etkin <= 1'b0;
        sm_giris_gecerli <= 1'b0;
        if (rst) begin
            durum <= D_BOS; panel_hazir <= 2'b00; bos <= 2'b00; yuklenen <= 0; kop_mesgul <= 1'b0; kop_tampon <= 1'b0; satir <= 0; satir_mod <= 0;
            gir_gecerli_d <= 1'b0; gir_gecerli_d2 <= 1'b0; skor_ic_adres <= 0;
        end else begin
            // panel_hazir / bos bayraklari (cizelge siralayici ile ayni mantik)
            ph = panel_hazir;
            if (panel_bitti) begin ph[panel_bitti_tampon] = 1'b0; bos[panel_bitti_tampon] <= 1'b1; end
            if (pk_bitti && kop_mesgul) begin ph[kop_tampon] = 1'b1; kop_mesgul <= 1'b0; end
            panel_hazir <= ph;

            case (durum)
                D_BOS: if (basla) begin
                    pv_mod <= mod; yuklenen <= 0; bos <= 2'b00; satir <= 0; satir_mod <= 0; durum <= D_P0;
                end
                D_P0: begin pk_basla <= 1'b1; pk_kaynak <= kaynak_panel(4'd0); pk_tampon <= 1'b0; kop_mesgul <= 1'b1; kop_tampon <= 1'b0; yuklenen <= 4'd1; durum <= D_P0W; end
                D_P0W: if (pk_bitti) durum <= D_P1;
                D_P1: begin pk_basla <= 1'b1; pk_kaynak <= kaynak_panel(4'd1); pk_tampon <= 1'b1; kop_mesgul <= 1'b1; kop_tampon <= 1'b1; yuklenen <= 4'd2; durum <= D_P1W; end
                D_P1W: if (pk_bitti) durum <= D_CAL;
                D_CAL: begin calistir <= 1'b1; durum <= D_KOS; end
                D_KOS: begin
                    if (!kop_mesgul && yuklenen < 4'd8 && bos[yuklenen[0]]) begin
                        pk_basla <= 1'b1; pk_kaynak <= kaynak_panel(yuklenen); pk_tampon <= yuklenen[0];
                        kop_mesgul <= 1'b1; kop_tampon <= yuklenen[0]; bos[yuklenen[0]] <= 1'b0; yuklenen <= yuklenen + 4'd1;
                    end
                    if (tile_bitti) begin akit_say <= 4'd0; durum <= D_AKIT; end
                end
                D_AKIT: begin                                     // boru hatti ve skor yazimi bosalsin
                    akit_say <= akit_say + 4'd1;
                    if (akit_say == 4'd12) begin
                        if (pv_mod) begin bitti <= 1'b1; durum <= D_BOS; end                 // P.V: baglam hazir
                        else begin skor_hazir <= 1'b1; satir <= 0; satir_mod <= 0; durum <= S_BASLAT; end
                    end
                end
                // ---- Softmax: her satir ----
                S_BASLAT: begin sm_baslat <= 1'b1; gir_say <= 7'd0; durum <= S_HAZIR; end
                S_HAZIR: if (sm_giris_hazir) durum <= S_GIRIS;
                S_GIRIS: begin
                    // skor okuma: adres bu cevrim yayinlanir, veri 1 cevrim sonra skor_ic_veri'de
                    if (gir_say < 7'd64) begin
                        skor_ic_adres <= {satir[5:0], gir_say[5:0]};
                        gir_gecerli_d <= 1'b1; gir_idx_d <= gir_say; gir_say <= gir_say + 7'd1;
                    end else gir_gecerli_d <= 1'b0;
                    if (gir_say == 7'd64 && !gir_gecerli_d && !gir_gecerli_d2) durum <= S_BEKLE;
                end
                S_BEKLE: if (satir_tamam) begin
                    if (satir_mod == 3'd7) begin yaz_say <= 7'd0; durum <= S_YAZ; end
                    else begin satir <= satir + 7'd1; satir_mod <= satir_mod + 3'd1; durum <= S_BASLAT; end
                end
                S_YAZ: begin
                    p_yaz_etkin <= 1'b1; p_yaz_adres <= {satir[5:3], yaz_say[5:0]};
                    p_yaz_veri <= {pbuf[7*64 + yaz_say[5:0]], pbuf[6*64 + yaz_say[5:0]], pbuf[5*64 + yaz_say[5:0]], pbuf[4*64 + yaz_say[5:0]],
                                   pbuf[3*64 + yaz_say[5:0]], pbuf[2*64 + yaz_say[5:0]], pbuf[1*64 + yaz_say[5:0]], pbuf[0*64 + yaz_say[5:0]]};
                    if (yaz_say == 7'd63) begin
                        if (satir == 7'd63) begin bitti <= 1'b1; durum <= D_BOS; end
                        else begin satir <= satir + 7'd1; satir_mod <= 3'd0; durum <= S_BASLAT; end
                    end else yaz_say <= yaz_say + 7'd1;
                end
                default: durum <= D_BOS;
            endcase

            // skor okuma hatti: skor_ic_adres yayinlandi -> bir cevrim sonra veri; Softmax girisine bir kayit daha
            gir_gecerli_d2 <= gir_gecerli_d; gir_idx_d2 <= gir_idx_d;
            if (gir_gecerli_d2) begin
                sm_giris_gecerli <= 1'b1; sm_giris_veri <= {{16{skor_ic_veri[15]}}, skor_ic_veri}; sm_giris_maske <= (gir_idx_d2 < uzunluk);
            end
        end
    end
endmodule
