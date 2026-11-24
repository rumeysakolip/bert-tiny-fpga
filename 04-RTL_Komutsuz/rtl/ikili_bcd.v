// -----------------------------------------------------------------------------
// ikili_bcd.v -- 14 bitlik ikili sayiyi dort basamakli onlu (BCD) sayiya cevirir (kaydirma + 3 ekleme yontemi, seri)
//   Surekli calisir: her 16 cevrimde bir sonuc yenilenir. Girdi 0..9999 araligindadir (ust modul sinirlar).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module ikili_bcd (
    input  wire        clk,
    input  wire [13:0] ikili,
    output reg  [15:0] bcd
);
    reg [13:0] kayd;
    reg [15:0] bir;
    reg [4:0]  adim;

    function [3:0] ekle3;
        input [3:0] d;
        ekle3 = (d >= 4'd5) ? (d + 4'd3) : d;
    endfunction

    wire [15:0] duz = {ekle3(bir[15:12]), ekle3(bir[11:8]), ekle3(bir[7:4]), ekle3(bir[3:0])};

    initial begin kayd = 14'd0; bir = 16'd0; adim = 5'd0; bcd = 16'd0; end

    always @(posedge clk) begin
        if (adim == 5'd0) begin
            kayd <= ikili; bir <= 16'd0; adim <= 5'd1;
        end else if (adim <= 5'd14) begin
            bir  <= {duz[14:0], kayd[13]};
            kayd <= {kayd[12:0], 1'b0};
            adim <= adim + 5'd1;
        end else begin
            bcd  <= bir; adim <= 5'd0;
        end
    end
endmodule
