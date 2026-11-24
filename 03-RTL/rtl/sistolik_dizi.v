// -----------------------------------------------------------------------------
// sistolik_dizi.v -- parametrik NxN cikis-sabit sistolik dizi, AKISLI arayuz (G4)
//   C[N][N] = sum_k A[:,k] * B[k,:]   (tile; K = k_uzunlugu cevrim boyunca akitilir)
//
// Arayuz:
//   start        : 1 cevrim darbe (busy iken yok sayilir). k_uzunlugu ve PE'ler start kenarinda
//                  yakalanir/sifirlanir. Veri start kenarindan SONRAKI cevrimden itibaren verilir.
//   giris_gecerli     : o cevrimde a_sutunu/b_satiri gecerli. Tam k_uzunlugu gecerli cevrim sonra kabul biter.
//                  Gecerli cevrimler arasinda bosluk (durma) olabilir: bosluk her iki akisa
//                  birden sifir sokar, hizalama bozulmaz.
//   a_sutunu        : A[i][k], i=0..N-1  -> [i*A_GENISLIGI +: A_GENISLIGI]   (her cevrimde BIR sutun)
//   b_satiri        : B[k][j], j=0..N-1  -> [j*B_GENISLIGI +: B_GENISLIGI]   (her cevrimde BIR satir)
//   c_matrisi       : C[i][j] -> [(i*N+j)*BIRIKEC_GENISLIGI +: BIRIKEC_GENISLIGI], done=1 iken gecerli
//   busy / done  : done, bir sonraki start'a ya da rst'ye kadar 1 kalir.
//
// Skew: A satiri i, i cevrim; B sutunu j, j cevrim gecikmeli beslenir (kaydirma yazmaci).
//   PE(i,j) girisinde cevrim t'de k = t-i-j gorulur; ikisi de ayni k'yi gorur.
//   Sureler: besleme K cevrim, bosaltma 2N-1 cevrim -> tile = K + 2N - 1 cevrim (Konu 6'dan once K + 2N - 2: kenar PE'lere giris yazmaci +1)
//   (N=4,K=4 -> 11; N=8,K=64 -> 79).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module sistolik_dizi #(
    parameter DIZI_BOYUTU     = 8,
    parameter A_GENISLIGI   = 9,
    parameter B_GENISLIGI   = 8,
    parameter BIRIKEC_GENISLIGI = 32,
    parameter K_GENISLIGI   = 11            // k_uzunlugu genisligi (K <= 2^K_GENISLIGI - 1)
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     baslat,
    input  wire [K_GENISLIGI-1:0]           k_uzunlugu,
    input  wire                     giris_gecerli,
    input  wire [DIZI_BOYUTU*A_GENISLIGI-1:0]         a_sutunu,
    input  wire [DIZI_BOYUTU*B_GENISLIGI-1:0]         b_satiri,
    output wire [DIZI_BOYUTU*DIZI_BOYUTU*BIRIKEC_GENISLIGI-1:0]     c_matrisi,
    output wire                     mesgul,
    output reg                      bitti
);
    localparam DURUM_BOSTA = 2'd0;
    localparam DURUM_CALISIYOR  = 2'd1;
    localparam DURUM_BITTI = 2'd2;
    localparam BOSALTMA_CEVRIMI  = 2*DIZI_BOYUTU - 1;                     // bosaltma cevrimi (Konu 6: kenar PE'lere giris yazmaci eklendi, +1)
    localparam BOSALTMA_SAYAC_GENISLIGI    = 8;                           // dcnt genisligi (2N-2 <= 255)

    reg [1:0]       durum;
    reg [K_GENISLIGI-1:0]   k_uzunlugu_kayit, k_sayaci;
    reg [BOSALTMA_SAYAC_GENISLIGI-1:0]   bosaltma_sayaci;
    reg             son_veri_alindi;                       // k_uzunlugu'inci veri alindi

    wire baslat_kabul = baslat && (durum != DURUM_CALISIYOR);
    wire calisiyor      = (durum == DURUM_CALISIYOR);
    assign mesgul   = calisiyor;
    wire giris_kabul    = calisiyor && giris_gecerli && !son_veri_alindi && (k_sayaci < k_uzunlugu_kayit);
    wire islem_elemani_sifirla   = rst | baslat_kabul;

    // ---- kontrol FSM'i ----
    always @(posedge clk) begin
        if (rst) begin
            durum     <= DURUM_BOSTA;
            k_uzunlugu_kayit     <= {K_GENISLIGI{1'b0}};
            k_sayaci      <= {K_GENISLIGI{1'b0}};
            bosaltma_sayaci      <= {BOSALTMA_SAYAC_GENISLIGI{1'b0}};
            son_veri_alindi <= 1'b0;
            bitti      <= 1'b0;
        end else if (baslat_kabul) begin
            k_uzunlugu_kayit     <= k_uzunlugu;
            k_sayaci      <= {K_GENISLIGI{1'b0}};
            bosaltma_sayaci      <= {BOSALTMA_SAYAC_GENISLIGI{1'b0}};
            son_veri_alindi <= 1'b0;
            bitti      <= 1'b0;
            durum     <= DURUM_CALISIYOR;
        end else if (calisiyor) begin
            if (giris_kabul) begin
                k_sayaci <= k_sayaci + 1'b1;
                if (k_sayaci == k_uzunlugu_kayit - 1'b1) son_veri_alindi <= 1'b1;
            end else if (son_veri_alindi) begin
                if (bosaltma_sayaci == BOSALTMA_CEVRIMI - 1) begin
                    durum <= DURUM_BITTI;
                    bitti  <= 1'b1;
                end else begin
                    bosaltma_sayaci <= bosaltma_sayaci + 1'b1;
                end
            end
        end
    end

    // ---- skew'li besleme (kaydirma yazmaci; gecersiz cevrimde sifir) ----
    wire [DIZI_BOYUTU*A_GENISLIGI-1:0] a_beslenen;
    wire [DIZI_BOYUTU*B_GENISLIGI-1:0] b_beslenen;

    genvar gi, gj;
    generate
        // Her satir/sutun gi+1 asamali kaydirma yazmacindan gecer (eskiden gi asama; satir/sutun 0 dogrudan kombinasyonel idi).
        // Boylece giris_kabul kapisi ile DSP girisi arasinda yazmac vardir (DSP B kurulum suresi 3,7 ns oldugundan kapi+yayilma yolu sinirdaydi).
        // Goreli kayma (skew) ayni kalir; tile suresi 1 cevrim uzar (K + 2N - 1).
        for (gi = 0; gi < DIZI_BOYUTU; gi = gi + 1) begin : g_a_kaydirma
            wire [A_GENISLIGI-1:0] kapili_giris = giris_kabul ? a_sutunu[gi*A_GENISLIGI +: A_GENISLIGI] : {A_GENISLIGI{1'b0}};
            reg [A_GENISLIGI*(gi+1)-1:0] kaydirma_yazmaci;
            always @(posedge clk) begin
                if (islem_elemani_sifirla) kaydirma_yazmaci <= {(A_GENISLIGI*(gi+1)){1'b0}};
                else        kaydirma_yazmaci <= (kaydirma_yazmaci << A_GENISLIGI) | kapili_giris;
            end
            assign a_beslenen[gi*A_GENISLIGI +: A_GENISLIGI] = kaydirma_yazmaci[A_GENISLIGI*gi +: A_GENISLIGI];
        end
        for (gj = 0; gj < DIZI_BOYUTU; gj = gj + 1) begin : g_b_kaydirma
            wire [B_GENISLIGI-1:0] kapili_giris = giris_kabul ? b_satiri[gj*B_GENISLIGI +: B_GENISLIGI] : {B_GENISLIGI{1'b0}};
            reg [B_GENISLIGI*(gj+1)-1:0] kaydirma_yazmaci;
            always @(posedge clk) begin
                if (islem_elemani_sifirla) kaydirma_yazmaci <= {(B_GENISLIGI*(gj+1)){1'b0}};
                else        kaydirma_yazmaci <= (kaydirma_yazmaci << B_GENISLIGI) | kapili_giris;
            end
            assign b_beslenen[gj*B_GENISLIGI +: B_GENISLIGI] = kaydirma_yazmaci[B_GENISLIGI*gj +: B_GENISLIGI];
        end
    endgenerate

    // ---- NxN PE izgarasi ----
    // PE'ler arasi baglantilar net dizisi (paketlenmis genis vektor degil): hem sentez icin
    // esdeger hem de Icarus'ta her degisimde tum dilimlerin yeniden degerlendirilmesini onler.
    wire signed [A_GENISLIGI-1:0]   a_baglanti   [0:DIZI_BOYUTU*DIZI_BOYUTU-1];
    wire signed [B_GENISLIGI-1:0]   b_baglanti   [0:DIZI_BOYUTU*DIZI_BOYUTU-1];
    wire signed [BIRIKEC_GENISLIGI-1:0] birikec_baglanti [0:DIZI_BOYUTU*DIZI_BOYUTU-1];

    generate
        for (gi = 0; gi < DIZI_BOYUTU; gi = gi + 1) begin : g_satir
            for (gj = 0; gj < DIZI_BOYUTU; gj = gj + 1) begin : g_sutun
                wire signed [A_GENISLIGI-1:0] a_giris;
                wire signed [B_GENISLIGI-1:0] b_giris;

                if (gj == 0) begin : g_a_kenar
                    assign a_giris = a_beslenen[gi*A_GENISLIGI +: A_GENISLIGI];
                end else begin : g_a_ic
                    assign a_giris = a_baglanti[gi*DIZI_BOYUTU + gj - 1];            // soldaki PE
                end

                if (gi == 0) begin : g_b_kenar
                    assign b_giris = b_beslenen[gj*B_GENISLIGI +: B_GENISLIGI];
                end else begin : g_b_ic
                    assign b_giris = b_baglanti[(gi-1)*DIZI_BOYUTU + gj];            // ustteki PE
                end

                islem_elemani #(.A_GENISLIGI(A_GENISLIGI), .B_GENISLIGI(B_GENISLIGI), .BIRIKEC_GENISLIGI(BIRIKEC_GENISLIGI)) u_islem_elemani (
                    .clk  (clk),
                    .rst  (islem_elemani_sifirla),
                    .etkin   (calisiyor),
                    .a_giris (a_giris),
                    .b_giris (b_giris),
                    .a_cikis(a_baglanti[gi*DIZI_BOYUTU + gj]),
                    .b_cikis(b_baglanti[gi*DIZI_BOYUTU + gj]),
                    .birikec  (birikec_baglanti[gi*DIZI_BOYUTU + gj])
                );
                assign c_matrisi[(gi*DIZI_BOYUTU + gj)*BIRIKEC_GENISLIGI +: BIRIKEC_GENISLIGI] = birikec_baglanti[gi*DIZI_BOYUTU + gj];
            end
        end
    endgenerate

endmodule
