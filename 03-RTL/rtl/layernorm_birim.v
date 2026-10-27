// -----------------------------------------------------------------------------
// layernorm_birim.v -- tamsayi LayerNorm: INT (Q_W bit) satir -> INT8 (G11)
// Altin model: dogrusal_olmayan.katman_norm_tam (g_bit = 12, N = 2^LOGN)
//   ort = (sum + N/2) >>> LOGN ; d = q - ort ; var = (sum(d^2) + N/2) >> LOGN
//   std = max(isqrt(var + eps_q), 1)            (isqrt: bit-bit karekok, floor; Newton ile ayni sonuc)
//   y   = floor((d*2^12 + std/2) / std)          (ardisik bolucu)
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
    input  wire signed [15:0]   par_gamma,
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
    localparam SUM_W = Q_W + LOGN;
    localparam D_W   = Q_W + 1;
    localparam SS_W  = 2*D_W + LOGN;        // 2*19+7 = 45
    localparam VAR_W = 40;
    localparam RW    = VAR_W/2;             // karekok bit sayisi

    localparam S_IDLE = 4'd0, S_LOAD = 4'd1, S_MEAN = 4'd2, S_SQ = 4'd3, S_VAR = 4'd4, S_ROOT = 4'd5,
               S_STD = 4'd6, S_NUM = 4'd7, S_DIV = 4'd8, S_Y = 4'd9, S_M1 = 4'd10, S_M2 = 4'd11, S_SH = 4'd12, S_OUT = 4'd13;

    reg [3:0] st;
    reg [LOGN:0] cnt;
    reg signed [Q_W-1:0] buf_q [0:N-1];
    reg signed [15:0]    gam [0:N-1];
    reg signed [15:0]    bet [0:N-1];
    reg signed [SUM_W-1:0] sum;
    reg signed [D_W-1:0]   mean;
    reg [SS_W-1:0]         ss;
    reg [VAR_W-1:0]        op, res, one;
    reg [RW:0]             rcnt;
    reg [31:0]             std;
    reg [39:0]             eps_r;
    reg [30:0]             m0_r;
    reg [5:0]              n_r;

    // bolucu
    reg         dv_start;
    reg  [31:0] dv_num;
    wire        dv_busy, dv_done;
    wire [31:0] dv_q, dv_r;
    bolucu_seri #(.W(32)) u_dv (.clk(clk), .rst(rst), .start(dv_start), .num(dv_num), .den(std),
                                .busy(dv_busy), .done(dv_done), .quo(dv_q), .rem(dv_r));

    reg                  num_neg;
    reg signed [16:0]    y;
    reg signed [32:0]    p1;
    reg signed [65:0]    p2;
    reg signed [65:0]    p2s;
    reg signed [D_W-1:0] d_r;
    reg signed [2*D_W-1:0] dsq_r;
    reg dv1, dv2;

    assign in_ready = (st == S_LOAD);
    assign busy     = (st != S_IDLE);

    always @(posedge clk) if (par_we) begin gam[par_adr] <= par_gamma; bet[par_adr] <= par_beta; end

    wire [LOGN-1:0] ix = cnt[LOGN-1:0];
    wire signed [Q_W-1:0] qb = buf_q[ix];
    wire signed [D_W-1:0] d_cur = qb - mean;
    wire signed [2*D_W-1:0] dsq = d_cur * d_cur;
    wire signed [D_W+G:0] d_sh  = d_cur <<< G;                                         // d << 12
    wire signed [D_W+G:0] num_s = d_sh + $signed({1'b0, std[31:1]});
    wire [31:0] num_abs = num_s[D_W+G] ? (~num_s + 32'd1) : num_s;

    wire [VAR_W-1:0] t_sum = res + one;
    wire signed [65:0] rnd = (n_r == 6'd0) ? 66'sd0 : (66'sd1 <<< (n_r - 6'd1));
    wire signed [65:0] p2r = (p2 + rnd) >>> n_r;
    wire signed [15:0] bt = bet[ix];
    wire signed [66:0] cikis_w = p2s + bt;

    always @(posedge clk) begin
        if (rst) begin
            st <= S_IDLE; cnt <= 0; out_valid <= 1'b0; out_data <= 8'sd0; out_last <= 1'b0; dv_start <= 1'b0;
            sum <= 0; mean <= 0; ss <= 0; std <= 32'd1; y <= 0; p1 <= 0; p2 <= 0; p2s <= 0; d_r <= 0; dsq_r <= 0; dv1 <= 1'b0; dv2 <= 1'b0; num_neg <= 1'b0; dv_num <= 0;
            op <= 0; res <= 0; one <= 0; rcnt <= 0; eps_r <= 0; m0_r <= 0; n_r <= 0;
        end else begin
            out_valid <= 1'b0; out_last <= 1'b0; dv_start <= 1'b0;
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
                S_NUM: begin
                    num_neg <= num_s[D_W+G];
                    dv_num <= num_abs; dv_start <= 1'b1; st <= S_DIV;
                end
                S_DIV: if (dv_done) st <= S_Y;
                S_Y: begin
                    // floor(num/std): negatifte -ceil(|num|/std)
                    y  <= num_neg ? -$signed(dv_q[16:0] + ((dv_r != 0) ? 17'd1 : 17'd0)) : $signed(dv_q[16:0]);
                    st <= S_M1;
                end
                S_M1: begin p1 <= y * gam[ix]; st <= S_M2; end
                S_M2: begin p2 <= p1 * $signed({1'b0, m0_r}); st <= S_SH; end
                S_SH: begin p2s <= p2r; st <= S_OUT; end
                S_OUT: begin
                    out_valid <= 1'b1;
                    out_data  <= (cikis_w > 67'sd127) ? 8'sd127 : (cikis_w < -67'sd128) ? -8'sd128 : cikis_w[7:0];
                    out_last  <= (cnt == N-1);
                    if (cnt == N-1) st <= S_IDLE; else begin cnt <= cnt + 1; st <= S_NUM; end
                end
                default: st <= S_IDLE;
            endcase
        end
    end
endmodule
