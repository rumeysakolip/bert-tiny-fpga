// -----------------------------------------------------------------------------
// layernorm_birim.v -- tamsayi LayerNorm: INT (Q_W bit) satir -> INT8 (G11)
// Altin model: dogrusal_olmayan.katman_norm_tam (g_bit = 12, N = 2^LOGN)
//   ort = (sum + N/2) >>> LOGN ; d = q - ort ; var = (sum(d^2) + N/2) >> LOGN
//   std = max(isqrt(var + eps_q), 1)            (isqrt: bit-bit karekok, floor; Newton ile ayni sonuc)
//   y   = floor((d*2^12 + std/2) / std)          (satir basina bir kez R = floor(2^31/std), eleman basina carpma + tek duzeltme:
//                                                  bolucu_ters.v, Konu 4a; bolum 17 bite sigar, sigmazsa doyar)
//   cikis = clip8( ((y*gamma_q[i]) * M0 + 2^(n-1)) >>> n + beta_q[i] )
// Akis: start -> N giris (in_valid) -> hesap -> N cikis (out_valid, out_last).
// Genislik varsayimlari (g11_vektor_uret.py istatistik.json ile denetlenir):
//   |q| < 2^(Q_W-1); |y| <= sqrt(N)*2^12 ~ 46341 (17 bit isaretli); gamma_q 16 bit isaretli; M0 <= 2^31-1.
// gamma_q / beta_q tablolari par_we ile yuklenir (host, kat basina bir kez).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module layernorm_birim #(
    parameter N    = 128,
    parameter LOGN = 7,
    parameter Q_W  = 18,
    parameter G    = 12
) (
    input  wire                 clk,
    input  wire                 rst,
    // parametreler
    input  wire                 par_we,
    input  wire [LOGN-1:0]      par_adr,
    input  wire signed [GWID-1:0] par_gamma,
    input  wire signed [15:0]   par_beta,
    input  wire [39:0]          eps_q,
    input  wire [30:0]          m0,
    input  wire [5:0]           nsh,
    // komut / veri
    input  wire                 start,
    output wire                 in_ready,
    input  wire                 in_valid,
    input  wire signed [Q_W-1:0] in_data,
    output reg                  out_valid,
    output reg signed [7:0]     out_data,
    output reg                  out_last,
    output wire                 busy
);
    // G'ye bagli genislikler (G=12'de eski sabitlerle ayni: YB=17, GWID=16, P1W=33, P2W=66)
    localparam YB   = G + 5;                // y = d/std * 2^G genisligi (isaretli)
    localparam GWID = G + 4;                // gamma_q = gamma * 2^G genisligi (isaretli)
    localparam P1W  = YB + GWID;
    localparam P2W  = P1W + 33;
    localparam SUM_W = Q_W + LOGN;
    localparam D_W   = Q_W + 1;
    localparam SS_W  = 2*D_W + LOGN;        // 2*19+7 = 45
    localparam VAR_W = 40;
    localparam RW    = VAR_W/2;             // karekok bit sayisi

    // S_NUM: ters deger baslat, S_DIV: ters degeri bekle, S_Y: elemanlari boru hattina besle, S_M1: son cikisi bekle (eski durum
    // numaralari 4 bitte kalsin diye yeniden kullanildi; S_M2, S_SH, S_OUT artik yok: carpma/kaydirma/cikis boru hatti asamalaridir)
    localparam S_IDLE = 4'd0, S_LOAD = 4'd1, S_MEAN = 4'd2, S_SQ = 4'd3, S_VAR = 4'd4, S_ROOT = 4'd5,
               S_STD = 4'd6, S_NUM = 4'd7, S_DIV = 4'd8, S_Y = 4'd9, S_M1 = 4'd10;

    reg [3:0] st;
    reg [LOGN:0] cnt;
    reg signed [Q_W-1:0] buf_q [0:N-1];
    reg signed [GWID-1:0] gam [0:N-1];
    reg signed [GWID-1:0] bet [0:N-1];
    reg signed [SUM_W-1:0] sum;
    reg signed [D_W-1:0]   mean;
    reg [SS_W-1:0]         ss;
    reg [VAR_W-1:0]        op, res, one;
    reg [RW:0]             rcnt;
    reg [31:0]             std;
    reg [39:0]             eps_r;
    reg [30:0]             m0_r;
    reg [5:0]              n_r;

    // bolucu (satir basina ters deger + eleman basina carpma/duzeltme)
    wire        ters_basla = (st == S_NUM);
    wire        ters_hazir, q_valid, q_kalan, q_tasma;
    wire [YB-1:0] q_dat;
    wire [LOGN+1:0] yan_c;                                 // {isaret, son, indeks}
    wire [D_W+G-1:0] num_gir;
    // elemanin ters-bolme sonrasi boru hatti: y -> y*gamma -> *M0 -> yuvarla/kaydir -> +beta, kirp
    reg                  y_v, p1_v, p2_v, ps_v;
    reg                  y_l, p1_l, p2_l, ps_l;
    reg [LOGN-1:0]       y_i, p1_i, p2_i, ps_i;
    reg signed [YB-1:0]  y;
    reg signed [P1W-1:0] p1;
    reg signed [P2W-1:0] p2;
    reg signed [P2W-1:0] p2s;
    reg signed [D_W-1:0] d_r;
    reg signed [2*D_W-1:0] dsq_r;
    reg dv1, dv2;
    wire [LOGN-1:0] yan_ix   = yan_c[LOGN-1:0];
    wire            yan_son  = yan_c[LOGN];
    wire            yan_neg  = yan_c[LOGN+1];

    assign in_ready = (st == S_LOAD);
    assign busy     = (st != S_IDLE);

    always @(posedge clk) if (par_we) begin gam[par_adr] <= par_gamma; bet[par_adr] <= par_beta; end

    wire [LOGN-1:0] ix = cnt[LOGN-1:0];
    wire signed [Q_W-1:0] qb = buf_q[ix];
    wire signed [D_W-1:0] d_cur = qb - mean;
    wire signed [2*D_W-1:0] dsq = d_cur * d_cur;
    wire signed [D_W+G:0] d_sh  = d_cur <<< G;                                         // d << 12
    wire signed [D_W+G:0] num_s = d_sh + $signed({1'b0, std[31:1]});
    wire [D_W+G:0] num_abs = num_s[D_W+G] ? (~num_s + 1'b1) : num_s;
    assign num_gir = num_abs[D_W+G-1:0];                                                  // |num| < 2^31 (|d| < 2^18 => |d<<12| + std/2 < 2^31)
    bolucu_ters #(.NW(D_W+G), .DW(20), .QB(YB), .YW(LOGN + 2)) u_dv (.clk(clk), .rst(rst), .ters_basla(ters_basla), .bolen(std[19:0]),
        .ters_hazir(ters_hazir), .n_valid(st == S_Y), .n_data(num_gir), .yan_giris({num_s[D_W+G], cnt == N-1, ix}),
        .q_valid(q_valid), .q(q_dat), .kalan_var(q_kalan), .tasma(q_tasma), .yan_cikis(yan_c));


    wire [VAR_W-1:0] t_sum = res + one;
    wire signed [P2W-1:0] rnd = (n_r == 6'd0) ? {P2W{1'b0}} : ({{(P2W-1){1'b0}}, 1'b1} <<< (n_r - 6'd1));
    wire signed [P2W-1:0] p2r = (p2 + rnd) >>> n_r;
    wire signed [GWID-1:0] bt = bet[ps_i];
    wire signed [P2W:0] cikis_w = p2s + bt;

    always @(posedge clk) begin
        if (rst) begin
            st <= S_IDLE; cnt <= 0; out_valid <= 1'b0; out_data <= 8'sd0; out_last <= 1'b0;
            sum <= 0; mean <= 0; ss <= 0; std <= 32'd1; y <= 0; p1 <= 0; p2 <= 0; p2s <= 0; d_r <= 0; dsq_r <= 0; dv1 <= 1'b0; dv2 <= 1'b0;
            op <= 0; res <= 0; one <= 0; rcnt <= 0; eps_r <= 0; m0_r <= 0; n_r <= 0;
            y_v <= 1'b0; p1_v <= 1'b0; p2_v <= 1'b0; ps_v <= 1'b0; y_l <= 1'b0; p1_l <= 1'b0; p2_l <= 1'b0; ps_l <= 1'b0;
            y_i <= 0; p1_i <= 0; p2_i <= 0; ps_i <= 0;
        end else begin
            // ---- eleman boru hatti (serbest akar; gecerli bayragi ile) ----
            // y: floor(num/std); negatifte -ceil(|num|/std)
            y_v <= q_valid; y_l <= yan_son; y_i <= yan_ix;
            y   <= yan_neg ? -$signed(q_dat + ((q_kalan) ? {{(YB-1){1'b0}}, 1'b1} : {YB{1'b0}})) : $signed(q_dat);
            p1_v <= y_v; p1_l <= y_l; p1_i <= y_i; p1 <= y * gam[y_i];
            p2_v <= p1_v; p2_l <= p1_l; p2_i <= p1_i; p2 <= p1 * $signed({1'b0, m0_r});
            ps_v <= p2_v; ps_l <= p2_l; ps_i <= p2_i; p2s <= p2r;
            out_valid <= ps_v;
            out_last  <= ps_v && ps_l;
            if (ps_v) out_data <= (cikis_w > 127) ? 8'sd127 : (cikis_w < -128) ? -8'sd128 : cikis_w[7:0];
            case (st)
                S_IDLE: if (start) begin
                    eps_r <= eps_q; m0_r <= m0; n_r <= nsh; cnt <= 0; sum <= 0; ss <= 0; st <= S_LOAD;
                end
                S_LOAD: if (in_valid) begin
                    buf_q[ix] <= in_data;
                    sum <= sum + in_data;
                    if (cnt == N-1) begin cnt <= 0; st <= S_MEAN; end else cnt <= cnt + 1;
                end
                S_MEAN: begin
                    mean <= (sum + (1 <<< (LOGN-1))) >>> LOGN;
                    cnt <= 0; ss <= 0; dv1 <= 1'b0; dv2 <= 1'b0; st <= S_SQ;
                end
                S_SQ: begin                                     // 3 asamali boru hatti: d -> d*d -> toplam
                    d_r   <= d_cur;
                    dv1   <= (cnt < N);
                    dsq_r <= d_r * d_r;
                    dv2   <= dv1;
                    if (dv2) ss <= ss + {{(SS_W-2*D_W){1'b0}}, dsq_r};
                    if (cnt == N+1) begin cnt <= 0; st <= S_VAR; end else cnt <= cnt + 1;
                end
                S_VAR: begin
                    op  <= ((ss + (1 << (LOGN-1))) >> LOGN) + eps_r;
                    res <= 0; one <= {2'b01, {(VAR_W-2){1'b0}}}; rcnt <= 0; st <= S_ROOT;
                end
                S_ROOT: begin                                   // bit-bit tamsayi karekok (floor)
                    if (op >= t_sum) begin op <= op - t_sum; res <= (res >> 1) + one; end
                    else res <= res >> 1;
                    one  <= one >> 2;
                    rcnt <= rcnt + 1;
                    if (rcnt == RW-1) begin st <= S_STD; cnt <= 0; end
                end
                S_STD: begin std <= (res == 0) ? 32'd1 : res[31:0]; st <= S_NUM; end
                S_NUM: begin cnt <= 0; st <= S_DIV; end                    // ters_basla bu durumda 1 cevrimlik darbedir
                S_DIV: if (ters_hazir) st <= S_Y;
                S_Y: begin                                                  // her cevrimde bir eleman
                    if (cnt == N-1) st <= S_M1; else cnt <= cnt + 1;
                end
                S_M1: ;                                                    // son cikis gelince asagida IDLE'a donulur
                default: st <= S_IDLE;
            endcase
            if (ps_v && ps_l) st <= S_IDLE;
        end
    end
endmodule
