// -----------------------------------------------------------------------------
// systolic_4x4.v -- 4x4 çıkış-sabit sistolik dizi, tek 4x4 matris çarpımı (G13)
//   C = A * B ;  A, B: 4x4 INT8 (işaretli), C: 4x4 INT32
//
// Düzenek: 16 adet pe (pe.v). A satırları soldan, B sütunları yukarıdan akar.
//   PE(i,j) acc'sinde C[i][j] = sum_k A[i][k]*B[k][j] birikir (çıkış-sabit).
//
// Skew (kaydırmalı besleme): PE(i,j), A[i][k] ve B[k][j] değerlerini AYNI
//   çevrimde görmeli. Her PE geçişi 1 çevrim gecikme eklediği için:
//     - A satırı i, i çevrim geç başlar  : çevrim t'de A[i][t-i]  (0<=t-i<4)
//     - B sütunu j, j çevrim geç başlar  : çevrim t'de B[t-j][j]  (0<=t-j<4)
//   Pencere dışında 0 beslenir (0*x = 0, birikimi bozmaz).
//   O zaman PE(i,j) girişinde çevrim t'de k = t-i-j olur; ikisi de aynı k'yi görür.
//   Skew, giriş yazmaçlarından sayaçla seçim yapılarak üretilir (gecikme
//   yazmacı zinciri yok).
//
// Zamanlama (start örneklenen kenar = kenar 0):
//   kenar 0        : A,B yakalanır, PE'ler sıfırlanır, durum RUN, cnt=0
//   kenar 1..10    : cnt=0..9 ; PE(3,3) son veriyi cnt=9'da (k=3) alır
//   kenar 10 sonrası: done=1, c_flat geçerli.  => start'tan done'a 11 çevrim
//   (10 hesap çevrimi = 3*N-2, N=4)
//
// Arayüz (düzleştirilmiş, satır-öncelikli):
//   a_flat[(i*4+k)*8  +: 8 ] = A[i][k]
//   b_flat[(k*4+j)*8  +: 8 ] = B[k][j]
//   c_flat[(i*4+j)*32 +: 32] = C[i][j]
//   start: 1 çevrim darbe (busy iken yok sayılır). A,B start kenarında
//   yakalanır; sonrasında değişmeleri sonucu etkilemez.
//   done : hesap bitince 1 olur, yeni start veya rst'ye kadar 1 kalır.
// Sabit 4x4 (genelleştirme kapsam dışı).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module systolic_4x4 (
    input  wire              clk,
    input  wire              rst,      // senkron reset, aktif-yüksek
    input  wire              start,
    input  wire [127:0]      a_flat,
    input  wire [127:0]      b_flat,
    output wire [511:0]      c_flat,
    output wire              busy,
    output reg               done
);
    localparam N        = 4;
    localparam S_IDLE   = 2'd0;
    localparam S_RUN    = 2'd1;
    localparam S_DONE   = 2'd2;
    localparam LAST_CNT = 4'd9;        // 3*(N-1) = 9 -> cnt: 0..9 (10 çevrim)

    reg [1:0]   state;
    reg [3:0]   cnt;
    reg [127:0] a_reg, b_reg;          // start'ta yakalanan girişler

    wire start_ok = start && (state != S_RUN);
    wire run      = (state == S_RUN);
    assign busy   = run;

    // ---- kontrol FSM'i ----
    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
            cnt   <= 4'd0;
            done  <= 1'b0;
            a_reg <= 128'd0;
            b_reg <= 128'd0;
        end else begin
            if (start_ok) begin
                a_reg <= a_flat;
                b_reg <= b_flat;
                cnt   <= 4'd0;
                done  <= 1'b0;
                state <= S_RUN;
            end else if (run) begin
                if (cnt == LAST_CNT) begin
                    state <= S_DONE;
                    done  <= 1'b1;
                end else begin
                    cnt <= cnt + 4'd1;
                end
            end
        end
    end

    // PE'ler: genel reset veya kabul edilen start'ta sıfırlanır; yalnızca RUN'da çalışır
    wire pe_rst = rst | start_ok;

    // ---- skew'li besleme ----
    // a_feed[i*8 +: 8] : satır i'nin sol girişi ; b_feed[j*8 +: 8] : sütun j'nin üst girişi
    wire [8*N-1:0] a_feed, b_feed;

    genvar gi, gj;
    generate
        for (gi = 0; gi < N; gi = gi + 1) begin : g_feed_a
            wire       in_win = (cnt >= gi) && (cnt < gi + N);
            wire [1:0] k      = cnt - gi;                  // pencere içinde 0..3
            assign a_feed[gi*8 +: 8] = (run && in_win) ? a_reg[(gi*N + k)*8 +: 8] : 8'd0;
        end
        for (gj = 0; gj < N; gj = gj + 1) begin : g_feed_b
            wire       in_win = (cnt >= gj) && (cnt < gj + N);
            wire [1:0] k      = cnt - gj;
            assign b_feed[gj*8 +: 8] = (run && in_win) ? b_reg[(k*N + gj)*8 +: 8] : 8'd0;
        end
    endgenerate

    // ---- 4x4 PE ızgarası ----
    wire [8*N*N-1:0]  a_o;    // PE(i,j) a_out  -> indeks i*N+j
    wire [8*N*N-1:0]  b_o;    // PE(i,j) b_out
    wire [32*N*N-1:0] acc_o;
    assign c_flat = acc_o;

    generate
        for (gi = 0; gi < N; gi = gi + 1) begin : g_row
            for (gj = 0; gj < N; gj = gj + 1) begin : g_col
                wire signed [7:0] a_in;
                wire signed [7:0] b_in;

                if (gj == 0) begin : g_a_edge
                    assign a_in = a_feed[gi*8 +: 8];
                end else begin : g_a_int
                    assign a_in = a_o[(gi*N + gj - 1)*8 +: 8];   // soldaki PE
                end

                if (gi == 0) begin : g_b_edge
                    assign b_in = b_feed[gj*8 +: 8];
                end else begin : g_b_int
                    assign b_in = b_o[((gi-1)*N + gj)*8 +: 8];   // üstteki PE
                end

                pe u_pe (
                    .clk  (clk),
                    .rst  (pe_rst),
                    .en   (run),
                    .a_in (a_in),
                    .b_in (b_in),
                    .a_out(a_o[(gi*N + gj)*8 +: 8]),
                    .b_out(b_o[(gi*N + gj)*8 +: 8]),
                    .acc  (acc_o[(gi*N + gj)*32 +: 32])
                );
            end
        end
    endgenerate

endmodule
