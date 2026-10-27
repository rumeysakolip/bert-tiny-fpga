// hizlandirici_ust.v -- bayt akisi arayuzlu hizlandirici: komut_cozucu + dogrusal_katman (G9)
// UART'siz test icin dogrudan bayt portlari; kart icin hizlandirici_uart_ust bunu UART'a sarar.
`timescale 1ns/1ps
module hizlandirici_ust (
    input  wire        clk,
    input  wire        rst,
    input  wire        rx_valid,
    input  wire [7:0]  rx_data,
    output wire        tx_valid,
    output wire [7:0]  tx_data,
    input  wire        tx_ready,
    output wire        tx_bos,
    output wire [15:0] paket_sayisi,
    output wire [15:0] hata_sayisi
);
    wire kos, a_isaretsiz, gelu_en, busy, layer_done, tasma_hata, pan_bitti, pan_bitti_buf;
    wire [10:0] cfg_k; wire [6:0] cfg_np; wire [5:0] cfg_n;
    wire aw_en; wire [11:0] aw_addr; wire [63:0] aw_data;
    wire pw_en, pw_buf; wire [1:0] pw_sel; wire [10:0] pw_addr; wire [63:0] pw_data;
    wire [1:0] pan_hazir, pan_bos;
    wire lw_en; wire [7:0] lw_addr, lw_data;
    wire [11:0] cr_addr; wire [63:0] cr_data;
    wire [31:0] kirpilan_say;

    komut_cozucu u_cd (.clk(clk), .rst(rst), .rx_valid(rx_valid), .rx_data(rx_data),
        .tx_valid(tx_valid), .tx_data(tx_data), .tx_ready(tx_ready), .tx_bos(tx_bos),
        .kos(kos), .cfg_k(cfg_k), .cfg_np(cfg_np), .cfg_n(cfg_n), .a_isaretsiz(a_isaretsiz), .gelu_en(gelu_en),
        .busy(busy), .layer_done(layer_done), .tasma_hata(tasma_hata), .pan_bitti(pan_bitti), .pan_bitti_buf(pan_bitti_buf),
        .aw_en(aw_en), .aw_addr(aw_addr), .aw_data(aw_data),
        .pw_en(pw_en), .pw_buf(pw_buf), .pw_sel(pw_sel), .pw_addr(pw_addr), .pw_data(pw_data),
        .pan_hazir(pan_hazir), .lw_en(lw_en), .lw_addr(lw_addr), .lw_data(lw_data),
        .cr_addr(cr_addr), .cr_data(cr_data), .pan_bos(pan_bos),
        .paket_sayisi(paket_sayisi), .hata_sayisi(hata_sayisi));

    dogrusal_katman u_kat (.clk(clk), .rst(rst), .kos(kos), .cfg_k(cfg_k), .cfg_np(cfg_np), .cfg_n(cfg_n),
        .a_isaretsiz(a_isaretsiz), .gelu_en(gelu_en), .busy(busy), .layer_done(layer_done),
        .aw_en(aw_en), .aw_addr(aw_addr), .aw_data(aw_data),
        .pw_en(pw_en), .pw_buf(pw_buf), .pw_sel(pw_sel), .pw_addr(pw_addr), .pw_data(pw_data),
        .pan_hazir(pan_hazir), .pan_bitti(pan_bitti), .pan_bitti_buf(pan_bitti_buf),
        .lw_en(lw_en), .lw_addr(lw_addr), .lw_data(lw_data), .cr_addr(cr_addr), .cr_data(cr_data),
        .tasma_hata(tasma_hata), .kirpilan_say(kirpilan_say));
endmodule
