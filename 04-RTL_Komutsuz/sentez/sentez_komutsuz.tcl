# Komutsuz prototip: sentez + yerlestirme-yonlendirme (disaridan baglamsiz kip -- pin atamasi yok), 100 MHz
# Kullanim (cwd: 04-RTL_Komutsuz):  vivado -mode batch -source sentez/sentez_komutsuz.tcl -tclargs <ust: komutsuz_ust | komutsuz_flas_ust>
set ust [lindex $argv 0]
if {$ust eq ""} { set ust komutsuz_ust }
set part xc7a35tcpg236-1
set rtl3 ../03-RTL/rtl
foreach f {islem_elemani sistolik_dizi cift_kapili_bellek panel_tamponu tile_denetleyici yeniden_olcekle gelu_tablosu cikis_sozcuk_toplayici dogrusal_katman} { read_verilog $rtl3/$f.v }
foreach f {akis_ayristirici cizelge_siralayici komutsuz_ust qspi_okuyucu komutsuz_flas_ust} { read_verilog rtl/$f.v }
set xdc sentez/saat_100mhz.xdc
set fp [open $xdc w]; puts $fp "create_clock -period 10.000 -name clk \[get_ports clk\]"; close $fp
read_xdc $xdc
file mkdir sentez/cikti
synth_design -top $ust -part $part -mode out_of_context -flatten_hierarchy rebuilt
report_utilization -file sentez/cikti/${ust}_sentez_kullanim.txt
report_utilization -hierarchical -file sentez/cikti/${ust}_sentez_kullanim_hiyerarsik.txt
opt_design
place_design
route_design
report_utilization -file sentez/cikti/${ust}_impl_kullanim.txt
report_timing_summary -delay_type min_max -max_paths 5 -file sentez/cikti/${ust}_impl_zamanlama.txt
report_drc -file sentez/cikti/${ust}_impl_drc.txt
puts "SENTEZ_BITTI"
