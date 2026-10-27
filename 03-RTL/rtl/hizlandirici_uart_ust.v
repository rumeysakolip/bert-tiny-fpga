// hizlandirici_uart_ust.v -- kart ust modulu: UART (8N1) + hizlandirici_ust. Basys3: clk 100 MHz, USB-UART.
`timescale 1ns/1ps
module hizlandirici_uart_ust #(parameter CLKS_PER_BIT = 109) (   // 100e6/921600 = 108.5 -> 109
    input  wire clk,
    input  wire rst,
    input  wire uart_rx_pin,
    output wire uart_tx_pin
);
    wire        rx_valid; wire [7:0] rx_data;
    wire        tx_valid; wire [7:0] tx_data; wire tx_ready, tx_bos;
    wire [15:0] ps, hs;
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx (.clk(clk), .rst(rst), .rx(uart_rx_pin), .valid(rx_valid), .data(rx_data));
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (.clk(clk), .rst(rst), .valid(tx_valid), .data(tx_data), .ready(tx_ready), .tx(uart_tx_pin));
    hizlandirici_ust u_ust (.clk(clk), .rst(rst), .rx_valid(rx_valid), .rx_data(rx_data),
        .tx_valid(tx_valid), .tx_data(tx_data), .tx_ready(tx_ready), .tx_bos(tx_bos), .paket_sayisi(ps), .hata_sayisi(hs));
endmodule
