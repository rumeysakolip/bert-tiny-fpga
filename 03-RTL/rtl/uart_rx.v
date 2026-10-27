// uart_rx.v -- 8N1 UART alici; CLKS_PER_BIT = f_clk / baud (100 MHz, 921600 baud -> 109; 3 Mbaud -> 33)
`timescale 1ns/1ps
module uart_rx #(parameter CLKS_PER_BIT = 109) (
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output reg        valid,
    output reg  [7:0] data
);
    localparam CW = 16;
    reg [1:0]    s;            // 2-FF senkronlayici
    reg          rx_s;
    reg [1:0]    durum;        // 0 bosta, 1 baslangic, 2 veri, 3 durdurma
    reg [CW-1:0] sayac;
    reg [2:0]    bit_i;
    reg [7:0]    kay;
    always @(posedge clk) begin
        s <= {s[0], rx}; rx_s <= s[1];
        valid <= 1'b0;
        if (rst) begin durum <= 2'd0; sayac <= {CW{1'b0}}; bit_i <= 3'd0; kay <= 8'd0; data <= 8'd0; s <= 2'b11; rx_s <= 1'b1; end
        else case (durum)
            2'd0: if (!rx_s) begin durum <= 2'd1; sayac <= {CW{1'b0}}; end
            2'd1: if (sayac == (CLKS_PER_BIT/2)) begin          // baslangic bitinin ortasi
                      if (!rx_s) begin durum <= 2'd2; sayac <= {CW{1'b0}}; bit_i <= 3'd0; end
                      else durum <= 2'd0;
                  end else sayac <= sayac + 1'b1;
            2'd2: if (sayac == CLKS_PER_BIT - 1) begin
                      sayac <= {CW{1'b0}}; kay <= {rx_s, kay[7:1]};
                      if (bit_i == 3'd7) durum <= 2'd3; else bit_i <= bit_i + 1'b1;
                  end else sayac <= sayac + 1'b1;
            2'd3: if (sayac == CLKS_PER_BIT - 1) begin
                      durum <= 2'd0; sayac <= {CW{1'b0}};
                      if (rx_s) begin valid <= 1'b1; data <= kay; end        // durdurma biti dogruysa
                  end else sayac <= sayac + 1'b1;
        endcase
    end
endmodule
