# dogrusal_katman_gomulu (gomulu sabit parametreler) sentezi: bellek kullanimi ve zamanlama, 100 MHz, baglamsiz kip
# Kullanim (cwd: 04-RTL_Komutsuz):  vivado -mode batch -source sentez/sentez_param_gomulu.tcl
set part xc7a35tcpg236-1
set kok [pwd]
set rtl3 $kok/../03-RTL/rtl
foreach f {islem_elemani sistolik_dizi cift_kapili_bellek panel_tamponu tile_denetleyici yeniden_olcekle gelu_tablosu cikis_sozcuk_toplayici dogrusal_katman} { read_verilog $rtl3/$f.v }
foreach f {parametre_rom panel_parametre_yukleyici gelu_yukleyici dogrusal_katman_gomulu} { read_verilog $kok/rtl/$f.v }
set xdc $kok/sentez/saat_100mhz.xdc
set fp [open $xdc w]; puts $fp "create_clock -period 10.000 -name clk \[get_ports clk\]"; close $fp
read_xdc $xdc
file mkdir $kok/sentez/cikti
cd $kok/rtl                              ;# gomulu bellek dosyalari (param_bias.mem vb.) burada
synth_design -top dogrusal_katman_gomulu -part $part -mode out_of_context -flatten_hierarchy rebuilt
report_utilization -file $kok/sentez/cikti/param_gomulu_sentez_kullanim.txt
report_utilization -hierarchical -file $kok/sentez/cikti/param_gomulu_sentez_hiyerarsik.txt
opt_design
place_design
route_design
report_utilization -file $kok/sentez/cikti/param_gomulu_impl_kullanim.txt
report_timing_summary -delay_type min_max -max_paths 5 -file $kok/sentez/cikti/param_gomulu_impl_zamanlama.txt
puts "SENTEZ_BITTI"
