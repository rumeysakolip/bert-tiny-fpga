// -----------------------------------------------------------------------------
// ters_bolucu.v -- isaretsiz bolme: satir basina BIR kez ters deger, eleman basina carpma + tek duzeltme (Konu 4a)
//
// Bir satirdaki tum elemanlar ayni boleni kullanir (Softmax: toplam, LayerNorm: standart sapma).
//   1) ters_baslat: R = floor(2^NW / bolen)  -- mevcut ardisik bolucu ile, NW+1 cevrim, satir basina bir kez
//   2) her eleman (cevrim basina bir tane, boru hatli):
//        q0 = (n * R) >> NW                  taslak bolum  (q0 = q ya da q-1; asagida kanit)
//        r  = n - q0 * bolen                 kalan  (0 <= r < 2*bolen)
//        q  = q0 + (r >= bolen)              tam bolum;  kalan_var = (r mod bolen) != 0
//   Kanit: R = 2^NW/bolen - d, 0 <= d < 1  =>  n*R/2^NW = n/bolen - n*d/2^NW  ve n < 2^NW ise fark < 1.
//          n*R/2^NW <= n/bolen oldugundan q0 <= q; fark < 1 oldugundan q0 >= q-1. Tek duzeltme yeter, yaklasik sonuc yoktur.
// Genislik varsayimlari: n < 2^NW, 1 <= bolen < 2^DW. Bolum QB bite sigmazsa q = 2^QB - 1'e doyar ve tasma=1 olur
// (eski seri bolucu ile kullanan Softmax'ta zaten min(q,255) vardi; LayerNorm'de bolum bu genislikte kalir).
// Carpmalar giriste ve cikista yazmaclidir (DSP48E1 icin M/P yazmaci); gecikme = LAT cevrim (pay_gecerli'den bolum_gecerli'e).
// yan_bilgi_giris: elemanla birlikte ayni gecikmeyle tasinan yan bilgi (indeks, isaret, son bayragi vb.).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module ters_bolucu #(
    parameter PAY_GENISLIGI = 24,
    parameter BOLEN_GENISLIGI = 22,
    parameter BOLUM_GENISLIGI = 8,
    parameter YAN_GENISLIGI = 1
) (
    input  wire              clk,
    input  wire              rst,
    input  wire              ters_baslat,
    input  wire [BOLEN_GENISLIGI-1:0]     bolen,
    output reg               ters_hazir,
    input  wire              pay_gecerli,
    input  wire [PAY_GENISLIGI-1:0]     pay_veri,
    input  wire [YAN_GENISLIGI-1:0]     yan_bilgi_giris,
    output reg               bolum_gecerli,
    output reg  [BOLUM_GENISLIGI-1:0]     bolum,
    output reg               kalan_var,
    output reg               tasma,
    output reg  [YAN_GENISLIGI-1:0]     yan_bilgi_cikis
);
    localparam GECIKME = 7;
    localparam TERS_GENISLIGI  = PAY_GENISLIGI + 1;
    localparam CARPIM_GENISLIGI  = PAY_GENISLIGI + TERS_GENISLIGI;               // n * R genisligi
    localparam [BOLUM_GENISLIGI-1:0] BOLUM_EN_BUYUK = {BOLUM_GENISLIGI{1'b1}};                                  // 2^QB - 1
    localparam KALAN_GENISLIGI = ((BOLUM_GENISLIGI + BOLEN_GENISLIGI > PAY_GENISLIGI) ? (BOLUM_GENISLIGI + BOLEN_GENISLIGI) : PAY_GENISLIGI) + 2;                  // kalan genisligi (isaretli)

    // ---- ters deger: R = floor(2^NW / bolen) ----
    reg  [BOLEN_GENISLIGI-1:0] bolen_kayit;
    reg           seri_baslat;
    wire          seri_mesgul, seri_bitti;
    wire [TERS_GENISLIGI-1:0] seri_bolum, seri_kalan;
    seri_bolucu #(.GENISLIK(TERS_GENISLIGI)) u_ters_bolucu (.clk(clk), .rst(rst), .baslat(seri_baslat),
                                .bolunen({1'b1, {PAY_GENISLIGI{1'b0}}}), .bolen({{(TERS_GENISLIGI-BOLEN_GENISLIGI){1'b0}}, bolen_kayit}),
                                .mesgul(seri_mesgul), .bitti(seri_bitti), .bolum(seri_bolum), .kalan(seri_kalan));
    reg  [TERS_GENISLIGI-1:0] ters_deger;
    always @(posedge clk) begin
        if (rst) begin bolen_kayit <= {{(BOLEN_GENISLIGI-1){1'b0}}, 1'b1}; seri_baslat <= 1'b0; ters_hazir <= 1'b0; ters_deger <= {TERS_GENISLIGI{1'b0}}; end
        else begin
            seri_baslat <= 1'b0;
            if (ters_baslat) begin bolen_kayit <= bolen; ters_hazir <= 1'b0; seri_baslat <= 1'b1; end
            if (seri_bitti) begin ters_deger <= seri_bolum; ters_hazir <= 1'b1; end
        end
    end

    // ---- eleman boru hatti (cevrim basina bir eleman) ----
    reg [YAN_GENISLIGI-1:0]    yan0, yan1, yan2, yan3, yan4, yan5;
    reg             gecerli0, gecerli1, gecerli2, gecerli3, gecerli4, gecerli5;
    reg [PAY_GENISLIGI-1:0]    pay0, pay1, pay2, pay3, pay4;
    (* use_dsp = "yes" *) reg [CARPIM_GENISLIGI-1:0] pay_carpim1;      // pay0 * R
    reg [CARPIM_GENISLIGI-1:0]    pay_carpim2;
    reg [BOLUM_GENISLIGI-1:0]    taslak_bolum3, taslak_bolum4;
    reg             doygun3, doygun4;
    (* use_dsp = "yes" *) reg [BOLUM_GENISLIGI+BOLEN_GENISLIGI-1:0] taslak_carpim4;   // q0 * bolen
    reg signed [KALAN_GENISLIGI-1:0] kalan5;
    reg [BOLUM_GENISLIGI-1:0]    taslak_bolum5;
    reg             doygun5;

    wire [CARPIM_GENISLIGI-PAY_GENISLIGI-1:0] taslak_bolum_tam = pay_carpim2[CARPIM_GENISLIGI-1:PAY_GENISLIGI];       // (n*R) >> NW
    wire             taslak_tasar = (taslak_bolum_tam > BOLUM_EN_BUYUK);
    wire [KALAN_GENISLIGI-1:0]   taslak_carpim_genis = {{(KALAN_GENISLIGI-BOLUM_GENISLIGI-BOLEN_GENISLIGI){1'b0}}, taslak_carpim4};
    wire signed [KALAN_GENISLIGI-1:0] kalan_yeni = $signed({{(KALAN_GENISLIGI-PAY_GENISLIGI){1'b0}}, pay4}) - $signed(taslak_carpim_genis);
    wire [KALAN_GENISLIGI-1:0]   bolen_genis = {{(KALAN_GENISLIGI-BOLEN_GENISLIGI){1'b0}}, bolen_kayit};
    wire             duzeltme_gerekli = (kalan5 >= $signed(bolen_genis));
    wire signed [KALAN_GENISLIGI-1:0] kalan_duzeltilmis = duzeltme_gerekli ? (kalan5 - $signed(bolen_genis)) : kalan5;

    always @(posedge clk) begin
        if (rst) begin
            gecerli0 <= 1'b0; gecerli1 <= 1'b0; gecerli2 <= 1'b0; gecerli3 <= 1'b0; gecerli4 <= 1'b0; gecerli5 <= 1'b0; bolum_gecerli <= 1'b0;
            bolum <= {BOLUM_GENISLIGI{1'b0}}; kalan_var <= 1'b0; tasma <= 1'b0; yan_bilgi_cikis <= {YAN_GENISLIGI{1'b0}};
        end else begin
            // giris yazmaci
            gecerli0 <= pay_gecerli; pay0 <= pay_veri; yan0 <= yan_bilgi_giris;
            // carpma (M ve P yazmaclari)
            gecerli1 <= gecerli0; pay1 <= pay0; yan1 <= yan0; pay_carpim1 <= pay0 * ters_deger;
            gecerli2 <= gecerli1; pay2 <= pay1; yan2 <= yan1; pay_carpim2 <= pay_carpim1;
            // taslak bolum (QB bite kirpilir; tasma doygun3 ile ayrica isaretlenir)
            gecerli3 <= gecerli2; pay3 <= pay2; yan3 <= yan2; taslak_bolum3 <= taslak_bolum_tam[BOLUM_GENISLIGI-1:0]; doygun3 <= taslak_tasar;                  // tasarsa q0 kullanilmaz: sat bayragi cikisi doyurur
            // q0 * bolen
            gecerli4 <= gecerli3; pay4 <= pay3; yan4 <= yan3; taslak_bolum4 <= taslak_bolum3; doygun4 <= doygun3; taslak_carpim4 <= taslak_bolum3 * bolen_kayit;
            // kalan
            gecerli5 <= gecerli4; yan5 <= yan4; taslak_bolum5 <= taslak_bolum4; doygun5 <= doygun4; kalan5 <= kalan_yeni;
            // duzeltme ve cikis
            bolum_gecerli   <= gecerli5;
            yan_bilgi_cikis <= yan5;
            if (doygun5) begin bolum <= BOLUM_EN_BUYUK; kalan_var <= 1'b1; tasma <= 1'b1; end
            else if (duzeltme_gerekli && taslak_bolum5 == BOLUM_EN_BUYUK) begin bolum <= BOLUM_EN_BUYUK; kalan_var <= 1'b1; tasma <= 1'b1; end
            else begin bolum <= taslak_bolum5; kalan_var <= (kalan_duzeltilmis != 0); tasma <= 1'b0; end
        end
    end
endmodule
