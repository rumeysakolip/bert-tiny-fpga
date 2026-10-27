// -----------------------------------------------------------------------------
// panel_tamponu.v -- cift tamponlu agirlik paneli (host'tan akitilir) (G5)
//   Her tampon: W[K] (64 bit sozcuk: bayt j = kanal j), bias[8] INT32, m0[8] (31 bit).
//   Host bir tamponu yazarken denetleyici digerini okur (ping-pong).
//
// Yazma portu : pw_en, pw_buf, pw_sel (0=W, 1=bias, 2=m0), pw_addr (W: k ; bias/m0: j), pw_data[63:0]
// W okuma     : pr_buf, pr_addr -> pr_data (KAYITLI, 1 cevrim gecikme; BRAM)
// bias/m0     : rbuf, rj -> rbias, rm0 (birlesik/anlik; 2x8 yazmac)
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module panel_tamponu #(
    parameter KMAX = 512,
    parameter KW   = 11
) (
    input  wire             clk,
    input  wire             pw_en,
    input  wire             pw_buf,
    input  wire [1:0]       pw_sel,
    input  wire [KW-1:0]    pw_addr,
    input  wire [63:0]      pw_data,

    input  wire             pr_buf,
    input  wire [KW-1:0]    pr_addr,
    output reg  [63:0]      pr_data,

    input  wire             rbuf,
    input  wire [2:0]       rj,
    output wire [31:0]      rbias,
    output wire [30:0]      rm0
);
    reg [63:0] w0 [0:KMAX-1];
    reg [63:0] w1 [0:KMAX-1];
    reg [31:0] bias0 [0:7];
    reg [31:0] bias1 [0:7];
    reg [30:0] m00 [0:7];
    reg [30:0] m01 [0:7];

    always @(posedge clk) begin
        if (pw_en && pw_sel == 2'd0) begin
            if (pw_buf) w1[pw_addr] <= pw_data; else w0[pw_addr] <= pw_data;
        end
        if (pw_en && pw_sel == 2'd1) begin
            if (pw_buf) bias1[pw_addr[2:0]] <= pw_data[31:0]; else bias0[pw_addr[2:0]] <= pw_data[31:0];
        end
        if (pw_en && pw_sel == 2'd2) begin
            if (pw_buf) m01[pw_addr[2:0]] <= pw_data[30:0]; else m00[pw_addr[2:0]] <= pw_data[30:0];
        end
        pr_data <= pr_buf ? w1[pr_addr] : w0[pr_addr];
    end

    assign rbias = rbuf ? bias1[rj] : bias0[rj];
    assign rm0   = rbuf ? m01[rj]   : m00[rj];
endmodule
