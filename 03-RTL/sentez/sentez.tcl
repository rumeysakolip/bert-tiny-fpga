# Vivado sentez (yalnizca synth_design; yerlestirme/yonlendirme yok) -- G12
# Kullanim:  vivado -mode batch -source sentez/sentez.tcl -tclargs <ust_modul>   (cwd: 03-RTL)
set ust [lindex $argv 0]
if {$ust eq ""} { set ust hizlandirici_uart_ust }
set part xc7a35tcpg236-1
set dosyalar {pe systolic_nxn bram_sdp panel_tamponu tile_denetleyici yeniden_olcekle gelu_lut cikis_paketle dogrusal_katman komut_cozucu uart_rx uart_tx hizlandirici_ust hizlandirici_uart_ust}
foreach f $dosyalar { read_verilog rtl/$f.v }
read_xdc sentez/basys3.xdc
file mkdir sentez/cikti
synth_design -top $ust -part $part -flatten_hierarchy rebuilt
report_utilization -file sentez/cikti/${ust}_kullanim.txt
report_utilization -hierarchical -file sentez/cikti/${ust}_kullanim_hiyerarsik.txt
report_timing_summary -delay_type max -max_paths 3 -file sentez/cikti/${ust}_zamanlama.txt
report_drc -file sentez/cikti/${ust}_drc.txt
write_checkpoint -force sentez/cikti/${ust}_synth.dcp
puts "SENTEZ BITTI: $ust"
