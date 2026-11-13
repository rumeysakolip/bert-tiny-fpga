// -----------------------------------------------------------------------------
// bert_tiny_mmcm_ust.v -- kart ust modulu: 100 MHz osilator -> MMCME2_BASE -> tasarim saati; UART bolucusu yeni saate gore (Konu 6)
//
// f_cikis = 100 MHz * (MMCM_CARPAN_X8/8) / (MMCM_BOLEN_X8/8);  VCO = 100 * MMCM_CARPAN_X8/8, -1 hiz sinifinda 600..1200 MHz olmali.
// (Parametreler tamsayi: Vivado -generic ile gercel deger gecirmek yerine 1/8 adimli tamsayi kullanilir.)
// Port adi `clk` (100 MHz giris): sentez/basys3.xdc degismeden kullanilir; MMCM cikis saati Vivado tarafindan otomatik turetilir.
//   96,25 MHz: CARPAN_X8=77 (9,625), BOLEN_X8=80 (VCO 962,5): 12 Mbaud icin CLKS_PER_BIT=8 (gercek 12,031 Mbaud, hata %+0,26)
//   125 MHz: CARPAN_X8=80,  BOLEN_X8=64   (VCO 1000)
//   150 MHz: CARPAN_X8=72,  BOLEN_X8=48   (VCO 900)
// CLKS_PER_BIT = f_cikis / baud (en yakin tam sayi; hata ve esikler: sim/sure_modeli.json, sim/uart_kombinasyonlari.csv).
// Reset: ic reset = rst | ~locked; birakma tasarim saatinde 2 kademeli senkronlayici ile yapilir. locked=0 iken tasarim reset'te kalir.
//
// BENZETIM NOTU: Icarus'ta MMCME2_BASE modeli yoktur. `-DMMCM_YOK` ile derlenirse MMCM atlanir: tasarim saati = giris saati, locked=1.
// Boylece benzetimde frekans degismez (100 MHz'lik testbench saatiyle calisir); MMCM'nin kendisi YALNIZ Vivado'da (sentez/yerlestirme) sinanir
// ve KARTTA DENENMEDI. Testbench saati MMCM cikis frekansini temsil etmek istiyorsa testbench saatini ona gore secin.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module bert_tiny_mmcm_ust #(
    parameter integer MMCM_CARPAN_X8 = 80,        // CLKFBOUT_MULT_F * 8 (0,125 adim): 80 = 10,0
    parameter integer MMCM_BOLEN_X8  = 64,        // CLKOUT0_DIVIDE_F * 8: 64 = 8,0
    parameter integer CLKS_PER_BIT = 136          // 125 MHz / 921600 baud = 135,6 -> 136
) (
    input  wire clk,
    input  wire rst,
    input  wire uart_rx_pin,
    output wire uart_tx_pin
);
    wire clk_tas, locked;
`ifdef MMCM_YOK
    assign clk_tas = clk;
    assign locked  = 1'b1;
`else
    wire clkfb_ham, clkfb, clk_ham;
    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKIN1_PERIOD(10.0),
        .DIVCLK_DIVIDE(1),
        .CLKFBOUT_MULT_F(MMCM_CARPAN_X8 / 8.0),
        .CLKOUT0_DIVIDE_F(MMCM_BOLEN_X8 / 8.0),
        .STARTUP_WAIT("FALSE")
    ) u_mmcm (
        .CLKIN1(clk), .CLKFBIN(clkfb), .CLKFBOUT(clkfb_ham), .CLKOUT0(clk_ham),
        .CLKOUT0B(), .CLKOUT1(), .CLKOUT1B(), .CLKOUT2(), .CLKOUT2B(), .CLKOUT3(), .CLKOUT3B(),
        .CLKOUT4(), .CLKOUT5(), .CLKOUT6(), .CLKFBOUTB(),
        .LOCKED(locked), .PWRDWN(1'b0), .RST(1'b0));
    BUFG u_fb  (.I(clkfb_ham), .O(clkfb));
    BUFG u_clk (.I(clk_ham),   .O(clk_tas));
`endif

    // ic reset: kilit yoksa reset; birakma tasarim saatinde senkron
    reg [1:0] rst_sr = 2'b11;
    always @(posedge clk_tas or posedge rst) begin
        if (rst) rst_sr <= 2'b11;
        else     rst_sr <= {rst_sr[0], ~locked};
    end
    wire rst_ic = rst_sr[1];

    bert_tiny_uart_ust #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_cekirdek (
        .clk(clk_tas), .rst(rst_ic), .uart_rx_pin(uart_rx_pin), .uart_tx_pin(uart_tx_pin));
endmodule
