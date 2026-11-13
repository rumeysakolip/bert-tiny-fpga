# artik_ln_blogu sentezi (LayerNorm + tek yeniden olcekleme devresi), 100 MHz, baglamsiz kip
# Kullanim (cwd: 04-RTL_Komutsuz):  vivado -mode batch -source sentez/sentez_artik_ln.tcl
set part xc7a35tcpg236-1
set kok [pwd]
set rtl3 $kok/../03-RTL/rtl
foreach f {ters_bolucu seri_bolucu} { read_verilog $rtl3/$f.v }
foreach f {layernorm_birim_dz yeniden_olcekle_ortak artik_ln_blogu} { read_verilog $kok/rtl/$f.v }
set_property include_dirs [list $kok/rtl] [current_fileset]
set xdc $kok/sentez/saat_100mhz.xdc
set fp [open $xdc w]; puts $fp "create_clock -period 10.000 -name clk \[get_ports clk\]"; close $fp
read_xdc $xdc
file mkdir $kok/sentez/cikti
cd $kok/rtl
synth_design -top artik_ln_blogu -part $part -mode out_of_context -flatten_hierarchy rebuilt -include_dirs [list $kok/rtl]
report_utilization -file $kok/sentez/cikti/artik_ln_sentez_kullanim.txt
report_utilization -hierarchical -file $kok/sentez/cikti/artik_ln_sentez_hiyerarsik.txt
opt_design
place_design
route_design
report_utilization -file $kok/sentez/cikti/artik_ln_impl_kullanim.txt
report_timing_summary -delay_type min_max -max_paths 5 -file $kok/sentez/cikti/artik_ln_impl_zamanlama.txt
puts "SENTEZ_BITTI"
