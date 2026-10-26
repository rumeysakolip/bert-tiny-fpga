// -----------------------------------------------------------------------------
// pe.v  --  İşlem hücresi (Processing Element), INT8 x INT8 -> INT32 MAC
// BIL 401 bitirme tasarımı: FPGA tabanlı BERT-Tiny INT8 hızlandırıcısı (G12)
//
// Mimari tercih: ÇIKIŞ-SABİT (output-stationary)
//   * Toplam (acc) PE'nin İÇİNDE kalır; hücreler arasında yalnızca 8 bitlik
//     işlenenler (a: soldan sağa, b: yukarıdan aşağı) akar.
//   * Neden çıkış-sabit?
//     1) Kısmi toplam 32 bit, işlenen 8 bit. Ağırlık-sabit (weight-stationary)
//        mimaride her çevrimde 32 bitlik kısmi toplam komşu hücreye taşınır:
//        4 kat fazla bağlantı/yazmaç. Burada yalnızca 8 bit hareket eder.
//     2) Her çıkış elemanı C[i][j] tam olarak bir PE'de birikir; sonuç ek bir
//        toplama/okuma ağı olmadan doğrudan acc'den okunur.
//     3) Ağırlık yükleme fazı yoktur; A ve B birlikte akar. BERT-Tiny'de
//        iç boyut K uzun (128/512): uzun birikim yerinde yapılır.
//     4) INT32 birikim taşmaz: |a*b| <= 128*128 = 2^14, K=512 için <= 2^23.
//   * Bedel: her çevrimde iki işlenen de akar (veri yeniden kullanımı için
//     her iki giriş de beslenmeli); bu çalışmada kabul edilebilir.
//
// Davranış (hepsi yükselen kenarda, senkron):
//   rst=1 : acc, a_out, b_out sıfırlanır (en'den önceliklidir)
//   en=1  : acc <= acc + a_in*b_in ; a_out <= a_in ; b_out <= b_in
//   en=0  : her şey tutulur (duraklatma)
// Tüm sayılar işaretli (iki'ye tümleyen).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module pe_eski (
    input  wire                clk,
    input  wire                rst,     // senkron reset, aktif-yüksek
    input  wire                en,      // enable
    input  wire signed [7:0]   a_in,    // soldan gelen işlenen (A elemanı)
    input  wire signed [7:0]   b_in,    // yukarıdan gelen işlenen (B elemanı)
    output reg  signed [7:0]   a_out,   // sağdaki komşuya (1 çevrim gecikmeli)
    output reg  signed [7:0]   b_out,   // alttaki komşuya (1 çevrim gecikmeli)
    output reg  signed [31:0]  acc      // birikmiş sonuç (C elemanı)
);

    // 8x8 işaretli çarpım en fazla (-128)*(-128)=16384 -> 16 bit yeter.
    wire signed [15:0] prod = a_in * b_in;

    always @(posedge clk) begin
        if (rst) begin
            a_out <= 8'sd0;
            b_out <= 8'sd0;
            acc   <= 32'sd0;
        end else if (en) begin
            a_out <= a_in;
            b_out <= b_in;
            acc   <= acc + prod;   // prod işaret genişletilerek eklenir
        end
    end

endmodule
