// tb_uart.v -- hizlandirici_uart_ust: gercek UART bit hizinda paket (DURUM, bozuk CRC'li CFG, CFG+DURUM) (G9)
// CLKS_PER_BIT=16 (benzetim hizi icin); kart icin 109 (921600 baud @100 MHz) veya 33 (3 Mbaud).
`timescale 1ns/1ps
module tb_uart;
    parameter CPB = 16;
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;
    initial begin $dumpfile("sim/tb_uart.vcd"); $dumpvars(1, tb_uart); end
    reg  rx_pin = 1;
    wire tx_pin;
    hizlandirici_uart_ust #(.CLKS_PER_BIT(CPB)) dut (.clk(clk), .rst(rst), .uart_rx_pin(rx_pin), .uart_tx_pin(tx_pin));

    task bayt_gonder;
        input [7:0] b;
        integer k;
        begin
            rx_pin = 0; repeat (CPB) @(posedge clk);
            for (k = 0; k < 8; k = k + 1) begin rx_pin = b[k]; repeat (CPB) @(posedge clk); end
            rx_pin = 1; repeat (CPB) @(posedge clk);
        end
    endtask

    // alici: tx_pin'deki baytlari yakala
    reg [7:0] rxb [0:63];
    integer rxn;
    reg [7:0] kay;
    integer kb;
    initial begin
        rxn = 0;
        forever begin
            @(negedge tx_pin);
            repeat (CPB + CPB/2) @(posedge clk);
            for (kb = 0; kb < 8; kb = kb + 1) begin kay[kb] = tx_pin; repeat (CPB) @(posedge clk); end
            rxb[rxn] = kay; rxn = rxn + 1;
        end
    end

    function [7:0] crc8;
        input [7:0] c; input [7:0] d;
        reg [7:0] x; integer b;
        begin x = c ^ d; for (b = 0; b < 8; b = b + 1) x = x[7] ? ((x << 1) ^ 8'h07) : (x << 1); crc8 = x; end
    endfunction

    integer errors = 0, checks = 0, i;
    reg [7:0] c;
    task bekle_bayt;
        input integer n;
        integer t;
        begin t = 0; while (rxn < n && t < 200000) begin @(posedge clk); t = t + 1; end end
    endtask
    task kontrol;
        input [255:0] ad; input ok;
        begin checks = checks + 1; if (!ok) begin errors = errors + 1; $display("  FAIL: %0s", ad); end end
    endtask

    initial begin
        repeat (5) @(posedge clk); rst = 0; repeat (5) @(posedge clk);
        // 1) DURUM (cmd 6, len 0): beklenen VERI 02 06 02 00 b0 b1 crc
        c = crc8(0, 8'h06); c = crc8(c, 8'h00); c = crc8(c, 8'h00);
        bayt_gonder(8'h06); bayt_gonder(8'h00); bayt_gonder(8'h00); bayt_gonder(c);
        bekle_bayt(7);
        kontrol("DURUM baslik", rxb[0] == 8'h02 && rxb[1] == 8'h06 && rxb[2] == 8'h02 && rxb[3] == 8'h00);
        kontrol("DURUM busy=0", rxb[4][0] == 1'b0);
        kontrol("DURUM pan_bos=11", rxb[5][1:0] == 2'b11);
        c = crc8(0, 8'h06); c = crc8(c, 8'h02); c = crc8(c, 8'h00); c = crc8(c, rxb[4]); c = crc8(c, rxb[5]);
        kontrol("DURUM crc", rxb[6] == c);
        // 2) bozuk CRC'li CFG -> HATA kod 1
        rxn = 0;
        bayt_gonder(8'h01); bayt_gonder(8'h05); bayt_gonder(8'h00);
        bayt_gonder(8'h00); bayt_gonder(8'h01); bayt_gonder(8'h02); bayt_gonder(8'h25); bayt_gonder(8'h00);
        bayt_gonder(8'hAA);                                     // yanlis CRC
        bekle_bayt(3);
        kontrol("HATA bayt0", rxb[0] == 8'h15); kontrol("HATA cmd", rxb[1] == 8'h01); kontrol("HATA kod=CRC", rxb[2] == 8'h01);
        // 3) dogru CRC'li CFG -> ACK
        rxn = 0;
        c = crc8(0, 8'h01); c = crc8(c, 8'h05); c = crc8(c, 8'h00);
        c = crc8(c, 8'h00); c = crc8(c, 8'h01); c = crc8(c, 8'h02); c = crc8(c, 8'h25); c = crc8(c, 8'h00);
        bayt_gonder(8'h01); bayt_gonder(8'h05); bayt_gonder(8'h00);
        bayt_gonder(8'h00); bayt_gonder(8'h01); bayt_gonder(8'h02); bayt_gonder(8'h25); bayt_gonder(8'h00);
        bayt_gonder(c);
        bekle_bayt(2);
        kontrol("CFG ACK", rxb[0] == 8'h06 && rxb[1] == 8'h01);
        // 4) hata sayaci
        kontrol("hata_sayisi=1", dut.u_ust.u_cd.hata_sayisi == 16'd1);
        kontrol("cfg_k=256 (0x100)", dut.u_ust.u_cd.cfg_k == 11'd256 && dut.u_ust.u_cd.cfg_np == 7'd2 && dut.u_ust.u_cd.cfg_n == 6'd37);

        $display("----------------------------------------------");
        if (errors == 0) $display("UART TEST (CLKS_PER_BIT=%0d): PASS  (%0d kontrol, 0 hata)", CPB, checks);
        else             $display("UART TEST (CLKS_PER_BIT=%0d): FAIL  (%0d hata)", CPB, errors);
        $finish;
    end
endmodule
