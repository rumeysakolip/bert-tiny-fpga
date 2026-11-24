# G20: dizi boyutu deneyi -- yalnizca sistolik_dizi (N x N PE), out_of_context, 100 MHz.  cwd: 03-RTL
# Kullanim: vivado -mode batch -source sentez/g20_dizi.tcl -tclargs <N>
set n [lindex $argv 0]
set part xc7a35tcpg236-1
file mkdir sentez/cikti
read_verilog rtl/islem_elemani.v
read_verilog rtl/sistolik_dizi.v
synth_design -top sistolik_dizi -part $part -mode out_of_context -flatten_hierarchy rebuilt -generic DIZI_BOYUTU=$n
create_clock -period 10.0 [get_ports clk]
report_utilization -file sentez/cikti/g20_n${n}_sentez_kullanim.txt
report_timing_summary -delay_type max -max_paths 1 -file sentez/cikti/g20_n${n}_sentez_zamanlama.txt
if {[catch {
    opt_design
    place_design
    route_design
    report_utilization -file sentez/cikti/g20_n${n}_impl_kullanim.txt
    report_timing_summary -delay_type max -max_paths 1 -file sentez/cikti/g20_n${n}_impl_zamanlama.txt
} hata]} { puts "IMPL HATA N=$n: $hata" ; set f [open sentez/cikti/g20_n${n}_impl_hata.txt w]; puts $f $hata; close $f }
puts "G20 BITTI N=$n"
