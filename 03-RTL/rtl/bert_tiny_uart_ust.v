// bert_tiny_uart_ust.v -- kart ust modulu (G13): UART (8N1) + bert_tiny_ust. Basys3: clk 100 MHz, USB-UART.
// Portlar hizlandirici_uart_ust ile ayni (clk, rst, uart_rx_pin, uart_tx_pin) -> sentez/basys3.xdc degismeden kullanilir.
`timescale 1ns/1ps
module bert_tiny_uart_ust #(parameter CLKS_PER_BIT = 109) (   // 100e6/921600 = 108.5 -> 109
    input  wire clk,
    input  wire rst,
    input  wire uart_rx_pin,
    output wire uart_tx_pin
);
    // reset dugmesi saatle eszamansiz: basma aninda eszamansiz kurulur, birakma saatle hizali (2 kademeli senkronlayici)
    (* ASYNC_REG = "TRUE" *) reg [1:0] reset_kaydi = 2'b11;
    always @(posedge clk or posedge rst) begin
        if (rst) reset_kaydi <= 2'b11;
        else     reset_kaydi <= {reset_kaydi[0], 1'b0};
    end
    wire reset_senkron = reset_kaydi[1];
    wire        rx_valid; wire [7:0] rx_data;
    wire        tx_valid; wire [7:0] tx_data; wire tx_ready, tx_bos;
    wire [15:0] ps, hs;
    uart_alici #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_uart_alici (.clk(clk), .rst(reset_senkron), .rx(uart_rx_pin), .gecerli(rx_valid), .veri(rx_data));
    uart_verici #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_uart_verici (.clk(clk), .rst(reset_senkron), .gecerli(tx_valid), .veri(tx_data), .gonderilebilir(tx_ready), .tx(uart_tx_pin));
    bert_tiny_ust u_bert_tiny (.clk(clk), .rst(reset_senkron), .rx_valid(rx_valid), .rx_data(rx_data),
        .tx_valid(tx_valid), .tx_data(tx_data), .tx_ready(tx_ready), .tx_bos(tx_bos), .paket_sayisi(ps), .hata_sayisi(hs));
endmodule
