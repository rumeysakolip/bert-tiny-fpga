// -----------------------------------------------------------------------------
// cikis_paketle.v -- INT8 cikislari 64 bit sozcuge toplar ve cikis BRAM'ine yazar (G6/G7)
// Giris sirasi: kanal j dis dongu, token i ic dongu (i=0..7 ardisik). Sozcuk (blk, kanal c):
//   bayt i = Y[blk*8+i][c]   -> sonraki katmanin aktivasyon duzeniyle AYNI (b*K' + k, K'=C).
// Yazma adresi = blk*C + panel*8 + j  (C = 8*np).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module cikis_paketle #(
    parameter AW = 12,
    parameter PW = 7
) (
    input  wire              clk,
    input  wire              rst,
    input  wire              v,
    input  wire signed [7:0] y,
    input  wire [2:0]        i,
    input  wire [2:0]        j,
    input  wire [3:0]        blk,
    input  wire [PW-1:0]     panel,
    input  wire [9:0]        c_toplam,       // C = 8*np
    output reg               we,
    output reg  [AW-1:0]     waddr,
    output reg  [63:0]       wdata
);
    reg [55:0] ust;                           // i=0..6 baytlari
    always @(posedge clk) begin
        if (rst) begin
            we <= 1'b0; ust <= 56'd0;
        end else begin
            we <= 1'b0;
            if (v) begin
                if (i == 3'd7) begin
                    we    <= 1'b1;
                    wdata <= {y, ust};
                    waddr <= blk * c_toplam + {panel, 3'b000} + j;
                end else begin
                    ust[i*8 +: 8] <= y;
                end
            end
        end
    end
endmodule
