# Konu 4: Softmax ve LayerNorm birimleri, bagimsiz (out_of_context) sentez. cwd: 03-RTL
# Kullanim: vivado -mode batch -source sentez/konu4_sentez.tcl -tclargs <etiket> [periyot_ns]
#   Ciktilar: sentez/cikti/konu4_<etiket>_<birim>_kullanim.txt / _zamanlama.txt  (eski g11 raporlarinin ustune yazilmaz)
# Yalniz sentez: yerlestirme/yonlendirme yok, WNS sentez tahminidir.
set etiket [lindex $argv 0]
if {$etiket eq ""} { set etiket deneme }
set per [lindex $argv 1]
if {$per eq ""} { set per 10.0 }
set part xc7a35tcpg236-1
file mkdir sentez/cikti
foreach ust {softmax_birim layernorm_birim} {
    read_verilog rtl/seri_bolucu.v
    read_verilog rtl/ters_bolucu.v
    read_verilog rtl/$ust.v
    synth_design -top $ust -part $part -mode out_of_context -flatten_hierarchy rebuilt
    create_clock -period $per [get_ports clk]
    report_utilization -file sentez/cikti/konu4_${etiket}_${ust}_kullanim.txt
    report_timing_summary -delay_type max -max_paths 3 -file sentez/cikti/konu4_${etiket}_${ust}_zamanlama.txt
    close_design
    remove_files [get_files]
}
puts "KONU4 SENTEZ BITTI: $etiket"
