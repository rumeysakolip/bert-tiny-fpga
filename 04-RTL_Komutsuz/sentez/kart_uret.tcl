# Basys 3 icin tam akis: sentez -> yerlestirme -> yonlendirme -> bit dosyasi -> flas goruntuleri
# Kullanim (cwd: 04-RTL_Komutsuz):  vivado -mode batch -source sentez/kart_uret.tcl
set part xc7a35tcpg236-1
set kok [pwd]
set rtl3 $kok/../03-RTL/rtl
set cikti $kok/sentez/cikti_kart
file mkdir $cikti
foreach f {ters_bolucu seri_bolucu cift_kapili_bellek cikis_sozcuk_toplayici panel_tamponu tile_denetleyici gelu_tablosu sistolik_dizi islem_elemani} { read_verilog $rtl3/$f.v }
foreach f {kart_ust kart_mantik ikili_bcd qspi_okuyucu ortak_ust cizelge_ortak akis_ayristirici ortak_cekirdek ek_hat yaz_fifo agirlik_rom_banka artik_ln_par birlesik_bellek_2o artik_ln_ortak yeniden_olcekle_ortak
           layernorm_birim_dz panel_kopyalayici panel_parametre_yukleyici parametre_rom gelu_yukleyici cikis_sozcuk_toplayici_devrik softmax_birim_gomulu} { read_verilog $kok/rtl/$f.v }
read_xdc $kok/sentez/kart_basys3.xdc
cd $kok/rtl
synth_design -top kart_ust -part $part -flatten_hierarchy rebuilt
write_checkpoint -force $cikti/kart_sentez.dcp
report_utilization -file $cikti/sentez_kullanim.txt
opt_design
place_design
phys_opt_design
route_design
write_checkpoint -force $cikti/kart_yerlesik.dcp
report_utilization -file $cikti/impl_kullanim.txt
report_timing_summary -delay_type min_max -max_paths 10 -file $cikti/impl_zamanlama.txt
report_drc -file $cikti/impl_drc.txt
report_io -file $cikti/impl_io.txt
report_clock_utilization -file $cikti/impl_saat.txt
write_bitstream -force $cikti/kart_ust.bit
# flas goruntuleri: (1) yalniz akis verisi, (2) bit dosyasi + akis verisi (karti kendi kendine acilir)
write_cfgmem -force -format mcs -interface SPIx4 -size 4 -loaddata "up 0x00240000 $kok/vektor_akis/akis_katman2.bin" -file $cikti/kart_akis.mcs
write_cfgmem -force -format mcs -interface SPIx4 -size 4 -loadbit "up 0x00000000 $cikti/kart_ust.bit" -loaddata "up 0x00240000 $kok/vektor_akis/akis_katman2.bin" -file $cikti/kart_tam.mcs
puts "KART_URET_BITTI"
