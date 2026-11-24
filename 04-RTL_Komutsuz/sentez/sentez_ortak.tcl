# ortak_cekirdek ek_hat yaz_fifo agirlik_rom_banka artik_ln_par sentezi (tek dizi + tek yeniden olcekleme + 48 KB bellek + Softmax + LayerNorm), 100 MHz, baglamsiz kip
# Kullanim (cwd: 04-RTL_Komutsuz):  vivado -mode batch -source sentez/sentez_ortak.tcl
set part xc7a35tcpg236-1
set kok [pwd]
set rtl3 $kok/../03-RTL/rtl
foreach f {ters_bolucu seri_bolucu cift_kapili_bellek cikis_sozcuk_toplayici panel_tamponu tile_denetleyici gelu_tablosu sistolik_dizi islem_elemani} { read_verilog $rtl3/$f.v }
foreach f {ortak_cekirdek birlesik_bellek_2o artik_ln_ortak yeniden_olcekle_ortak layernorm_birim_dz panel_kopyalayici panel_parametre_yukleyici parametre_rom gelu_yukleyici cikis_sozcuk_toplayici_devrik softmax_birim_gomulu} { read_verilog $kok/rtl/$f.v }
set_property include_dirs [list $kok/rtl] [current_fileset]
set xdc $kok/sentez/saat_100mhz.xdc
set fp [open $xdc w]; puts $fp "create_clock -period 10.000 -name clk \[get_ports clk\]"; close $fp
read_xdc $xdc
file mkdir $kok/sentez/cikti
cd $kok/rtl
synth_design -top ortak_cekirdek -part $part -mode out_of_context -flatten_hierarchy rebuilt -include_dirs [list $kok/rtl]
report_utilization -file $kok/sentez/cikti/ortak_sentez_kullanim.txt
report_utilization -hierarchical -file $kok/sentez/cikti/ortak_sentez_hiyerarsik.txt
opt_design
place_design
route_design
report_utilization -file $kok/sentez/cikti/ortak_impl_kullanim.txt
report_timing_summary -delay_type min_max -max_paths 5 -file $kok/sentez/cikti/ortak_impl_zamanlama.txt
puts "SENTEZ_BITTI"
