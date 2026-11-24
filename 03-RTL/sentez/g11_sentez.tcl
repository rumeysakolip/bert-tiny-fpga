# G11 birimleri: bagimsiz (out_of_context) sentez, 100 MHz.  cwd: 03-RTL
set part xc7a35tcpg236-1
file mkdir sentez/cikti
foreach {ust dosya} {softmax_birim softmax_birim layernorm_birim layernorm_birim} {
    read_verilog rtl/seri_bolucu.v
    read_verilog rtl/$dosya.v
    synth_design -top $ust -part $part -mode out_of_context -flatten_hierarchy rebuilt
    create_clock -period 10.0 [get_ports clk]
    report_utilization -file sentez/cikti/${ust}_kullanim.txt
    report_timing_summary -delay_type max -max_paths 1 -file sentez/cikti/${ust}_zamanlama.txt
    close_design
    remove_files [get_files]
}
puts "G11 SENTEZ BITTI"
