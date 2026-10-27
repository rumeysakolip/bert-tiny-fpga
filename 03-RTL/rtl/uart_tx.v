// uart_tx.v -- 8N1 UART verici. valid&&ready ile bayt kabul edilir; ready yalniz bostayken 1.
`timescale 1ns/1ps
module uart_tx #(parameter CLKS_PER_BIT = 109) (
    input  wire       clk,
    input  wire       rst,
    input  wire       valid,
    input  wire [7:0] data,
    output wire       ready,
    output reg        tx
);
    localparam CW = 16;
    reg          mesgul;
    reg [CW-1:0] sayac;
    reg [3:0]    bit_i;       // 0 baslangic, 1..8 veri, 9 durdurma
    reg [9:0]    kayma;
    assign ready = !mesgul;
    always @(posedge clk) begin
        if (rst) begin mesgul <= 1'b0; tx <= 1'b1; sayac <= {CW{1'b0}}; bit_i <= 4'd0; kayma <= 10'h3FF; end
        else if (!mesgul) begin
            tx <= 1'b1;
            if (valid) begin kayma <= {1'b1, data, 1'b0}; mesgul <= 1'b1; sayac <= {CW{1'b0}}; bit_i <= 4'd0; tx <= 1'b0; end
        end else begin
            if (sayac == CLKS_PER_BIT - 1) begin
                sayac <= {CW{1'b0}};
                if (bit_i == 4'd9) begin mesgul <= 1'b0; tx <= 1'b1; end
                else begin bit_i <= bit_i + 1'b1; tx <= kayma[bit_i + 1'b1]; end
            end else sayac <= sayac + 1'b1;
        end
    end
endmodule
