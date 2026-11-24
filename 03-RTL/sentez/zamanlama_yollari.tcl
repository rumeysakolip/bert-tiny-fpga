# Yonlendirilmis checkpoint'ten en kotu setup yollarini (ve hold ozetini) rapora yazar. cwd: 03-RTL
# Kullanim: vivado -mode batch -source sentez/zamanlama_yollari.tcl -tclargs <checkpoint.dcp> <cikti_on_eki> [yol_sayisi]
#   Ciktilar: <on_ek>_yollar.txt (setup, en kotu N yol), <on_ek>_ozet.txt (WNS/WHS ozeti)
set dcp [lindex $argv 0]
set on  [lindex $argv 1]
set n   [lindex $argv 2]
if {$n eq ""} { set n 20 }
open_checkpoint $dcp
report_timing -delay_type max -max_paths $n -sort_by slack -file ${on}_yollar.txt
report_timing_summary -delay_type min_max -max_paths 1 -file ${on}_ozet.txt
puts "ZAMANLAMA YOLLARI BITTI: $on"
