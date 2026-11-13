# Konu 5: LayerNorm birimi, bagimsiz (out_of_context) sentez, G (kesir biti) parametresi ile. cwd: 03-RTL
# Kullanim: vivado -mode batch -source sentez/konu5_sentez.tcl -tclargs <G> [periyot_ns]
#   Ciktilar: sentez/cikti/konu5_g<G>_layernorm_birim_kullanim.txt / _zamanlama.txt
# Yalniz sentez: yerlestirme/yonlendirme yok, WNS sentez tahminidir. G=16 surumu benzetimde dogrulanmadi (yalniz alan/zamanlama verisi).
set g [lindex $argv 0]
if {$g eq ""} { set g 12 }
set per [lindex $argv 1]
if {$per eq ""} { set per 10.0 }
file mkdir sentez/cikti
read_verilog rtl/seri_bolucu.v
read_verilog rtl/ters_bolucu.v
read_verilog rtl/layernorm_birim.v
synth_design -top layernorm_birim -part xc7a35tcpg236-1 -mode out_of_context -flatten_hierarchy rebuilt -generic KESIR_BITI=$g
create_clock -period $per [get_ports clk]
report_utilization -file sentez/cikti/konu5_g${g}_layernorm_birim_kullanim.txt
report_timing_summary -delay_type max -max_paths 3 -file sentez/cikti/konu5_g${g}_layernorm_birim_zamanlama.txt
puts "KONU5 SENTEZ BITTI: G=$g"
