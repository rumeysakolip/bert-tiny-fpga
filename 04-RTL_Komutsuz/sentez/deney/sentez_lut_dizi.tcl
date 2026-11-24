# DENEY: 8x8 LUT carpmali MAC dizisi, 100 ve 150 MHz. Kullanim (cwd: 04-RTL_Komutsuz): vivado -mode batch -source sentez/deney/sentez_lut_dizi.tcl
set part xc7a35tcpg236-1
set kok [pwd]
file mkdir $kok/sentez/deney/cikti
foreach {ad periyot} {100mhz 10.000 150mhz 6.667} {
    read_verilog $kok/sentez/deney/lut_dizi_deneme.v
    set xdc $kok/sentez/deney/cikti/saat_$ad.xdc
    set fp [open $xdc w]; puts $fp "create_clock -period $periyot -name clk \[get_ports clk\]"; close $fp
    read_xdc $xdc
    synth_design -top lut_dizi_deneme -part $part -mode out_of_context -flatten_hierarchy rebuilt
    opt_design
    place_design
    route_design
    report_utilization -file $kok/sentez/deney/cikti/lut_dizi_kullanim_$ad.txt
    report_timing_summary -delay_type min_max -max_paths 3 -file $kok/sentez/deney/cikti/lut_dizi_zamanlama_$ad.txt
    close_design
    reset_project
}
puts "DENEY_BITTI"
