// -----------------------------------------------------------------------------
// softmax_birim.v -- tamsayi Softmax: L adet INT32 skor (+maske) -> L adet UINT8 olasilik (G11)
// Altin model: dogrusal_olmayan.softmax_tam
//   enb  = max(skor | maske=1)              fark = enb - skor  (>= 0)
//   idx  = min((fark * M0) >> 16, 511)      e = exp_lut[idx]  (maskeli: 0)     (LUT 512 x 16 bit, host yukler)
//   top  = max(sum(e), 1)                   p = min((e*255 + top/2) / top, 255)  (ardisik bolucu)
// Akis: start -> L giris (in_valid, in_data, in_mask) -> hesap -> L cikis (out_valid, out_last).
// Genislik: skor 32 bit isaretli, M0 <= 2^24, fark <= 2^33 -> carpim < 2^58.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module softmax_birim #(
    parameter L    = 64,
    parameter LOGL = 6
) (
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 lut_we,
    input  wire [8:0]           lut_adr,
    input  wire [15:0]          lut_data,
    input  wire [23:0]          m0,
    input  wire                 start,
    output wire                 in_ready,
    input  wire                 in_valid,
    input  wire signed [31:0]   in_data,
    input  wire                 in_mask,
    output reg                  out_valid,
    output reg  [7:0]           out_data,
    output reg                  out_last,
    output wire                 busy
);
    localparam S_IDLE = 4'd0, S_LOAD = 4'd1, S_FARK = 4'd2, S_IDX = 4'd3, S_EXP = 4'd4,
               S_NUM = 4'd5, S_DIV = 4'd6, S_OUT = 4'd7, S_ACC = 4'd8;

    reg [3:0] st;
    reg [LOGL:0] cnt;
    reg signed [31:0] sbuf [0:L-1];
    reg               mbuf [0:L-1];
    reg [15:0]        ebuf [0:L-1];
    reg [15:0]        lut  [0:511];
    reg signed [33:0] enb;
    reg               var_gecerli;
    reg [23:0]        m0_r;
    reg [33:0]        fark;
    reg [57:0]        carp;
    reg [21:0]        top;
    reg [15:0]        e_r;

    wire [21:0] top_k = (top == 22'd0) ? 22'd1 : top;           // max(toplam, 1)
    reg         dv_start;
    reg  [23:0] dv_num;
    wire        dv_busy, dv_done;
    wire [23:0] dv_q, dv_r;
    bolucu_seri #(.W(24)) u_dv (.clk(clk), .rst(rst), .start(dv_start), .num(dv_num), .den({2'b00, top_k}),
                                .busy(dv_busy), .done(dv_done), .quo(dv_q), .rem(dv_r));

    assign in_ready = (st == S_LOAD);
    assign busy     = (st != S_IDLE);

    always @(posedge clk) if (lut_we) lut[lut_adr] <= lut_data;

    wire [LOGL-1:0] ix = cnt[LOGL-1:0];
    wire signed [33:0] s_cur = sbuf[ix];
    wire [8:0]  idx = (carp[57:16] > 42'd511) ? 9'd511 : carp[24:16];
    wire [23:0] pay = ebuf[ix] * 8'd255 + (top_k >> 1);

    always @(posedge clk) begin
        if (rst) begin
            st <= S_IDLE; cnt <= 0; out_valid <= 1'b0; out_data <= 8'd0; out_last <= 1'b0; dv_start <= 1'b0;
            enb <= 0; var_gecerli <= 1'b0; m0_r <= 0; e_r <= 0; fark <= 0; carp <= 0; top <= 0; dv_num <= 0;
        end else begin
            out_valid <= 1'b0; out_last <= 1'b0; dv_start <= 1'b0;
            case (st)
                S_IDLE: if (start) begin
                    m0_r <= m0; cnt <= 0; var_gecerli <= 1'b0; enb <= 0; top <= 0; st <= S_LOAD;
                end
                S_LOAD: if (in_valid) begin
                    sbuf[ix] <= in_data; mbuf[ix] <= in_mask;
                    if (in_mask && (!var_gecerli || in_data > enb)) begin enb <= in_data; var_gecerli <= 1'b1; end
                    if (cnt == L-1) begin cnt <= 0; st <= S_FARK; end else cnt <= cnt + 1;
                end
                S_FARK: begin
                    fark <= mbuf[ix] ? (enb - s_cur) : 34'd0;
                    st <= S_IDX;
                end
                S_IDX: begin
                    carp <= fark * m0_r;
                    st <= S_EXP;
                end
                S_EXP: begin
                    e_r <= mbuf[ix] ? lut[idx] : 16'd0;
                    st <= S_ACC;
                end
                S_ACC: begin
                    ebuf[ix] <= e_r;
                    top <= top + e_r;
                    if (cnt == L-1) begin cnt <= 0; st <= S_NUM; end
                    else begin cnt <= cnt + 1; st <= S_FARK; end
                end
                S_NUM: begin
                    dv_num <= pay; dv_start <= 1'b1; st <= S_DIV;
                end
                S_DIV: if (dv_done) st <= S_OUT;
                S_OUT: begin
                    out_valid <= 1'b1;
                    out_data  <= (dv_q > 24'd255) ? 8'd255 : dv_q[7:0];
                    out_last  <= (cnt == L-1);
                    if (cnt == L-1) st <= S_IDLE; else begin cnt <= cnt + 1; st <= S_NUM; end
                end
                default: st <= S_IDLE;
            endcase
        end
    end
endmodule
