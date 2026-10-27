// -----------------------------------------------------------------------------
// dogrusal_katman.v -- bir INT8 dogrusal katmanin uctan uca veri yolu (G7)
//   aktivasyon BRAM -> tile denetleyici + 8x8 dizi -> (+bias) -> yeniden olcekle -> [GELU LUT] -> cikis BRAM
// Ayni modul Q, K, V, attn_out, ffn1, ffn2, pooler, classifier icin kullanilir; katmana ozgu
// degerler (K, np, n, bayraklar) kos oncesi konfigurasyon girislerinden gelir.
//
// Host/TB arayuzu: aktivasyon yazma (aw_*), panel yazma (pw_*, panel_tamponu), GELU LUT yukleme (lw_*),
//   cikis okuma (cr_addr -> cr_data, kayitli). layer_done, cikis BRAM'in tamami yazildiktan sonra 1 darbe.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module dogrusal_katman #(
    parameter KMAX = 512,
    parameter KW   = 11,
    parameter PW   = 7,
    parameter AW   = 12
) (
    input  wire              clk,
    input  wire              rst,
    // konfigurasyon + denetim
    input  wire              kos,
    input  wire [KW-1:0]     cfg_k,
    input  wire [PW-1:0]     cfg_np,
    input  wire [5:0]        cfg_n,            // KAYDIRMA_<AD>
    input  wire              a_isaretsiz,
    input  wire              gelu_en,
    output wire              busy,
    output wire              layer_done,
    // aktivasyon (girdi) yazma
    input  wire              aw_en,
    input  wire [AW-1:0]     aw_addr,
    input  wire [63:0]       aw_data,
    // panel yazma / el sikisma
    input  wire              pw_en,
    input  wire              pw_buf,
    input  wire [1:0]        pw_sel,
    input  wire [KW-1:0]     pw_addr,
    input  wire [63:0]       pw_data,
    input  wire [1:0]        pan_hazir,
    output wire              pan_bitti,
    output wire              pan_bitti_buf,
    // GELU LUT yukleme
    input  wire              lw_en,
    input  wire [7:0]        lw_addr,
    input  wire [7:0]        lw_data,
    // cikis okuma
    input  wire [AW-1:0]     cr_addr,
    output wire [63:0]       cr_data,
    // tanilama
    output wire              tasma_hata,       // golge ustune yazildi
    output reg  [31:0]       kirpilan_say      // kirpilan eleman sayaci
);
    // ---- bellekler ----
    wire [AW-1:0] act_raddr;  wire [63:0] act_rdata;
    bram_sdp #(.AW(AW), .DW(64)) u_girdi (.clk(clk), .we(aw_en), .waddr(aw_addr), .wdata(aw_data),
                                          .raddr(act_raddr), .rdata(act_rdata));
    wire pan_rbuf; wire [KW-1:0] pan_raddr; wire [63:0] pan_rdata;
    wire out_pbuf; wire [2:0] out_rj; wire [31:0] rbias; wire [30:0] rm0;
    panel_tamponu #(.KMAX(KMAX), .KW(KW)) u_panel (.clk(clk), .pw_en(pw_en), .pw_buf(pw_buf), .pw_sel(pw_sel),
        .pw_addr(pw_addr), .pw_data(pw_data), .pr_buf(pan_rbuf), .pr_addr(pan_raddr), .pr_data(pan_rdata),
        .rbuf(out_pbuf), .rj(out_rj), .rbias(rbias), .rm0(rm0));

    // ---- tile denetleyici ----
    wire              out_valid, out_son;
    wire [2:0]        out_i, out_j;
    wire [3:0]        out_blk;
    wire [PW-1:0]     out_panel;
    wire signed [31:0] out_acc;
    wire              layer_done_i;
    tile_denetleyici #(.N(8), .NB(8), .KW(KW), .PW(PW), .AW(AW)) u_tile (
        .clk(clk), .rst(rst), .kos(kos), .cfg_k(cfg_k), .cfg_np(cfg_np), .a_isaretsiz(a_isaretsiz),
        .busy(busy), .layer_done(layer_done_i), .pan_hazir(pan_hazir), .pan_bitti(pan_bitti),
        .pan_bitti_buf(pan_bitti_buf), .act_raddr(act_raddr), .act_rdata(act_rdata),
        .pan_rbuf(pan_rbuf), .pan_raddr(pan_raddr), .pan_rdata(pan_rdata),
        .out_pbuf(out_pbuf), .out_rj(out_rj), .rbias(rbias),
        .out_valid(out_valid), .out_i(out_i), .out_j(out_j), .out_blk(out_blk), .out_panel(out_panel),
        .out_son(out_son), .out_acc(out_acc), .out_tasma(tasma_hata));

    // ---- m0'i out_acc ile hizala (ikisi de 1 cevrim kayitli) ----
    reg [30:0] m0_q;
    always @(posedge clk) m0_q <= rm0;

    // ---- yeniden olcekle ----
    wire               rq_v, rq_sat;
    wire signed [7:0]  rq_y;
    wire [17:0]        rq_meta;
    yeniden_olcekle #(.META_W(18)) u_rq (
        .clk(clk), .rst(rst), .vin(out_valid), .acc(out_acc), .m0(m0_q), .n(cfg_n),
        .meta_in({out_son, out_i, out_j, out_blk, out_panel}),
        .vout(rq_v), .y(rq_y), .meta_out(rq_meta), .sat(rq_sat));

    // ---- [GELU LUT] ----
    wire signed [7:0] lut_y;
    gelu_lut u_lut (.clk(clk), .lw_en(lw_en), .lw_addr(lw_addr), .lw_data(lw_data), .x(rq_y), .y(lut_y));
    wire signed [7:0] y_son = gelu_en ? lut_y : rq_y;

    // ---- paketle + cikis BRAM ----
    wire              c_we;
    wire [AW-1:0]     c_waddr;
    wire [63:0]       c_wdata;
    cikis_paketle #(.AW(AW), .PW(PW)) u_pk (
        .clk(clk), .rst(rst), .v(rq_v), .y(y_son),
        .i(rq_meta[16:14]), .j(rq_meta[13:11]), .blk(rq_meta[10:7]), .panel(rq_meta[6:0]),
        .c_toplam({cfg_np, 3'b000}), .we(c_we), .waddr(c_waddr), .wdata(c_wdata));
    bram_sdp #(.AW(AW), .DW(64)) u_cikis (.clk(clk), .we(c_we), .waddr(c_waddr), .wdata(c_wdata),
                                          .raddr(cr_addr), .rdata(cr_data));

    // ---- layer_done: boru hatti + paketleyici bosalana kadar ertele (4 cevrim) ----
    reg [4:0] ld_sr;
    always @(posedge clk) begin
        if (rst) ld_sr <= 5'd0; else ld_sr <= {ld_sr[3:0], layer_done_i};
    end
    assign layer_done = ld_sr[4];

    always @(posedge clk) begin
        if (rst || kos) kirpilan_say <= 32'd0;
        else if (rq_sat) kirpilan_say <= kirpilan_say + 32'd1;
    end
endmodule
