# dikkat_cekirdegi sentezi (bellek, DSP, zamanlama), 100 MHz, baglamsiz kip
# Kullanim (cwd: 04-RTL_Komutsuz):  vivado -mode batch -source sentez/sentez_dikkat.tcl
set part xc7a35tcpg236-1
set kok [pwd]
set rtl3 $kok/../03-RTL/rtl
foreach f {islem_elemani sistolik_dizi cift_kapili_bellek panel_tamponu tile_denetleyici cikis_sozcuk_toplayici ters_bolucu seri_bolucu} { read_verilog $rtl3/$f.v }
foreach f {panel_kopyalayici yeniden_olcekle_ortak softmax_birim_gomulu dikkat_cekirdegi} { read_verilog $kok/rtl/$f.v }
set xdc $kok/sentez/saat_100mhz.xdc
set fp [open $xdc w]; puts $fp "create_clock -period 10.000 -name clk \[get_ports clk\]"; close $fp
read_xdc $xdc
file mkdir $kok/sentez/cikti
cd $kok/rtl
synth_design -top dikkat_cekirdegi -part $part -mode out_of_context -flatten_hierarchy rebuilt
report_utilization -file $kok/sentez/cikti/dikkat_sentez_kullanim.txt
report_utilization -hierarchical -file $kok/sentez/cikti/dikkat_sentez_hiyerarsik.txt
opt_design
place_design
route_design
report_utilization -file $kok/sentez/cikti/dikkat_impl_kullanim.txt
report_timing_summary -delay_type min_max -max_paths 5 -file $kok/sentez/cikti/dikkat_impl_zamanlama.txt
puts "SENTEZ_BITTI"
