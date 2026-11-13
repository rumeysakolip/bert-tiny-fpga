// -----------------------------------------------------------------------------
// kart_ust.v -- Basys 3 (XC7A35T-1CPG236C) ust modulu: yalniz pin ilkelleri; asil is kart_mantik.v icinde
//   Flas saati (CCLK) 7 serisinde dogrudan pine atanamaz; STARTUPE2 ilkeli uzerinden surulur.
//   Flas veri hatlari: io0 komut/adres/bosluk asamasinda cikis, veri asamasinda giris; io1 hep giris; io2/io3 komut asamasinda yuksek.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module kart_ust (
    input  wire        clk,            // 100 MHz
    input  wire        btnC,           // orta dugme: bastan baslat
    input  wire [15:0] sw,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire        dp,
    output wire [3:0]  an,
    inout  wire [3:0]  QspiDB,
    output wire        QspiCSn
);
    wire f_sck, f_cs_n, f_io0, f_oe;
    wire [3:0] f_in;

    kart_mantik #(.BOL(4)) u_kart (
        .clk(clk), .btn(btnC), .sw(sw), .led(led), .seg(seg), .dp(dp), .an(an),
        .flas_sck(f_sck), .flas_cs_n(f_cs_n), .flas_io0_o(f_io0), .flas_io_oe(f_oe), .flas_io_i(f_in));

    assign QspiCSn    = f_cs_n;
    assign QspiDB[0]  = f_oe ? f_io0 : 1'bz;
    assign QspiDB[1]  = 1'bz;
    assign QspiDB[2]  = f_oe ? 1'b1  : 1'bz;
    assign QspiDB[3]  = f_oe ? 1'b1  : 1'bz;
    assign f_in       = QspiDB;

    STARTUPE2 #(.PROG_USR("FALSE"), .SIM_CCLK_FREQ(0.0)) u_startup (
        .CFGCLK(), .CFGMCLK(), .EOS(), .PREQ(),
        .CLK(1'b0), .GSR(1'b0), .GTS(1'b0), .KEYCLEARB(1'b1), .PACK(1'b0),
        .USRCCLKO(f_sck), .USRCCLKTS(1'b0), .USRDONEO(1'b1), .USRDONETS(1'b1));
endmodule
