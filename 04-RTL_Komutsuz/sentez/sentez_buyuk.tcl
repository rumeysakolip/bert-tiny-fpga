# Buyuk FPGA (XC7A200T) icin ortak_ust sentezi + yerlestirme: NA paralel dogrusal hat, agirlik ROM, paralel LayerNorm ve Softmax.
# Kullanim (cwd: 04-RTL_Komutsuz):  vivado -mode batch -source sentez/sentez_buyuk.tcl -tclargs <NA> <saat_ns> <etiket> [parca] [LN_PAR] [SMP] [ATTP]
#   ornek: vivado -mode batch -source sentez/sentez_buyuk.tcl -tclargs 8 10.0 na8 xc7a200tfbg676-2 1 1 1
# Onkosul: python scripts/uret_agirlik_rom.py <NA>  (vektor_rom/na<NA>/ ) 
set na   [lindex $argv 0]
set per  [lindex $argv 1]
set tag  [lindex $argv 2]
set part [lindex $argv 3]
set lnp  [lindex $argv 4]
set smp  [lindex $argv 5]
set attp [lindex $argv 6]
if {$part eq ""} { set part xc7a200tfbg676-2 }
if {$lnp eq ""} { set lnp 1 }
if {$smp eq ""} { set smp 1 }
if {$attp eq ""} { set attp 0 }
if {$na eq ""} { set na 8 }
if {$per eq ""} { set per 10.0 }
if {$tag eq ""} { set tag na$na }
set kok [pwd]
set rtl3 $kok/../03-RTL/rtl
set rd [file normalize $kok/sentez/buyuk_$tag]
file mkdir $rd
foreach f [glob $kok/rtl/*.mem] { file copy -force $f $rd }
foreach f [glob $kok/vektor_rom/na$na/*.mem] { file copy -force $f $rd }
set fp [open $kok/vektor_rom/na$na/agirlik_rom_b0.mem r]; set romd 0; while {[gets $fp l] >= 0} { incr romd }; close $fp
foreach f {ters_bolucu seri_bolucu cift_kapili_bellek cikis_sozcuk_toplayici panel_tamponu tile_denetleyici gelu_tablosu sistolik_dizi islem_elemani} { read_verilog $rtl3/$f.v }
foreach f {ortak_ust cizelge_ortak akis_ayristirici ortak_cekirdek ek_hat yaz_fifo agirlik_rom_banka artik_ln_par birlesik_bellek_2o artik_ln_ortak yeniden_olcekle_ortak layernorm_birim_dz panel_kopyalayici panel_parametre_yukleyici parametre_rom gelu_yukleyici cikis_sozcuk_toplayici_devrik softmax_birim_gomulu} { read_verilog $kok/rtl/$f.v }
set_property include_dirs [list $kok/rtl] [current_fileset]
set xdc $rd/saat.xdc
set f [open $xdc w]; puts $f "create_clock -period $per -name clk \[get_ports clk\]"; close $f
read_xdc $xdc
cd $rd
synth_design -top ortak_ust -part $part -mode out_of_context -flatten_hierarchy rebuilt -include_dirs [list $kok/rtl] \
    -generic NA=$na -generic AGIRLIK_ROM=1 -generic ROM_D=$romd -generic LN_PAR=$lnp -generic SMP=$smp -generic ATTP=$attp -generic KATMAN_ISLEM=2
report_utilization -file $rd/sentez_kullanim.txt
opt_design
place_design
route_design
report_utilization -file $rd/impl_kullanim.txt
report_timing_summary -delay_type min_max -max_paths 5 -file $rd/impl_zamanlama.txt
puts "SENTEZ_BITTI $tag $part"
