// -----------------------------------------------------------------------------
// kart_mantik.v -- Basys 3 icin kart mantigi (pin ilkelleri disinda her sey burada; benzetimde dogrudan sinanir)
//   Akis: guc acilisi/dugme ile reset -> flas hazirlik darbeleri -> secilen cumlenin akisi flastan okunur (qspi_okuyucu)
//         -> ortak_ust (hizlandirici) -> sonuc (sinif, iki puan, sure) -> LED ve dort basamakli gosterge.
//   Girdiler : btn (orta dugme = bastan baslat), sw[1:0] = cumle secimi (0..3), sw[15:14] = gosterge secimi
//   Gosterge : 00 birinci puan | 01 ikinci puan | 10 sure (ms, ondalik nokta ile) | 11 okunan kilobayt (calisirken canli)
//   Tani (sw13 yukari): 00 akistan okunan cumle uzunlugu (cumle 0..3: 4, 4, 5, 6) | 01 akis denetim hatasi sayisi
//                       10 "ab": a = okunan cumle, b = sw[1:0]'in gordugu deger | 11 satir (katman*100 + satir)
//   sw[1:0] degisince hesap kendiliginden bastan baslar (btnC de bastan baslatir); yeniden baslayinca gosterge ~0,33 s "----" gosterir
//   LED      : [3:0] satir no | [4] katman no | [5] flas okuyor | [6] akis hatasi | [7] tasma/carpisma | [8] bitti
//              [9] sinif 1 | [10] sinif 0 | [11] iki puan da altin modelle ayni | [13:12] secili cumle | [14] flas okuma bitti | [15] canlilik
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module kart_mantik #(
    parameter BOL        = 4,                    // SCK yarim periyodu (sistem saati cevrimi); SCK = 100 MHz / (2*BOL)
    parameter [23:0] AKIS_TABAN = 24'h240000,    // flasta akisin basladigi adres
    parameter [31:0] CUMLE_BAYT = 32'd419429,    // bir cumlenin akis uzunlugu (bayt)
    parameter DEB_BIT    = 20                    // dugme suzgeci: 2^DEB_BIT cevrim
) (
    input  wire        clk,
    input  wire        btn,
    input  wire [15:0] sw,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire        dp,
    output wire [3:0]  an,
    // flas (pin ilkelleri kart_ust.v icinde)
    output wire        flas_sck,
    output wire        flas_cs_n,
    output wire        flas_io0_o,
    output wire        flas_io_oe,
    input  wire [3:0]  flas_io_i
);
    // ---------------- reset: guc acilisi + dugme (suzgecli) ----------------
    reg [11:0] por = 12'd0;
    wire       por_bitti = por[11];
    always @(posedge clk) if (!por_bitti) por <= por + 12'd1;

    reg [1:0] bsy = 2'b00;
    reg       btn_db = 1'b0;
    reg [DEB_BIT:0] deb = 0;
    always @(posedge clk) begin
        bsy <= {bsy[0], btn};
        if (bsy[1] == btn_db) deb <= 0;
        else begin
            deb <= deb + 1'b1;
            if (deb[DEB_BIT]) begin btn_db <= bsy[1]; deb <= 0; end
        end
    end
    // cumle anahtarlari (sw[1:0]): iki kademeli senkronlama; secim degisince hesap kendiliginden bastan baslar
    reg [1:0] sw_a = 2'b00, sw_s = 2'b00;
    always @(posedge clk) begin sw_a <= sw[1:0]; sw_s <= sw_a; end
    reg [1:0] sent;                    // flastan okunmakta olan cumle (baslangicta kilitlenir)
    reg [1:0] kd;                      // flas okuma denetimi durumu (asagida tanimli)
    localparam K_ISIT = 2'd0, K_OKU = 2'd1, K_BITTI = 2'd2;
    reg sw_yeniden = 1'b0;
    reg [5:0] uzat = 6'd0;             // anahtar kaynakli reseti 64 cevrim tut
    always @(posedge clk) begin
        sw_yeniden <= por_bitti && (kd != K_ISIT) && (sw_s != sent);
        if (sw_yeniden) uzat <= 6'd63; else if (uzat != 6'd0) uzat <= uzat - 6'd1;
    end
    reg rst_c = 1'b1;
    always @(posedge clk) rst_c <= !por_bitti | btn_db | sw_yeniden | (uzat != 6'd0);

    // ---------------- flas okuma denetimi ----------------
    reg [8:0]  isit;
    reg        basla_r;
    reg [23:0] adres_r;
    wire       q_sck, q_cs_n, q_io0, q_oe, q_mesgul, q_bitti;
    wire       bayt_gecerli, bayt_hazir;
    wire [7:0] bayt_veri;

    wire [31:0] ofs1 = CUMLE_BAYT, ofs2 = CUMLE_BAYT * 2, ofs3 = CUMLE_BAYT * 3;
    reg  [23:0] ofs_sec;
    always @* begin
        case (sw_s)
            2'd0: ofs_sec = AKIS_TABAN;
            2'd1: ofs_sec = AKIS_TABAN + ofs1[23:0];
            2'd2: ofs_sec = AKIS_TABAN + ofs2[23:0];
            default: ofs_sec = AKIS_TABAN + ofs3[23:0];
        endcase
    end

    initial begin kd = K_ISIT; isit = 9'd0; basla_r = 1'b0; sent = 2'd0; adres_r = AKIS_TABAN; end
    always @(posedge clk) begin
        basla_r <= 1'b0;
        if (rst_c) begin
            kd <= K_ISIT; isit <= 9'd0;
        end else begin
            case (kd)
                K_ISIT: begin                     // flasa CS yuksekken birkac saat darbesi ver (STARTUPE2 ilk darbeleri yutar), sonra basla
                    isit <= isit + 9'd1;
                    if (isit == 9'd511) begin
                        sent <= sw_s; adres_r <= ofs_sec; basla_r <= 1'b1; kd <= K_OKU;
                    end
                end
                K_OKU:   if (q_bitti) kd <= K_BITTI;
                default: ;
            endcase
        end
    end

    qspi_okuyucu #(.BOL(BOL)) u_qspi (
        .clk(clk), .rst(rst_c), .basla(basla_r), .adres(adres_r), .bayt_sayisi(CUMLE_BAYT),
        .sck(q_sck), .cs_n(q_cs_n), .io0_o(q_io0), .io_oe(q_oe), .io_i(flas_io_i),
        .bayt_gecerli(bayt_gecerli), .bayt_veri(bayt_veri), .bayt_hazir(bayt_hazir), .mesgul(q_mesgul), .bitti(q_bitti));

    assign flas_sck   = (kd == K_ISIT) ? isit[3] : q_sck;
    assign flas_cs_n  = q_cs_n;
    assign flas_io0_o = q_io0;
    assign flas_io_oe = q_oe;

    // ---------------- hizlandirici ----------------
    wire        hata, sinif, sonuc_gecerli, cumle_bitti, tasma_hatasi, skor_tasma, ln_tasma, bellek_catisma;
    wire [3:0]  satir_no, katman_no;
    wire signed [7:0] logit0, logit1;
    wire [31:0] hata_sayisi, kabul_edilen_bayt, kirpilan_sayisi;
    wire [6:0]  cuml_uz;                       // akistan okunan cumle uzunlugu (sozcuk sayisi)

    ortak_ust #(.KATMAN_ISLEM(2), .SINIFLANDIR(1)) u_ust (
        .clk(clk), .rst(rst_c), .bayt_gecerli(bayt_gecerli), .bayt_veri(bayt_veri), .bayt_hazir(bayt_hazir),
        .gozlem(1'b0), .devam(1'b0), .satir_bitti(), .oku_adres(13'd0), .oku_veri(),
        .hata(hata), .satir_no(satir_no), .katman_no(katman_no), .cumle_no(), .cumle_bitti(cumle_bitti),
        .sinif(sinif), .sonuc_gecerli(sonuc_gecerli), .logit0(logit0), .logit1(logit1),
        .hata_sayisi(hata_sayisi), .kabul_edilen_bayt(kabul_edilen_bayt), .cumle_uzunluk(cuml_uz),
        .tasma_hatasi(tasma_hatasi), .skor_tasma(skor_tasma), .ln_tasma(ln_tasma), .bellek_catisma(bellek_catisma),
        .kirpilan_sayisi(kirpilan_sayisi));

    // ---------------- sonuc kaydi, sure olcumu, hata bayraklari ----------------
    reg               bitti;
    reg               sinif_k;
    reg signed [7:0]  l0, l1;
    reg               kosuyor;
    reg [13:0]        sure_alt, sure_100us;       // 0,1 ms birimiyle sure (100 MHz'de 10000 cevrim = 0,1 ms)
    reg               hata_k, tasma_k;
    initial begin bitti = 0; sinif_k = 0; l0 = 0; l1 = 0; kosuyor = 0; sure_alt = 0; sure_100us = 0; hata_k = 0; tasma_k = 0; end
    always @(posedge clk) begin
        if (rst_c) begin
            bitti <= 1'b0; kosuyor <= 1'b0; sure_alt <= 14'd0; sure_100us <= 14'd0; hata_k <= 1'b0; tasma_k <= 1'b0;
            l0 <= 8'sd0; l1 <= 8'sd0; sinif_k <= 1'b0;
        end else begin
            if (basla_r) kosuyor <= 1'b1;
            if (kosuyor) begin
                if (sure_alt == 14'd9999) begin
                    sure_alt <= 14'd0;
                    if (sure_100us != 14'd9999) sure_100us <= sure_100us + 14'd1;
                end else sure_alt <= sure_alt + 14'd1;
            end
            if (sonuc_gecerli) begin
                bitti <= 1'b1; kosuyor <= 1'b0; sinif_k <= sinif; l0 <= logit0; l1 <= logit1;
            end
            if (hata)  hata_k  <= 1'b1;
            if (tasma_hatasi | skor_tasma | ln_tasma | bellek_catisma) tasma_k <= 1'b1;
            if (hata) kosuyor <= 1'b0;
        end
    end

    // altin modelin bu cumleler icin verdigi puanlar (cumle 0..3)
    reg signed [7:0] e0, e1;
    always @* begin
        case (sent)
            2'd0: begin e0 = -8'sd65; e1 = 8'sd73;   end
            2'd1: begin e0 = 8'sd95;  e1 = -8'sd108; end
            2'd2: begin e0 = 8'sd101; e1 = -8'sd112; end
            default: begin e0 = 8'sd18; e1 = -8'sd33; end
        endcase
    end
    wire esles = bitti && (l0 == e0) && (l1 == e1);

    // ---------------- LED ----------------
    reg [26:0] canli = 27'd0;
    always @(posedge clk) canli <= canli + 27'd1;
    assign led = {canli[26], (kd == K_BITTI), sent, esles, bitti & ~sinif_k, bitti & sinif_k, bitti, tasma_k, hata_k, q_mesgul, katman_no[0], satir_no};

    // ---------------- dort basamakli gosterge ----------------
    wire [1:0]  mod = sw[15:14];
    wire [13:0] kb  = (kabul_edilen_bayt[23:10] > 14'd9999) ? 14'd9999 : kabul_edilen_bayt[23:10];
    wire signed [7:0] sec_puan = (mod == 2'd0) ? l0 : l1;
    wire        neg   = sec_puan[7];
    wire [7:0]  mutlak = neg ? (~sec_puan + 8'd1) : sec_puan;
    wire        tani = sw[13];                 // tani modu: sw13 yukari
    reg  [13:0] deger;
    always @* begin
        if (tani) begin
            case (mod)
                2'd0:    deger = {7'd0, cuml_uz};                                  // akistan okunan cumle uzunlugu (cumle 0..3 icin 4, 4, 5, 6)
                2'd1:    deger = (hata_sayisi > 32'd9999) ? 14'd9999 : hata_sayisi[13:0];   // akis denetim hatasi sayisi
                2'd2:    deger = 14'd0;
                default: deger = katman_no[0] ? (14'd100 + satir_no) : {10'd0, satir_no};   // katman*100 + satir
            endcase
        end else begin
            case (mod)
                2'd0, 2'd1: deger = {6'd0, mutlak};
                2'd2:       deger = sure_100us;
                default:    deger = kb;
            endcase
        end
    end
    wire [15:0] bcd;
    ikili_bcd u_bcd (.clk(clk), .ikili(deger), .bcd(bcd));

    // karakter kodlari: 0-9 rakam, 10 '-', 11 bos, 12 'E', 13 'r'
    reg [24:0] gor_say = 25'd0;               // yeniden baslatmadan sonra ~0,33 s tire: baslatma goze gorunsun
    always @(posedge clk) if (rst_c) gor_say <= 25'd0; else if (!gor_say[24]) gor_say <= gor_say + 25'd1;
    reg [15:0] kod;
    reg        sayi_goster;
    always @* begin
        sayi_goster = 1'b0;
        if (tani) begin
            sayi_goster = 1'b1;
            if (mod == 2'd2) kod = {2'b00, sent, 2'b00, sw_s, 4'd11, 4'd11};   // "ab  ": a = okunan cumle, b = anahtarlarin gordugu deger
            else kod = bcd;
        end
        else if (hata_k) kod = {4'd12, 4'd13, 4'd13, 4'd11};
        else if ((!bitti || !gor_say[24]) && mod != 2'd3) kod = {4'd10, 4'd10, 4'd10, 4'd10};
        else begin
            sayi_goster = 1'b1;
            if (mod == 2'd0 || mod == 2'd1) kod = {neg ? 4'd10 : 4'd11, bcd[11:0]};
            else kod = bcd;
        end
    end

    reg [15:0] yenile = 16'd0;
    always @(posedge clk) yenile <= yenile + 16'd1;
    wire [1:0] sec = yenile[15:14];
    reg  [3:0] kk;
    always @* begin
        case (sec)
            2'd0: kk = kod[3:0];
            2'd1: kk = kod[7:4];
            2'd2: kk = kod[11:8];
            default: kk = kod[15:12];
        endcase
    end
    reg [6:0] sg;
    always @* begin
        case (kk)
            4'd0:  sg = 7'b1000000;
            4'd1:  sg = 7'b1111001;
            4'd2:  sg = 7'b0100100;
            4'd3:  sg = 7'b0110000;
            4'd4:  sg = 7'b0011001;
            4'd5:  sg = 7'b0010010;
            4'd6:  sg = 7'b0000010;
            4'd7:  sg = 7'b1111000;
            4'd8:  sg = 7'b0000000;
            4'd9:  sg = 7'b0010000;
            4'd10: sg = 7'b0111111;       // '-'
            4'd12: sg = 7'b0000110;       // 'E'
            4'd13: sg = 7'b0101111;       // 'r'
            default: sg = 7'b1111111;     // bos
        endcase
    end
    assign seg = sg;
    assign an  = ~(4'b0001 << sec);
    assign dp  = ~(sayi_goster && !tani && mod == 2'd2 && sec == 2'd1);   // sure: "067.0" -> onda bir ms
endmodule
