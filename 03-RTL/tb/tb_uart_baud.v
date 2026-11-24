// tb_uart_baud.v -- tb_uart.v ile ayni paketler; fark: ana makinenin bit suresi saat cevriminden BAGIMSIZ, gercek zamanla (1e9/BAUD ns) uretilir.
// Boylece CLKS_PER_BIT tam sayi yuvarlama hatasi (f_clk/baud tam bolunmedigi durum) benzetimde sinanir.
// Calistirma (cwd = 03-RTL):
//   iverilog -g2001 -o sim/tb_uart_baud.vvp -P tb_uart_baud.CPB=33 -P tb_uart_baud.F_MHZ=100 -P tb_uart_baud.BAUD=3000000 \
//            rtl/*.v(uart ve hizlandirici dosyalari) tb/tb_uart_baud.v ; vvp sim/tb_uart_baud.vvp
//   Son satir: "UART BAUD TEST (...): PASS|FAIL"
// Not: saat yarim periyodu 500/F_MHZ ns, 1 ps cozunurlukle yuvarlanir (96 MHz -> 96,0015 MHz gibi <%0,02 fark; baud hatasi yaninda ihmal edilir).
`timescale 1ns/1ps
module tb_uart_baud;
    parameter CPB   = 109;            // DUT'un CLKS_PER_BIT degeri
    parameter real F_MHZ = 100.0;     // DUT saat frekansi (MHz)
    parameter real BAUD  = 921600.0;  // ana makinenin (PC) baud hizi
    localparam real YARIM_NS = 500.0 / F_MHZ;
    localparam real BIT_NS   = 1.0e9 / BAUD;
    reg clk = 0, rst = 1;
    always #(YARIM_NS) clk = ~clk;
    reg  rx_pin = 1;
    wire tx_pin;
    bert_tiny_uart_ust #(.CLKS_PER_BIT(CPB)) dut (.clk(clk), .rst(rst), .uart_rx_pin(rx_pin), .uart_tx_pin(tx_pin));

    task bayt_gonder;
        input [7:0] b;
        integer k;
        begin
            rx_pin = 0; #(BIT_NS);
            for (k = 0; k < 8; k = k + 1) begin rx_pin = b[k]; #(BIT_NS); end
            rx_pin = 1; #(BIT_NS);
        end
    endtask

    // PC alicisi: tx_pin'deki baytlari PC baud hizinda ornekle (bitin ortasi)
    reg [7:0] rxb [0:63];
    integer rxn;
    reg [7:0] kay;
    integer kb;
    initial begin
        rxn = 0;
        forever begin
            @(negedge tx_pin);
            #(1.5 * BIT_NS);
            for (kb = 0; kb < 8; kb = kb + 1) begin kay[kb] = tx_pin; #(BIT_NS); end
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
        kontrol("DURUM panel_bos=11", rxb[5][1:0] == 2'b11);
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
        kontrol("hata_sayisi=1", dut.u_bert_tiny.u_veri_yolu.hata_sayisi == 16'd1);
        kontrol("ayar_k=256 (0x100)", dut.u_bert_tiny.u_veri_yolu.ayar_k == 11'd256 && dut.u_bert_tiny.u_veri_yolu.ayar_panel_sayisi == 7'd2 && dut.u_bert_tiny.u_veri_yolu.ayar_kaydirma == 6'd37);

        $display("----------------------------------------------");
        if (errors == 0) $display("UART BAUD TEST (CPB=%0d, f=%0.2f MHz, baud=%0.0f): PASS  (%0d kontrol, 0 hata)", CPB, F_MHZ, BAUD, checks);
        else             $display("UART BAUD TEST (CPB=%0d, f=%0.2f MHz, baud=%0.0f): FAIL  (%0d hata)", CPB, F_MHZ, BAUD, errors);
        $finish;
    end
endmodule
