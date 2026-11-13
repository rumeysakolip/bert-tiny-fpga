// uart_alici.v -- 8N1 UART alici; CLKS_PER_BIT = f_clk / baud (100 MHz, 921600 baud -> 109; 3 Mbaud -> 33)
`timescale 1ns/1ps
module uart_alici #(parameter CLKS_PER_BIT = 109) (
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output reg        gecerli,
    output reg  [7:0] veri
);
    localparam SAYAC_GENISLIGI = 16;
    reg [1:0]    senkron;            // 2-FF senkronlayici
    reg          rx_senkron;
    reg [1:0]    durum;        // 0 bosta, 1 baslangic, 2 veri, 3 durdurma
    reg [SAYAC_GENISLIGI-1:0] sayac;
    reg [2:0]    bit_sirasi;
    reg [7:0]    alinan_bayt;
    always @(posedge clk) begin
        senkron <= {senkron[0], rx}; rx_senkron <= senkron[1];
        gecerli <= 1'b0;
        if (rst) begin durum <= 2'd0; sayac <= {SAYAC_GENISLIGI{1'b0}}; bit_sirasi <= 3'd0; alinan_bayt <= 8'd0; veri <= 8'd0; senkron <= 2'b11; rx_senkron <= 1'b1; end
        else case (durum)
            2'd0: if (!rx_senkron) begin durum <= 2'd1; sayac <= {SAYAC_GENISLIGI{1'b0}}; end
            2'd1: if (sayac == (CLKS_PER_BIT/2)) begin          // baslangic bitinin ortasi
                      if (!rx_senkron) begin durum <= 2'd2; sayac <= {SAYAC_GENISLIGI{1'b0}}; bit_sirasi <= 3'd0; end
                      else durum <= 2'd0;
                  end else sayac <= sayac + 1'b1;
            2'd2: if (sayac == CLKS_PER_BIT - 1) begin
                      sayac <= {SAYAC_GENISLIGI{1'b0}}; alinan_bayt <= {rx_senkron, alinan_bayt[7:1]};
                      if (bit_sirasi == 3'd7) durum <= 2'd3; else bit_sirasi <= bit_sirasi + 1'b1;
                  end else sayac <= sayac + 1'b1;
            2'd3: if (sayac == CLKS_PER_BIT - 1) begin
                      durum <= 2'd0; sayac <= {SAYAC_GENISLIGI{1'b0}};
                      if (rx_senkron) begin gecerli <= 1'b1; veri <= alinan_bayt; end        // durdurma biti dogruysa
                  end else sayac <= sayac + 1'b1;
        endcase
    end
endmodule
