# kart_mantik'in sentez sonrasi islevsel benzetim agi (BOL=1: flas daha hizli, hesap ayni)
set part xc7a35tcpg236-1
set kok [pwd]
set rtl3 $kok/../03-RTL/rtl
foreach f {ters_bolucu seri_bolucu cift_kapili_bellek cikis_sozcuk_toplayici panel_tamponu tile_denetleyici gelu_tablosu sistolik_dizi islem_elemani} { read_verilog $rtl3/$f.v }
foreach f {kart_mantik ikili_bcd qspi_okuyucu ortak_ust cizelge_ortak akis_ayristirici ortak_cekirdek ek_hat yaz_fifo agirlik_rom_banka birlesik_bellek_2o artik_ln_ortak yeniden_olcekle_ortak
           layernorm_birim_dz panel_kopyalayici panel_parametre_yukleyici parametre_rom gelu_yukleyici cikis_sozcuk_toplayici_devrik softmax_birim_gomulu} { read_verilog $kok/rtl/$f.v }
cd $kok/rtl
synth_design -top kart_mantik -part $part -flatten_hierarchy rebuilt -mode out_of_context -generic BOL=1
write_verilog -mode funcsim -force $kok/sim/net/kart_mantik_net.v
puts "NETLIST_BITTI"
