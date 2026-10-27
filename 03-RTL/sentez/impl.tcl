# Tam implementasyon (yerlestirme + yonlendirme), bitstream YOK.  cwd: 03-RTL
# Kullanim: vivado -mode batch -source sentez/impl.tcl
set ust hizlandirici_uart_ust
set part xc7a35tcpg236-1
foreach f {pe systolic_nxn bram_sdp panel_tamponu tile_denetleyici yeniden_olcekle gelu_lut cikis_paketle dogrusal_katman komut_cozucu uart_rx uart_tx hizlandirici_ust hizlandirici_uart_ust} { read_verilog rtl/$f.v }
read_xdc sentez/basys3.xdc
file mkdir sentez/cikti
synth_design -top $ust -part $part -flatten_hierarchy rebuilt
opt_design
place_design
phys_opt_design
route_design
report_utilization -file sentez/cikti/impl_kullanim.txt
report_timing_summary -delay_type min_max -max_paths 5 -file sentez/cikti/impl_zamanlama.txt
report_clock_utilization -file sentez/cikti/impl_saat.txt
report_power -file sentez/cikti/impl_guc.txt
report_route_status -file sentez/cikti/impl_rota.txt
write_checkpoint -force sentez/cikti/impl_routed.dcp
puts "IMPL BITTI"
