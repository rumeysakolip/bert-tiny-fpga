// -----------------------------------------------------------------------------
// softmax_birim.v -- tamsayi Softmax: L adet INT32 skor (+maske) -> L adet UINT8 olasilik (G11)
// Altin model: dogrusal_olmayan.softmax_tam
//   enb  = max(skor | maske=1)              fark = enb - skor  (>= 0)
//   idx  = min((fark * M0) >> 16, 511)      e = exp_lut[idx]  (maskeli: 0)     (LUT 512 x 16 bit, host yukler)
//   top  = max(sum(e), 1)                   p = min((e*255 + top/2) / top, 255)
//        bolme: satir basina bir kez R = floor(2^24/top) (ardisik), sonra eleman basina carpma + tek duzeltme (ters_bolucu.v, Konu 4a);
//        bolum 255'i asamaz (e <= top), asarsa min(.,255) ile ayni sekilde 255'e doyar.
// Akis: start -> L giris (giris_gecerli, giris_veri, giris_maske) -> hesap -> L cikis (cikis_gecerli, cikis_son).
// Genislik: skor 32 bit isaretli, M0 <= 2^24, fark <= 2^33 -> carpim < 2^58.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module softmax_birim #(
    parameter SATIR_UZUNLUGU    = 64,
    parameter SATIR_UZUNLUGU_LOG2 = 6
) (
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 tablo_yaz_etkin,
    input  wire [8:0]           tablo_yaz_adres,
    input  wire [15:0]          tablo_yaz_veri,
    input  wire [23:0]          olcek_m0,
    input  wire                 baslat,
    output wire                 giris_hazir,
    input  wire                 giris_gecerli,
    input  wire signed [31:0]   giris_veri,
    input  wire                 giris_maske,
    output reg                  cikis_gecerli,
    output reg  [7:0]           cikis_veri,
    output reg                  cikis_son,
    output wire                 mesgul
);
    // DURUM_FARK: elemanlari kesintisiz boru hattina besle (oku -> fark -> carpim -> LUT -> topla), DURUM_TERS_BASLAT: ters deger baslat, DURUM_TERS_BEKLE: ters degeri bekle,
    // DURUM_CIKTI: bolme boru hattina besle, DURUM_BOSALT: son cikisi bekle
    localparam DURUM_BOSTA = 4'd0, DURUM_YUKLE = 4'd1, DURUM_FARK = 4'd2, DURUM_TERS_BASLAT = 4'd5, DURUM_TERS_BEKLE = 4'd6, DURUM_CIKTI = 4'd7, DURUM_BOSALT = 4'd9;

    reg [3:0] durum;
    reg [SATIR_UZUNLUGU_LOG2:0] sayac;
    reg signed [31:0] skor_tamponu [0:SATIR_UZUNLUGU-1];
    reg               maske_tamponu [0:SATIR_UZUNLUGU-1];
    reg [15:0]        us_tamponu [0:SATIR_UZUNLUGU-1];
    (* ram_style = "block" *) reg [15:0] us_tablosu [0:511];          // BRAM: yazma host'tan, okuma esik (senkron, 1 cevrim)
    reg [15:0]        us_tablo_okunan;
    reg signed [33:0] en_buyuk_skor;
    reg               en_buyuk_gecerli;
    reg [23:0]        olcek_m0_kayit;
    reg [21:0]        toplam_us;
    // eleman boru hatti (Konu 6): cevrimde bir eleman; eski surumde eleman basina 4 durum (FARK, IDX, EXP, ACC) idi
    reg               asama1_gecerli, asama2_gecerli, asama3_gecerli, asama4_gecerli, asama5_gecerli;
    reg [SATIR_UZUNLUGU_LOG2-1:0]    asama1_indeks, asama2_indeks, asama3_indeks, asama4_indeks, asama5_indeks;
    reg               asama1_maske, asama2_maske, asama3_maske, asama4_maske, asama5_maske;
    reg signed [33:0] asama1_skor;
    reg [33:0]        skor_farki;
    reg [57:0]        carpim1, carpim2;

    wire [21:0] bolen_toplam = (toplam_us == 22'd0) ? 22'd1 : toplam_us;           // max(toplam, 1)
    reg  [SATIR_UZUNLUGU_LOG2:0] cikis_sayaci;                                          // cikis sayaci
    wire        ters_baslat = (durum == DURUM_TERS_BASLAT);
    wire        ters_hazir, bolum_gecerli;
    wire [7:0]  bolum_veri;
    wire [23:0] pay_hesap;
    reg  [23:0] pay_kayit;                                           // ebuf okuma + carpma + toplama, bolucu girisinden once yazmaca (Konu 6)
    reg         pay_gecerli_kayit;
    ters_bolucu #(.PAY_GENISLIGI(24), .BOLEN_GENISLIGI(22), .BOLUM_GENISLIGI(8), .YAN_GENISLIGI(1)) u_ters_bolucu (.clk(clk), .rst(rst), .ters_baslat(ters_baslat), .bolen(bolen_toplam),
        .ters_hazir(ters_hazir), .pay_gecerli(pay_gecerli_kayit), .pay_veri(pay_kayit), .yan_bilgi_giris(1'b0), .bolum_gecerli(bolum_gecerli), .bolum(bolum_veri),
        .kalan_var(), .tasma(), .yan_bilgi_cikis());

    assign giris_hazir = (durum == DURUM_YUKLE);
    assign mesgul     = (durum != DURUM_BOSTA);

    always @(posedge clk) begin
        if (tablo_yaz_etkin) us_tablosu[tablo_yaz_adres] <= tablo_yaz_veri;
        us_tablo_okunan <= us_tablosu[tablo_adresi];                                   // idx (carpim2'den) sunulur, bir sonraki cevrimde us_tablo_okunan hazirdir
    end

    wire [SATIR_UZUNLUGU_LOG2-1:0] satir_sirasi = sayac[SATIR_UZUNLUGU_LOG2-1:0];
    wire [8:0]  tablo_adresi = (carpim2[57:16] > 42'd511) ? 9'd511 : carpim2[24:16];
    wire [15:0] us_degeri = asama5_maske ? us_tablo_okunan : 16'd0;
    assign pay_hesap = us_tamponu[satir_sirasi] * 8'd255 + 22'd0;

    always @(posedge clk) begin
        if (rst) begin
            durum <= DURUM_BOSTA; sayac <= 0; cikis_gecerli <= 1'b0; cikis_veri <= 8'd0; cikis_son <= 1'b0; cikis_sayaci <= 0; pay_kayit <= 0; pay_gecerli_kayit <= 1'b0;
            en_buyuk_skor <= 0; en_buyuk_gecerli <= 1'b0; olcek_m0_kayit <= 0; skor_farki <= 0; carpim1 <= 0; carpim2 <= 0; toplam_us <= 0;
            asama1_gecerli <= 1'b0; asama2_gecerli <= 1'b0; asama3_gecerli <= 1'b0; asama4_gecerli <= 1'b0; asama5_gecerli <= 1'b0;
            asama1_indeks <= 0; asama2_indeks <= 0; asama3_indeks <= 0; asama4_indeks <= 0; asama5_indeks <= 0; asama1_maske <= 1'b0; asama2_maske <= 1'b0; asama3_maske <= 1'b0; asama4_maske <= 1'b0; asama5_maske <= 1'b0; asama1_skor <= 0;
        end else begin
            pay_kayit <= pay_hesap; pay_gecerli_kayit <= (durum == DURUM_CIKTI);
            // eleman boru hatti (serbest akar; gecerli bayragi ile)
            asama1_gecerli <= (durum == DURUM_FARK) && (sayac < SATIR_UZUNLUGU); asama1_indeks <= satir_sirasi; asama1_skor <= skor_tamponu[satir_sirasi]; asama1_maske <= maske_tamponu[satir_sirasi];
            asama2_gecerli <= asama1_gecerli; asama2_indeks <= asama1_indeks; asama2_maske <= asama1_maske; skor_farki <= asama1_maske ? (en_buyuk_skor - asama1_skor) : 34'd0;
            asama3_gecerli <= asama2_gecerli; asama3_indeks <= asama2_indeks; asama3_maske <= asama2_maske; carpim1 <= skor_farki * olcek_m0_kayit;
            asama4_gecerli <= asama3_gecerli; asama4_indeks <= asama3_indeks; asama4_maske <= asama3_maske; carpim2 <= carpim1;
            asama5_gecerli <= asama4_gecerli; asama5_indeks <= asama4_indeks; asama5_maske <= asama4_maske;
            if (asama5_gecerli) begin us_tamponu[asama5_indeks] <= us_degeri; toplam_us <= toplam_us + us_degeri; end
            // cikis: boru hattindan gelen her bolum bir cikis elemanidir
            cikis_gecerli <= bolum_gecerli;
            cikis_son  <= bolum_gecerli && (cikis_sayaci == SATIR_UZUNLUGU-1);
            if (bolum_gecerli) begin cikis_veri <= bolum_veri; cikis_sayaci <= (cikis_sayaci == SATIR_UZUNLUGU-1) ? {(SATIR_UZUNLUGU_LOG2+1){1'b0}} : cikis_sayaci + 1'b1; end
            case (durum)
                DURUM_BOSTA: if (baslat) begin
                    olcek_m0_kayit <= olcek_m0; sayac <= 0; cikis_sayaci <= 0; en_buyuk_gecerli <= 1'b0; en_buyuk_skor <= 0; toplam_us <= 0; durum <= DURUM_YUKLE;
                end
                DURUM_YUKLE: if (giris_gecerli) begin
                    skor_tamponu[satir_sirasi] <= giris_veri; maske_tamponu[satir_sirasi] <= giris_maske;
                    if (giris_maske && (!en_buyuk_gecerli || giris_veri > en_buyuk_skor)) begin en_buyuk_skor <= giris_veri; en_buyuk_gecerli <= 1'b1; end
                    if (sayac == SATIR_UZUNLUGU-1) begin sayac <= 0; durum <= DURUM_FARK; end else sayac <= sayac + 1;
                end
                DURUM_FARK: begin                                              // L eleman besle, 5 asama bosalt
                    if (sayac == SATIR_UZUNLUGU+4) begin sayac <= 0; durum <= DURUM_TERS_BASLAT; end else sayac <= sayac + 1;
                end
                DURUM_TERS_BASLAT: durum <= DURUM_TERS_BEKLE;                                       // ters_baslat bu durumda 1 cevrimlik darbedir
                DURUM_TERS_BEKLE: if (ters_hazir) begin sayac <= 0; durum <= DURUM_CIKTI; end
                DURUM_CIKTI: begin                                               // her cevrimde bir eleman
                    if (sayac == SATIR_UZUNLUGU-1) durum <= DURUM_BOSALT; else sayac <= sayac + 1;
                end
                DURUM_BOSALT: ;                                                   // son cikis gelince asagida IDLE'a donulur
                default: durum <= DURUM_BOSTA;
            endcase
            if (bolum_gecerli && cikis_sayaci == SATIR_UZUNLUGU-1) durum <= DURUM_BOSTA;
        end
    end
endmodule
