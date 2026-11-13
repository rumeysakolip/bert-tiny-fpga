## Basys3 (XC7A35T-1CPG236) -- hizlandirici_uart_ust icin kisitlar
## Pin atamalari Digilent Basys3 master XDC'den; KARTTA DENENMEDI, okulda dogrulanmali.
set_property -dict { PACKAGE_PIN W5  IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 5.71 -waveform {0 2.855} [get_ports clk]
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports rst]          ;# btnC (aktif-yuksek reset)
set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } [get_ports uart_rx_pin]  ;# RsRx (USB-UART, FPGA girisi)
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports uart_tx_pin]  ;# RsTx (USB-UART, FPGA cikisi)
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

