// -----------------------------------------------------------------------------
// layernorm_birim.v -- tamsayi LayerNorm: INT (GIRIS_GENISLIGI bit) satir -> INT8 (G11)
// Altin model: dogrusal_olmayan.katman_norm_tam (g_bit = 12, N = 2^LOGN)
//   ort = (sum + N/2) >>> LOGN ; d = q - ort ; var = (sum(d^2) + N/2) >> LOGN
//   std = max(isqrt(var + epsilon_q), 1)            (isqrt: bit-bit karekok, floor; Newton ile ayni sonuc)
//   y   = floor((d*2^12 + std/2) / std)          (satir basina bir kez R = floor(2^31/std), eleman basina carpma + tek duzeltme:
//                                                  ters_bolucu.v, Konu 4a; bolum 17 bite sigar, sigmazsa doyar)
//   cikis = clip8( ((y*gamma_q[i]) * M0 + 2^(n-1)) >>> n + beta_q[i] )
// Akis: start -> N giris (giris_gecerli) -> hesap -> N cikis (cikis_gecerli, cikis_son).
// Genislik varsayimlari (g11_vektor_uret.py istatistik.json ile denetlenir):
//   |q| < 2^(GIRIS_GENISLIGI-1); |y| <= sqrt(N)*2^12 ~ 46341 (17 bit isaretli); gamma_q 16 bit isaretli; M0 <= 2^31-1.
// gamma_q / beta_q tablolari parametre_yaz_etkin ile yuklenir (host, kat basina bir kez).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module layernorm_birim #(
    parameter KANAL_SAYISI    = 128,
    parameter KANAL_SAYISI_LOG2 = 7,
    parameter GIRIS_GENISLIGI  = 18,
    parameter KESIR_BITI    = 12
) (
    input  wire                 clk,
    input  wire                 rst,
    // parametreler
    input  wire                 parametre_yaz_etkin,
    input  wire [KANAL_SAYISI_LOG2-1:0]      parametre_yaz_adres,
    input  wire signed [GAMMA_GENISLIGI-1:0] parametre_gamma,
    input  wire signed [15:0]   parametre_beta,
    input  wire [39:0]          epsilon_q,
    input  wire [30:0]          olcek_m0,
    input  wire [5:0]           olcek_kaydirma,
    // komut / veri
    input  wire                 baslat,
    output wire                 giris_hazir,
    input  wire                 giris_gecerli,
    input  wire signed [GIRIS_GENISLIGI-1:0] giris_veri,
    output reg                  cikis_gecerli,
    output reg signed [7:0]     cikis_veri,
    output reg                  cikis_son,
    output wire                 mesgul
);
    // G'ye bagli genislikler (G=12'de eski sabitlerle ayni: YB=17, GWID=16, GAMMA_CARPIM_GENISLIGI=33, OLCEK_TOPLAM_GENISLIGI=66)
    localparam BOLUM_A_GENISLIGI   = KESIR_BITI + 5;                // y = d/std * 2^G genisligi (isaretli)
    localparam GAMMA_GENISLIGI = KESIR_BITI + 4;                // gamma_q = gamma * 2^G genisligi (isaretli)
    localparam GAMMA_CARPIM_GENISLIGI  = BOLUM_A_GENISLIGI + GAMMA_GENISLIGI;
    localparam OLCEK_TOPLAM_GENISLIGI  = GAMMA_CARPIM_GENISLIGI + 33;
    localparam TOPLAM_GENISLIGI = GIRIS_GENISLIGI + KANAL_SAYISI_LOG2;
    localparam FARK_GENISLIGI   = GIRIS_GENISLIGI + 1;
    localparam KARELER_TOPLAMI_GENISLIGI  = 2*FARK_GENISLIGI + KANAL_SAYISI_LOG2;        // 2*19+7 = 45
    localparam VARYANS_GENISLIGI = 40;
    localparam KAREKOK_BIT_SAYISI    = VARYANS_GENISLIGI/2;             // karekok bit sayisi

    // DURUM_TERS_BASLAT: ters deger baslat, DURUM_TERS_BEKLE: ters degeri bekle, DURUM_ELEMAN_AKIT: elemanlari boru hattina besle, DURUM_SON_CIKTI_BEKLE: son cikisi bekle (eski durum
    // numaralari 4 bitte kalsin diye yeniden kullanildi; S_M2, S_SH, S_OUT artik yok: carpma/kaydirma/cikis boru hatti asamalaridir)
    localparam DURUM_BOSTA = 4'd0, DURUM_YUKLE = 4'd1, DURUM_ORTALAMA = 4'd2, DURUM_KARE_TOPLA = 4'd3, DURUM_VARYANS = 4'd4, DURUM_KAREKOK = 4'd5,
               DURUM_STD_SEC = 4'd6, DURUM_TERS_BASLAT = 4'd7, DURUM_TERS_BEKLE = 4'd8, DURUM_ELEMAN_AKIT = 4'd9, DURUM_SON_CIKTI_BEKLE = 4'd10;

    reg [3:0] durum;
    reg [KANAL_SAYISI_LOG2:0] sayac;
    reg signed [GIRIS_GENISLIGI-1:0] giris_tamponu [0:KANAL_SAYISI-1];
    (* ram_style = "block" *) reg signed [GAMMA_GENISLIGI-1:0] gamma_tablosu [0:KANAL_SAYISI-1];     // BRAM: senkron okuma, adres boru hattinin onceki asamasindan sunulur
    (* ram_style = "block" *) reg signed [GAMMA_GENISLIGI-1:0] beta_tablosu [0:KANAL_SAYISI-1];
    reg signed [GAMMA_GENISLIGI-1:0] gamma_okunan, beta_okunan;
    reg signed [TOPLAM_GENISLIGI-1:0] toplam;
    reg signed [FARK_GENISLIGI-1:0]   ortalama;
    reg [KARELER_TOPLAMI_GENISLIGI-1:0]         kareler_toplami;
    reg [VARYANS_GENISLIGI-1:0]        karekok_girisi, karekok_sonucu, karekok_bit;
    reg [KAREKOK_BIT_SAYISI:0]             karekok_sayaci;
    reg [31:0]             standart_sapma;
    reg [39:0]             epsilon_kayit;
    reg [30:0]             olcek_m0_kayit;
    reg [5:0]              kaydirma_kayit;

    // bolucu (satir basina ters deger + eleman basina carpma/duzeltme)
    wire        ters_baslat = (durum == DURUM_TERS_BASLAT);
    wire        ters_hazir, bolum_gecerli, bolum_kalan_var, bolum_tasma;
    wire [BOLUM_A_GENISLIGI-1:0] bolum_veri;
    wire [KANAL_SAYISI_LOG2+1:0] yan_bilgi_cikis;                                 // {isaret, son, indeks}
    // ters degerden ONCE hazirlik boru hatti (Konu 6): oku -> d = q - ort -> num = (d<<G) + std/2 -> |num|, isaret
    reg                  hazirlik0_gecerli, hazirlik1_gecerli, hazirlik2_gecerli, hazirlik3_gecerli;
    reg                  hazirlik0_son, hazirlik1_son, hazirlik2_son, hazirlik3_son;
    reg [KANAL_SAYISI_LOG2-1:0]       hazirlik0_indeks, hazirlik1_indeks, hazirlik2_indeks, hazirlik3_indeks;
    reg signed [GIRIS_GENISLIGI-1:0] hazirlik0_girdi;
    reg signed [FARK_GENISLIGI-1:0] hazirlik1_fark;
    reg signed [FARK_GENISLIGI+KESIR_BITI:0] hazirlik2_pay;
    reg [FARK_GENISLIGI+KESIR_BITI-1:0]     hazirlik3_pay_mutlak;
    reg                  hazirlik3_negatif;
    // elemanin ters-bolme SONRASI boru hatti: y -> y*gamma -> *M0 -> +yuvarlama -> kaydir -> +beta -> kirp
    reg                  bolum_a_gecerli, bolum_b_gecerli, gamma_carpim_gecerli, olcek_carpim_gecerli, olcek_toplam_gecerli, yuvarlama_gecerli, kaydirma_gecerli, beta_gecerli;
    reg                  bolum_a_son, bolum_b_son, gamma_carpim_son, olcek_carpim_son, olcek_toplam_son, yuvarlama_son, kaydirma_son, beta_son;
    reg [KANAL_SAYISI_LOG2-1:0]       bolum_a_indeks, bolum_b_indeks, gamma_carpim_indeks, olcek_carpim_indeks, olcek_toplam_indeks, yuvarlama_indeks, kaydirma_indeks;
    reg signed [BOLUM_A_GENISLIGI-1:0]  bolum_b;                 // y'nin bir cevrim gecikmis kopyasi: gam BRAM cikisi ile DSP girisi arasina yazmac (gamma_gecikmis) icin hizalama
    reg signed [GAMMA_GENISLIGI-1:0] gamma_gecikmis;
    // gamma_carpim * M0 iki asamada: M0 = hi*2^16 + lo; kismi carpimlar DSP'de, toplama SERBEST (DSP->DSP zincirinde ara yazmac yoktu; 150 MHz'de -0,44 ns)
    reg signed [GAMMA_CARPIM_GENISLIGI+16:0] olcek_carpim_alt;
    reg signed [GAMMA_CARPIM_GENISLIGI+15:0] olcek_carpim_ust;
    reg signed [GAMMA_CARPIM_GENISLIGI+16:0] olcek_carpim_alt_kayit;
    reg signed [GAMMA_CARPIM_GENISLIGI+15:0] olcek_carpim_ust_kayit;
    reg                  olcek_carpim_kayit_gecerli, olcek_carpim_kayit_son;
    reg [KANAL_SAYISI_LOG2-1:0] olcek_carpim_kayit_indeks;
    reg signed [BOLUM_A_GENISLIGI-1:0]  bolum_a;
    reg signed [GAMMA_CARPIM_GENISLIGI-1:0] gamma_carpim;
    reg signed [OLCEK_TOPLAM_GENISLIGI-1:0] olcek_toplam;
    reg signed [OLCEK_TOPLAM_GENISLIGI-1:0] yuvarlanmis;
    reg signed [OLCEK_TOPLAM_GENISLIGI-1:0] kaydirilmis;
    reg signed [OLCEK_TOPLAM_GENISLIGI:0]   beta_eklenmis;
    reg signed [FARK_GENISLIGI-1:0] fark_kayit;
    reg signed [2*FARK_GENISLIGI-1:0] fark_karesi_kayit;
    reg kare_asama1_gecerli, kare_asama2_gecerli;
    wire [KANAL_SAYISI_LOG2-1:0] yan_indeks   = yan_bilgi_cikis[KANAL_SAYISI_LOG2-1:0];
    wire            yan_son_bayragi  = yan_bilgi_cikis[KANAL_SAYISI_LOG2];
    wire            yan_negatif  = yan_bilgi_cikis[KANAL_SAYISI_LOG2+1];

    assign giris_hazir = (durum == DURUM_YUKLE);
    assign mesgul     = (durum != DURUM_BOSTA);

    always @(posedge clk) begin
        if (parametre_yaz_etkin) begin gamma_tablosu[parametre_yaz_adres] <= parametre_gamma; beta_tablosu[parametre_yaz_adres] <= parametre_beta; end
        gamma_okunan <= gamma_tablosu[yan_indeks];            // y asamasi ile ayni cevrimde hazir (bolum_a_indeks = yan_indeks'in bir sonraki cevrim degeri)
        gamma_gecikmis <= gamma_okunan;                 // yd asamasi ile ayni cevrimde hazir; DSP girisi BRAM cikisindan dogrudan beslenmez
        beta_okunan <= beta_tablosu[yuvarlama_indeks];              // kaydirilmis asamasi ile ayni cevrimde hazir (kaydirma_indeks = yuvarlama_indeks'nin bir sonraki cevrim degeri)
    end

    wire [KANAL_SAYISI_LOG2-1:0] satir_sirasi = sayac[KANAL_SAYISI_LOG2-1:0];
    wire signed [GIRIS_GENISLIGI-1:0] giris_okunan = giris_tamponu[satir_sirasi];
    wire signed [FARK_GENISLIGI-1:0] fark_anlik = giris_okunan - ortalama;
    wire signed [2*FARK_GENISLIGI-1:0] fark_karesi = fark_anlik * fark_anlik;
    wire signed [FARK_GENISLIGI+KESIR_BITI:0] hazirlik1_kaydirilmis = hazirlik1_fark <<< KESIR_BITI;                                          // d << G
    // |num| < 2^(FARK_GENISLIGI+G-1+1): |d| < 2^(FARK_GENISLIGI-1) => |d<<G| + std/2 < 2^(FARK_GENISLIGI+G-1) + 2^19; 3. asamada FARK_GENISLIGI+G bite kirpilir
    ters_bolucu #(.PAY_GENISLIGI(FARK_GENISLIGI+KESIR_BITI), .BOLEN_GENISLIGI(20), .BOLUM_GENISLIGI(BOLUM_A_GENISLIGI), .YAN_GENISLIGI(KANAL_SAYISI_LOG2 + 2)) u_ters_bolucu (.clk(clk), .rst(rst), .ters_baslat(ters_baslat), .bolen(standart_sapma[19:0]),
        .ters_hazir(ters_hazir), .pay_gecerli(hazirlik3_gecerli), .pay_veri(hazirlik3_pay_mutlak), .yan_bilgi_giris({hazirlik3_negatif, hazirlik3_son, hazirlik3_indeks}),
        .bolum_gecerli(bolum_gecerli), .bolum(bolum_veri), .kalan_var(bolum_kalan_var), .tasma(bolum_tasma), .yan_bilgi_cikis(yan_bilgi_cikis));


    // karekok yinelemesi uc cevrimde (Konu 6): karekok_deneme = res + one yazmaca, ge = (op >= karekok_deneme) yazmaca, sonra cikarma/guncelleme
    reg  [VARYANS_GENISLIGI-1:0] karekok_deneme;
    reg  [1:0]       karekok_evresi;
    reg              karekok_buyuk_esit;
    wire signed [OLCEK_TOPLAM_GENISLIGI-1:0] yuvarlama_sabiti = (kaydirma_kayit == 6'd0) ? {OLCEK_TOPLAM_GENISLIGI{1'b0}} : ({{(OLCEK_TOPLAM_GENISLIGI-1){1'b0}}, 1'b1} <<< (kaydirma_kayit - 6'd1));

    always @(posedge clk) begin
        if (rst) begin
            durum <= DURUM_BOSTA; sayac <= 0; cikis_gecerli <= 1'b0; cikis_veri <= 8'sd0; cikis_son <= 1'b0;
            toplam <= 0; ortalama <= 0; kareler_toplami <= 0; standart_sapma <= 32'd1; bolum_a <= 0; gamma_carpim <= 0; olcek_toplam <= 0; kaydirilmis <= 0; fark_kayit <= 0; fark_karesi_kayit <= 0; kare_asama1_gecerli <= 1'b0; kare_asama2_gecerli <= 1'b0;
            karekok_girisi <= 0; karekok_sonucu <= 0; karekok_bit <= 0; karekok_sayaci <= 0; epsilon_kayit <= 0; olcek_m0_kayit <= 0; kaydirma_kayit <= 0; karekok_deneme <= 0; karekok_evresi <= 2'd0; karekok_buyuk_esit <= 1'b0;
            bolum_a_gecerli <= 1'b0; bolum_b_gecerli <= 1'b0; gamma_carpim_gecerli <= 1'b0; olcek_carpim_gecerli <= 1'b0; olcek_toplam_gecerli <= 1'b0; yuvarlama_gecerli <= 1'b0; kaydirma_gecerli <= 1'b0; beta_gecerli <= 1'b0;
            bolum_a_son <= 1'b0; bolum_b_son <= 1'b0; gamma_carpim_son <= 1'b0; olcek_carpim_son <= 1'b0; olcek_toplam_son <= 1'b0; yuvarlama_son <= 1'b0; kaydirma_son <= 1'b0; beta_son <= 1'b0;
            bolum_a_indeks <= 0; bolum_b_indeks <= 0; bolum_b <= 0; gamma_carpim_indeks <= 0; olcek_carpim_indeks <= 0; olcek_toplam_indeks <= 0; yuvarlama_indeks <= 0; kaydirma_indeks <= 0; yuvarlanmis <= 0; beta_eklenmis <= 0; olcek_carpim_alt <= 0; olcek_carpim_ust <= 0;
            olcek_carpim_kayit_gecerli <= 1'b0; olcek_carpim_kayit_son <= 1'b0; olcek_carpim_kayit_indeks <= 0; olcek_carpim_alt_kayit <= 0; olcek_carpim_ust_kayit <= 0;
            hazirlik0_gecerli <= 1'b0; hazirlik1_gecerli <= 1'b0; hazirlik2_gecerli <= 1'b0; hazirlik3_gecerli <= 1'b0; hazirlik0_son <= 1'b0; hazirlik1_son <= 1'b0; hazirlik2_son <= 1'b0; hazirlik3_son <= 1'b0;
            hazirlik0_indeks <= 0; hazirlik1_indeks <= 0; hazirlik2_indeks <= 0; hazirlik3_indeks <= 0; hazirlik0_girdi <= 0; hazirlik1_fark <= 0; hazirlik2_pay <= 0; hazirlik3_pay_mutlak <= 0; hazirlik3_negatif <= 1'b0;
        end else begin
            // ---- ters degerden once hazirlik (serbest akar) ----
            hazirlik0_gecerli <= (durum == DURUM_ELEMAN_AKIT); hazirlik0_son <= (sayac == KANAL_SAYISI-1); hazirlik0_indeks <= satir_sirasi; hazirlik0_girdi <= giris_okunan;
            hazirlik1_gecerli <= hazirlik0_gecerli; hazirlik1_son <= hazirlik0_son; hazirlik1_indeks <= hazirlik0_indeks; hazirlik1_fark <= hazirlik0_girdi - ortalama;
            hazirlik2_gecerli <= hazirlik1_gecerli; hazirlik2_son <= hazirlik1_son; hazirlik2_indeks <= hazirlik1_indeks; hazirlik2_pay <= hazirlik1_kaydirilmis + $signed({1'b0, standart_sapma[31:1]});
            hazirlik3_gecerli <= hazirlik2_gecerli; hazirlik3_son <= hazirlik2_son; hazirlik3_indeks <= hazirlik2_indeks; hazirlik3_negatif <= hazirlik2_pay[FARK_GENISLIGI+KESIR_BITI]; hazirlik3_pay_mutlak <= hazirlik2_pay[FARK_GENISLIGI+KESIR_BITI] ? (~hazirlik2_pay + 1'b1) : hazirlik2_pay;
            // ---- eleman boru hatti (serbest akar; gecerli bayragi ile) ----
            // y: floor(num/std); negatifte -ceil(|num|/std)
            bolum_a_gecerli <= bolum_gecerli; bolum_a_son <= yan_son_bayragi; bolum_a_indeks <= yan_indeks;
            bolum_a   <= yan_negatif ? -$signed(bolum_veri + ((bolum_kalan_var) ? {{(BOLUM_A_GENISLIGI-1){1'b0}}, 1'b1} : {BOLUM_A_GENISLIGI{1'b0}})) : $signed(bolum_veri);
            bolum_b_gecerli <= bolum_a_gecerli; bolum_b_son <= bolum_a_son; bolum_b_indeks <= bolum_a_indeks; bolum_b <= bolum_a;
            gamma_carpim_gecerli <= bolum_b_gecerli; gamma_carpim_son <= bolum_b_son; gamma_carpim_indeks <= bolum_b_indeks; gamma_carpim <= bolum_b * gamma_gecikmis;
            olcek_carpim_gecerli <= gamma_carpim_gecerli; olcek_carpim_son <= gamma_carpim_son; olcek_carpim_indeks <= gamma_carpim_indeks;
            olcek_carpim_alt <= gamma_carpim * $signed({1'b0, olcek_m0_kayit[15:0]});
            olcek_carpim_ust <= gamma_carpim * $signed({1'b0, olcek_m0_kayit[30:16]});
            // DSP'den DSP'ye zincirli carpimin ardina ek yazmac asamasi: zincir icindeki ara yazmaclar bu sayede kullanilir (150 MHz)
            olcek_carpim_kayit_gecerli <= olcek_carpim_gecerli; olcek_carpim_kayit_son <= olcek_carpim_son; olcek_carpim_kayit_indeks <= olcek_carpim_indeks;
            olcek_carpim_alt_kayit <= olcek_carpim_alt; olcek_carpim_ust_kayit <= olcek_carpim_ust;
            olcek_toplam_gecerli <= olcek_carpim_kayit_gecerli; olcek_toplam_son <= olcek_carpim_kayit_son; olcek_toplam_indeks <= olcek_carpim_kayit_indeks; olcek_toplam <= olcek_carpim_alt_kayit + (olcek_carpim_ust_kayit <<< 16);
            yuvarlama_gecerli <= olcek_toplam_gecerli; yuvarlama_son <= olcek_toplam_son; yuvarlama_indeks <= olcek_toplam_indeks; yuvarlanmis <= olcek_toplam + yuvarlama_sabiti;
            kaydirma_gecerli <= yuvarlama_gecerli; kaydirma_son <= yuvarlama_son; kaydirma_indeks <= yuvarlama_indeks; kaydirilmis <= yuvarlanmis >>> kaydirma_kayit;
            beta_gecerli <= kaydirma_gecerli; beta_son <= kaydirma_son; beta_eklenmis <= kaydirilmis + beta_okunan;
            cikis_gecerli <= beta_gecerli;
            cikis_son  <= beta_gecerli && beta_son;
            if (beta_gecerli) cikis_veri <= (beta_eklenmis > 127) ? 8'sd127 : (beta_eklenmis < -128) ? -8'sd128 : beta_eklenmis[7:0];
            case (durum)
                DURUM_BOSTA: if (baslat) begin
                    epsilon_kayit <= epsilon_q; olcek_m0_kayit <= olcek_m0; kaydirma_kayit <= olcek_kaydirma; sayac <= 0; toplam <= 0; kareler_toplami <= 0; durum <= DURUM_YUKLE;
                end
                DURUM_YUKLE: if (giris_gecerli) begin
                    giris_tamponu[satir_sirasi] <= giris_veri;
                    toplam <= toplam + giris_veri;
                    if (sayac == KANAL_SAYISI-1) begin sayac <= 0; durum <= DURUM_ORTALAMA; end else sayac <= sayac + 1;
                end
                DURUM_ORTALAMA: begin
                    ortalama <= (toplam + (1 <<< (KANAL_SAYISI_LOG2-1))) >>> KANAL_SAYISI_LOG2;
                    sayac <= 0; kareler_toplami <= 0; kare_asama1_gecerli <= 1'b0; kare_asama2_gecerli <= 1'b0; durum <= DURUM_KARE_TOPLA;
                end
                DURUM_KARE_TOPLA: begin                                     // 3 asamali boru hatti: d -> d*d -> toplam
                    fark_kayit   <= fark_anlik;
                    kare_asama1_gecerli   <= (sayac < KANAL_SAYISI);
                    fark_karesi_kayit <= fark_kayit * fark_kayit;
                    kare_asama2_gecerli   <= kare_asama1_gecerli;
                    if (kare_asama2_gecerli) kareler_toplami <= kareler_toplami + {{(KARELER_TOPLAMI_GENISLIGI-2*FARK_GENISLIGI){1'b0}}, fark_karesi_kayit};
                    if (sayac == KANAL_SAYISI+1) begin sayac <= 0; durum <= DURUM_VARYANS; end else sayac <= sayac + 1;
                end
                DURUM_VARYANS: begin
                    karekok_girisi  <= ((kareler_toplami + (1 << (KANAL_SAYISI_LOG2-1))) >> KANAL_SAYISI_LOG2) + epsilon_kayit;
                    karekok_sonucu <= 0; karekok_bit <= {2'b01, {(VARYANS_GENISLIGI-2){1'b0}}}; karekok_sayaci <= 0; karekok_evresi <= 2'd0; durum <= DURUM_KAREKOK;
                end
                DURUM_KAREKOK: begin                                   // bit-bit tamsayi karekok (floor); yineleme basina 3 cevrim
                    if (karekok_evresi == 2'd0) begin
                        karekok_deneme <= karekok_sonucu + karekok_bit; karekok_evresi <= 2'd1;
                    end else if (karekok_evresi == 2'd1) begin
                        karekok_buyuk_esit <= (karekok_girisi >= karekok_deneme); karekok_evresi <= 2'd2;
                    end else begin
                        if (karekok_buyuk_esit) begin karekok_girisi <= karekok_girisi - karekok_deneme; karekok_sonucu <= (karekok_sonucu >> 1) + karekok_bit; end
                        else karekok_sonucu <= karekok_sonucu >> 1;
                        karekok_bit  <= karekok_bit >> 2;
                        karekok_sayaci <= karekok_sayaci + 1;
                        karekok_evresi <= 2'd0;
                        if (karekok_sayaci == KAREKOK_BIT_SAYISI-1) begin durum <= DURUM_STD_SEC; sayac <= 0; end
                    end
                end
                DURUM_STD_SEC: begin standart_sapma <= karekok_sonucu[31:0] + 32'd0; durum <= DURUM_TERS_BASLAT; end
                DURUM_TERS_BASLAT: begin sayac <= 0; durum <= DURUM_TERS_BEKLE; end                    // ters_baslat bu durumda 1 cevrimlik darbedir
                DURUM_TERS_BEKLE: if (ters_hazir) durum <= DURUM_ELEMAN_AKIT;
                DURUM_ELEMAN_AKIT: begin                                                  // her cevrimde bir eleman
                    if (sayac == KANAL_SAYISI-1) durum <= DURUM_SON_CIKTI_BEKLE; else sayac <= sayac + 1;
                end
                DURUM_SON_CIKTI_BEKLE: ;                                                    // son cikis gelince asagida IDLE'a donulur
                default: durum <= DURUM_BOSTA;
            endcase
            if (beta_gecerli && beta_son) durum <= DURUM_BOSTA;
        end
    end
endmodule
