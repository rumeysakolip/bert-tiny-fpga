## Basys3 (XC7A35T-1CPG236) -- hizlandirici_uart_ust icin kisitlar
## Pin atamalari Digilent Basys3 master XDC'den; KARTTA DENENMEDI, okulda dogrulanmali.
set_property -dict { PACKAGE_PIN W5  IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 6.667 -waveform {0 3.3335} [get_ports clk]
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports rst]          ;# btnC (aktif-yuksek reset)
set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } [get_ports uart_rx_pin]  ;# RsRx (USB-UART, FPGA girisi)
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports uart_tx_pin]  ;# RsTx (USB-UART, FPGA cikisi)
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## Giris/cikis zamanlama kisitlari (Konu 7a). Uc port da saatle ESZAMANSIZ oldugundan set_false_path kullanilir;
## set_input_delay/set_output_delay icin kart devresinden kaynakli bir gecikme degeri kaydedilmedigi icin deger uydurulmadi.
## rx: uart_alici.v girisi 2 flip-flop ile senkronlar (senkron[1:0]); UART hizi saatten bagimsiz, kaynak FT2232H.
set_false_path -from [get_ports uart_rx_pin]
## tx: uart_verici.v cikisi saat kenarinda yazmactan cikar; alici (FT2232H) kendi orneklemesiyle eszamansiz okur.
set_false_path -to [get_ports uart_tx_pin]
## rst: btnC dugmesi eszamansiz; bert_tiny_uart_ust.v icindeki 2 kademeli reset senkronlayicisina girer (basma eszamansiz, birakma saatle hizali).
set_false_path -from [get_ports rst]

