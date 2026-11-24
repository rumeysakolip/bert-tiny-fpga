# Tam implementasyon (yerlestirme + yonlendirme), saat periyodu parametreli. cwd: 03-RTL
# Kullanim: vivado -mode batch -source sentez/impl_periyot.tcl -tclargs <ust_modul> <periyot_ns> <etiket> [bitstream: 1|0] ["GEN=DEGER ..."]
#   Dosyalar: rtl/*.v (otomatik). MMCM'li ust modulde periyot = GIRIS saati (10.0); tasarim saati MMCM'den turetilir.
#   Saat kisiti: basys3.xdc'deki create_clock periyodu gecici bir kopyada degistirilir (sentez/cikti/<etiket>.xdc).
#   Ciktilar: sentez/cikti/<etiket>_kullanim.txt, _zamanlama.txt, _yollar.txt (en kotu 20 setup yolu), _routed.dcp
#   Kisit durumu: rx, rst giris gecikmeleri ve tx cikis gecikmesi XDC'de TANIMLI DEGIL (check_timing: no_input_delay/no_output_delay).
set ust [lindex $argv 0]
set per [lindex $argv 1]
set etiket [lindex $argv 2]
set bit [lindex $argv 3]
if {$bit eq ""} { set bit 0 }
set gen [lindex $argv 4]               ;# ornek: "MMCM_CARPAN_X8=80 MMCM_BOLEN_X8=64 CLKS_PER_BIT=136"
set gen_args {}
foreach g $gen { lappend gen_args -generic $g }
set part xc7a35tcpg236-1
set yari [expr {$per / 2.0}]
file mkdir sentez/cikti
# periyodu degistirilmis XDC
set f [open sentez/basys3.xdc r]
set metin [read $f]
close $f
regsub {create_clock -add -name sys_clk_pin -period [0-9.]+ -waveform \{0 [0-9.]+\}} $metin "create_clock -add -name sys_clk_pin -period $per -waveform {0 $yari}" yeni
set f [open sentez/cikti/${etiket}.xdc w]
puts $f $yeni
close $f
foreach d [glob rtl/*.v] { read_verilog $d }
read_xdc sentez/cikti/${etiket}.xdc
synth_design -top $ust -part $part -flatten_hierarchy rebuilt {*}$gen_args
opt_design
place_design
phys_opt_design
route_design
report_utilization -file sentez/cikti/${etiket}_kullanim.txt
report_utilization -hierarchical -file sentez/cikti/${etiket}_kullanim_hiyerarsik.txt
report_timing_summary -delay_type min_max -max_paths 5 -file sentez/cikti/${etiket}_zamanlama.txt
report_timing -delay_type max -max_paths 20 -sort_by slack -file sentez/cikti/${etiket}_yollar.txt
report_clock_utilization -file sentez/cikti/${etiket}_saat.txt
report_route_status -file sentez/cikti/${etiket}_rota.txt
write_checkpoint -force sentez/cikti/${etiket}_routed.dcp
if {$bit} { write_bitstream -force sentez/cikti/${etiket}.bit }
puts "IMPL PERIYOT BITTI: $ust $per ns $etiket"
