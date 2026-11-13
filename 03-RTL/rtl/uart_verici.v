// uart_verici.v -- 8N1 UART verici. valid&&ready ile bayt kabul edilir; ready yalniz bostayken 1.
`timescale 1ns/1ps
module uart_verici #(parameter CLKS_PER_BIT = 109) (
    input  wire       clk,
    input  wire       rst,
    input  wire       gecerli,
    input  wire [7:0] veri,
    output wire       gonderilebilir,
    output reg        tx
);
    localparam SAYAC_GENISLIGI = 16;
    reg          mesgul;
    reg [SAYAC_GENISLIGI-1:0] sayac;
    reg [3:0]    bit_sirasi;       // 0 baslangic, 1..8 veri, 9 durdurma
    reg [9:0]    kaydirma_yazmaci;
    assign gonderilebilir = !mesgul;
    always @(posedge clk) begin
        if (rst) begin mesgul <= 1'b0; tx <= 1'b1; sayac <= {SAYAC_GENISLIGI{1'b0}}; bit_sirasi <= 4'd0; kaydirma_yazmaci <= 10'h3FF; end
        else if (!mesgul) begin
            tx <= 1'b1;
            if (gecerli) begin kaydirma_yazmaci <= {1'b1, veri, 1'b0}; mesgul <= 1'b1; sayac <= {SAYAC_GENISLIGI{1'b0}}; bit_sirasi <= 4'd0; tx <= 1'b0; end
        end else begin
            if (sayac == CLKS_PER_BIT - 1) begin
                sayac <= {SAYAC_GENISLIGI{1'b0}};
                if (bit_sirasi == 4'd9) begin mesgul <= 1'b0; tx <= 1'b1; end
                else begin bit_sirasi <= bit_sirasi + 1'b1; tx <= kaydirma_yazmaci[bit_sirasi + 1'b1]; end
            end else sayac <= sayac + 1'b1;
        end
    end
endmodule
