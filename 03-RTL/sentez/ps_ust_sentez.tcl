# Tam sistem (bert_tiny_uart_ust) icin sentez sonrasi ve yerlestirme-yonlendirme sonrasi ag listeleri. cwd: 03-RTL
# Kullanim: vivado -mode batch -source sentez/ps_ust_sentez.tcl -tclargs <yonlendirilmis.dcp>
#   1) sentez sonrasi islevsel ag listesi: sim/postsynth_ust/ust_ps_islevsel.v
#   2) yonlendirme sonrasi zamanlamali ag listesi + SDF: sim/postsynth_ust/ust_pr_zaman.v, ust_pr_zaman.sdf
set dcp [lindex $argv 0]
file mkdir sim/postsynth_ust
foreach d [glob rtl/*.v] { if {![string match *mmcm* $d]} { read_verilog $d } }
read_xdc sentez/basys3.xdc
synth_design -top bert_tiny_uart_ust -part xc7a35tcpg236-1 -flatten_hierarchy rebuilt
write_verilog -mode funcsim -force sim/postsynth_ust/ust_ps_islevsel.v
report_utilization -file sim/postsynth_ust/ust_ps_kullanim.txt
close_design
open_checkpoint $dcp
write_verilog -mode timesim -force sim/postsynth_ust/ust_pr_zaman.v
write_sdf -force sim/postsynth_ust/ust_pr_zaman.sdf
puts "PS UST BITTI"
