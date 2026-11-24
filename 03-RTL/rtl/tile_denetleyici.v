// -----------------------------------------------------------------------------
// tile_denetleyici.v -- tile sirasi, adres ureteci, golge acc ve cikis katı (G5)
//
// Bir katmani isler:  Y[T x C] = X[T x K] * W^T,  T = 8*NB token, C = 8*np kanal.
//   her cikis paneli p (8 kanal), her token blogu b (8 token): K boyunca akit, 8x8 acc.
//   Sira: panel disi dongu, token blogu ic dongu (panel 8 blokta yeniden kullanilir).
//
// Veri duzeni (OKUBENI.md):
//   aktivasyon BRAM sozcugu (b*K + k): bayt i = X[b*8+i][k]      (64 bit)
//   panel sozcugu (k)                : bayt j = W[p*8+j][k]      (64 bit)
//   -> A sutunu k = aktivasyon sozcugu, B satiri k = panel sozcugu; her ikisi 1 cevrimde.
//
// Zamanlama: start cevriminde adres k=0 sunulur; BRAM okumasi 1 cevrim gecikmeli oldugundan
//   sistolik dizi cevrim t'de k=t verisini gorur. Tile bitince (done) bir sonraki tile
//   AYNI cevrimde baslatilir (ayni panel icinde). Tile periyodu = K+2N-1 (hesap; Konu 6: sistolik girise yazmac, eskiden K+2N-2) + 1 (baslatma) = K+16.
//
// Golge acc: tile bitince c_matrisi (8x8x32) golgeye kopyalanir, sistolik dizi hemen sonraki tile'a
//   gecer; golge, siradaki tile hesaplanirken 64 cevrimde (cikis sirasi: kanal j dis, token i ic)
//   bias eklenerek akitilir. Golge ancak K+16 >= 64 oldugunda guvenle ortusur (K>=48).
//
// Panel el sikismasi: panel_hazir[b]=1 -> tampon b dolu (host set eder). panel_bitti: panelin son tile
//   cikisi tamamlanip tampon bos oldugunda 1 cevrim darbe (panel_bitti_tampon = bosalan tampon).
//   Host darbede hazir bitini siler, tamponu yeniden yazar, tekrar set eder.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module tile_denetleyici #(
    parameter DIZI_BOYUTU   = 8,
    parameter BLOK_SAYISI  = 8,          // token blogu sayisi (T = N*NB)
    parameter K_GENISLIGI  = 11,
    parameter PANEL_GENISLIGI  = 7,          // panel sayaci genisligi (np <= 127)
    parameter ADRES_GENISLIGI  = 12          // aktivasyon BRAM adres genisligi (NB*K <= 4096)
) (
    input  wire              clk,
    input  wire              rst,
    // katman denetimi
    input  wire              calistir,            // 1 cevrim darbe (IDLE iken)
    input  wire [K_GENISLIGI-1:0]     ayar_k,
    input  wire [PANEL_GENISLIGI-1:0]     ayar_panel_sayisi,
    input  wire [3:0]        ayar_blok_sayisi,            // etkin token blogu sayisi (1..8); 0 ya da 8den buyuk = NB (eski davranis)
    input  wire              a_isaretsiz,    // 1: A baytlari isaretsiz (UINT8 olasilik)
    output wire              mesgul,
    output reg               katman_bitti,
    // panel el sikismasi
    input  wire [1:0]        panel_hazir,
    output reg               panel_bitti,
    output reg               panel_bitti_tampon,
    // aktivasyon BRAM (kayitli okuma)
    output wire [ADRES_GENISLIGI-1:0]     aktivasyon_oku_adres,
    input  wire [63:0]       aktivasyon_oku_veri,
    // panel tamponu
    output wire              panel_oku_tampon,
    output wire [K_GENISLIGI-1:0]     panel_oku_adres,
    input  wire [63:0]       panel_oku_veri,
    // cikis kati bias/olcek_m0 sorgusu (panel_tamponu'na baglanir)
    output wire              sorgu_tampon,
    output wire [2:0]        sorgu_kanal,
    input  wire [31:0]       sorgu_bias,
    // cikis akisi (birikec + bias), kanal j dis, token i ic
    output reg               cikis_gecerli,
    output reg  [2:0]        cikis_token,
    output reg  [2:0]        cikis_kanal,
    output reg  [3:0]        cikis_blok,
    output reg  [PANEL_GENISLIGI-1:0]     cikis_panel,
    output reg               cikis_tile_son,        // tile'in son elemani
    output reg signed [31:0] cikis_birikec,
    // tanilama
    output reg               cikis_tasma       // golge ustune yazildi (yapisal hata)
);
    localparam DURUM_BOSTA  = 3'd0;
    localparam DURUM_PANEL_BEKLE = 3'd1;
    localparam DURUM_BESLE  = 3'd2;
    localparam DURUM_TILE_BEKLE  = 3'd3;
    localparam DURUM_BITIR = 3'd4;

    reg [2:0]      durum;
    reg [K_GENISLIGI-1:0]   k_uzunlugu_kayit, okuma_k;
    reg [PANEL_GENISLIGI-1:0]   panel_sayisi, panel_no;
    reg [3:0]      blok_no;
    reg [3:0]      son_blok_no;                // bu katmanin son token blogu indeksi = nb-1 (kos aninda ayar_blok_sayisi'den kilitlenir; kayitli: karsilastirma BRAM adresine gidiyor)
    reg [ADRES_GENISLIGI-1:0]   aktivasyon_taban;
    reg            gecerli_tampon;

    wire [DIZI_BOYUTU*DIZI_BOYUTU*32-1:0] c_matrisi;
    wire              dizi_bitti, dizi_mesgul;

    // ayar_blok_sayisi = 0 ya da NB'den buyukse tum bloklar islenir (ayar_blok_sayisi baglanmayan eski kullanim ile ayni davranis)
    wire [3:0]     etkin_blok_sayisi = (ayar_blok_sayisi == 4'd0 || ayar_blok_sayisi > BLOK_SAYISI) ? BLOK_SAYISI : ayar_blok_sayisi;

    // ---- tile baslatma / adresler ----
    wire ayni_panel_tile_baslat   = (durum == DURUM_TILE_BEKLE) && dizi_bitti && (blok_no != son_blok_no);
    wire yeni_panel_tile_baslat     = (durum == DURUM_PANEL_BEKLE) && panel_hazir[gecerli_tampon];
    wire tile_baslat = ayni_panel_tile_baslat | yeni_panel_tile_baslat;
    wire [K_GENISLIGI-1:0] etkin_okuma_k = tile_baslat ? {K_GENISLIGI{1'b0}} : okuma_k;
    wire [ADRES_GENISLIGI-1:0] etkin_aktivasyon_adres = ayni_panel_tile_baslat ? (aktivasyon_taban + k_uzunlugu_kayit) : aktivasyon_taban;
    assign aktivasyon_oku_adres = etkin_aktivasyon_adres + etkin_okuma_k;
    assign panel_oku_adres = etkin_okuma_k;
    assign panel_oku_tampon  = gecerli_tampon;
    assign mesgul      = (durum != DURUM_BOSTA);

    // ---- sistolik dizi ----
    wire [DIZI_BOYUTU*9-1:0] a_sutunu;
    genvar gi;
    generate
        for (gi = 0; gi < DIZI_BOYUTU; gi = gi + 1) begin : g_a_sutunu
            assign a_sutunu[gi*9 +: 9] = a_isaretsiz ? {1'b0, aktivasyon_oku_veri[gi*8 +: 8]}
                                                  : {aktivasyon_oku_veri[gi*8+7], aktivasyon_oku_veri[gi*8 +: 8]};
        end
    endgenerate

    sistolik_dizi #(.DIZI_BOYUTU(DIZI_BOYUTU), .A_GENISLIGI(9), .B_GENISLIGI(8), .BIRIKEC_GENISLIGI(32), .K_GENISLIGI(K_GENISLIGI)) u_sistolik_dizi (
        .clk(clk), .rst(rst), .baslat(tile_baslat), .k_uzunlugu(k_uzunlugu_kayit),
        .giris_gecerli(durum == DURUM_BESLE), .a_sutunu(a_sutunu), .b_satiri(panel_oku_veri),
        .c_matrisi(c_matrisi), .mesgul(dizi_mesgul), .bitti(dizi_bitti));

    // ---- golge acc + cikis katı ----
    reg [DIZI_BOYUTU*DIZI_BOYUTU*32-1:0] golge_birikec;
    reg              akitma_suruyor, akitma_tampon, akitma_son_blok;
    // Konu 6: golge elemani secimi (64:1 coklayici) ve bias toplami ayri asamalarda; toplama zinciri DSP girisine girdigi icin
    // (Vivado cikis yazmacini DSP B yazmacina emiyor) yol 8,7 ns idi.
    reg              ara_gecerli, ara_son;
    reg  [2:0]       ara_token, ara_kanal;
    reg  [3:0]       ara_blok;
    reg  [PANEL_GENISLIGI-1:0]    ara_panel;
    reg signed [31:0] ara_eleman, ara_bias;
    reg [5:0]        akitma_sira;
    reg [3:0]        akitma_blok;
    reg [PANEL_GENISLIGI-1:0]     akitma_panel;

    wire golge_yakala       = (durum == DURUM_TILE_BEKLE) && dizi_bitti;
    wire akitma_son_sira = (akitma_sira == 6'd63);
    assign sorgu_tampon = akitma_tampon;
    assign sorgu_kanal   = akitma_sira[5:3];
    wire [2:0] akitma_token  = akitma_sira[2:0];
    wire [2:0] akitma_kanal  = akitma_sira[5:3];
    wire signed [31:0] golge_elemani = golge_birikec[(akitma_token*DIZI_BOYUTU + akitma_kanal)*32 +: 32];

    always @(posedge clk) begin
        if (rst) begin
            akitma_suruyor <= 1'b0; akitma_sira <= 6'd0; cikis_gecerli <= 1'b0; cikis_tile_son <= 1'b0; cikis_tasma <= 1'b0; ara_gecerli <= 1'b0; ara_son <= 1'b0;
            ara_token <= 3'd0; ara_kanal <= 3'd0; ara_blok <= 4'd0; ara_panel <= {PANEL_GENISLIGI{1'b0}}; ara_eleman <= 32'sd0; ara_bias <= 32'sd0;
            panel_bitti <= 1'b0; panel_bitti_tampon <= 1'b0; akitma_son_blok <= 1'b0; akitma_tampon <= 1'b0;
            akitma_blok <= 4'd0; akitma_panel <= {PANEL_GENISLIGI{1'b0}};
            cikis_token <= 3'd0; cikis_kanal <= 3'd0; cikis_blok <= 4'd0; cikis_panel <= {PANEL_GENISLIGI{1'b0}}; cikis_birikec <= 32'sd0;
        end else begin
            panel_bitti <= 1'b0;
            ara_gecerli   <= akitma_suruyor;
            ara_son     <= akitma_suruyor & akitma_son_sira;
            ara_token       <= akitma_token;
            ara_kanal       <= akitma_kanal;
            ara_blok     <= akitma_blok;
            ara_panel   <= akitma_panel;
            ara_eleman    <= golge_elemani;
            ara_bias    <= $signed(sorgu_bias);
            cikis_gecerli <= ara_gecerli;
            cikis_tile_son   <= ara_son;
            cikis_token     <= ara_token;
            cikis_kanal     <= ara_kanal;
            cikis_blok   <= ara_blok;
            cikis_panel <= ara_panel;
            cikis_birikec   <= ara_eleman + ara_bias;
            if (akitma_suruyor && akitma_son_sira) begin
                akitma_suruyor <= 1'b0;
                if (akitma_son_blok) begin panel_bitti <= 1'b1; panel_bitti_tampon <= akitma_tampon; end
            end else if (akitma_suruyor) begin
                akitma_sira <= akitma_sira + 6'd1;
            end
            if (golge_yakala) begin
                if (akitma_suruyor && !akitma_son_sira) cikis_tasma <= 1'b1;     // onceki akitma bitmeden golge ezildi
                golge_birikec   <= c_matrisi;
                akitma_tampon   <= gecerli_tampon;
                akitma_blok   <= blok_no;
                akitma_panel <= panel_no;
                akitma_son_blok  <= (blok_no == son_blok_no);
                akitma_suruyor   <= 1'b1;
                akitma_sira   <= 6'd0;
            end
        end
    end

    // ---- ana FSM ----
    always @(posedge clk) begin
        if (rst) begin
            durum <= DURUM_BOSTA; k_uzunlugu_kayit <= {K_GENISLIGI{1'b0}}; okuma_k <= {K_GENISLIGI{1'b0}}; panel_sayisi <= {PANEL_GENISLIGI{1'b0}};
            panel_no <= {PANEL_GENISLIGI{1'b0}}; blok_no <= 4'd0; aktivasyon_taban <= {ADRES_GENISLIGI{1'b0}}; gecerli_tampon <= 1'b0; katman_bitti <= 1'b0; son_blok_no <= BLOK_SAYISI - 1;
        end else begin
            katman_bitti <= 1'b0;
            case (durum)
                DURUM_BOSTA: if (calistir) begin
                    k_uzunlugu_kayit <= ayar_k; panel_sayisi <= ayar_panel_sayisi; son_blok_no <= etkin_blok_sayisi - 4'd1; panel_no <= {PANEL_GENISLIGI{1'b0}}; blok_no <= 4'd0;
                    aktivasyon_taban <= {ADRES_GENISLIGI{1'b0}}; gecerli_tampon <= 1'b0; durum <= DURUM_PANEL_BEKLE;
                end
                DURUM_PANEL_BEKLE: if (yeni_panel_tile_baslat) begin
                    okuma_k <= {{(K_GENISLIGI-1){1'b0}}, 1'b1}; durum <= DURUM_BESLE;
                end
                DURUM_BESLE: begin
                    okuma_k <= okuma_k + 1'b1;
                    if (okuma_k == k_uzunlugu_kayit) durum <= DURUM_TILE_BEKLE;
                end
                DURUM_TILE_BEKLE: if (dizi_bitti) begin
                    if (ayni_panel_tile_baslat) begin
                        okuma_k <= {{(K_GENISLIGI-1){1'b0}}, 1'b1};
                        blok_no <= blok_no + 1'b1; aktivasyon_taban <= etkin_aktivasyon_adres; durum <= DURUM_BESLE;
                    end else if (panel_no == panel_sayisi - 1'b1) begin
                        durum <= DURUM_BITIR;
                    end else begin
                        panel_no <= panel_no + 1'b1; gecerli_tampon <= ~gecerli_tampon; blok_no <= 4'd0; aktivasyon_taban <= {ADRES_GENISLIGI{1'b0}};
                        durum <= DURUM_PANEL_BEKLE;
                    end
                end
                DURUM_BITIR: if (!akitma_suruyor && !ara_gecerli && !cikis_gecerli) begin
                    katman_bitti <= 1'b1; durum <= DURUM_BOSTA;
                end
                default: durum <= DURUM_BOSTA;
            endcase
        end
    end

endmodule
