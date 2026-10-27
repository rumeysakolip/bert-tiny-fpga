// -----------------------------------------------------------------------------
// bram_sdp.v -- basit cift-kapili (1 yazma, 1 okuma) senkron bellek; okuma KAYITLI (1 cevrim gecikme).
// Vivado'da block RAM olarak cikarilir (ayri okuma adresi, yazma-oncesi okuma davranisi).
// Aktivasyon BRAM'i icin kullanilir: sozcuk = 8 token bayti (bayt i = token i).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module bram_sdp #(
    parameter AW = 12,
    parameter DW = 64
) (
    input  wire             clk,
    input  wire             we,
    input  wire [AW-1:0]    waddr,
    input  wire [DW-1:0]    wdata,
    input  wire [AW-1:0]    raddr,
    output reg  [DW-1:0]    rdata
);
    reg [DW-1:0] mem [0:(1<<AW)-1];

    always @(posedge clk) begin
        if (we) mem[waddr] <= wdata;
        rdata <= mem[raddr];
    end
endmodule
