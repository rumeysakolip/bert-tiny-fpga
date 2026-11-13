# Tam implementasyon (yerlestirme + yonlendirme) + bitstream.  cwd: 03-RTL
# Kullanim: vivado -mode batch -source sentez/impl.tcl -tclargs <ust_modul> [bitstream: 1|0]
#   <ust_modul>: bert_tiny_uart_ust (varsayilan)
#   Yeni top ciktilari: sentez/cikti/<ust>_impl_*.txt, <ust>_impl_routed.dcp, <ust>.bit  (eski impl_* dosyalarinin ustune yazilmaz)
set ust [lindex $argv 0]
if {$ust eq ""} { set ust bert_tiny_uart_ust }
set bit [lindex $argv 1]
set on ${ust}_impl
if {$bit eq ""} { set bit 1 }
set part xc7a35tcpg236-1
foreach f {islem_elemani sistolik_dizi cift_kapili_bellek panel_tamponu tile_denetleyici yeniden_olcekle gelu_tablosu cikis_sozcuk_toplayici dogrusal_katman
           seri_bolucu ters_bolucu softmax_birim layernorm_birim sonuc_tamponu
           komut_cozucu kontrol_birimi veri_yolu uart_alici uart_verici bert_tiny_ust bert_tiny_uart_ust} { read_verilog rtl/$f.v }
read_xdc sentez/basys3.xdc
file mkdir sentez/cikti
synth_design -top $ust -part $part -flatten_hierarchy rebuilt
opt_design
place_design
phys_opt_design
route_design
report_utilization -file sentez/cikti/${on}_kullanim.txt
report_utilization -hierarchical -file sentez/cikti/${on}_kullanim_hiyerarsik.txt
report_timing_summary -delay_type min_max -max_paths 5 -file sentez/cikti/${on}_zamanlama.txt
report_clock_utilization -file sentez/cikti/${on}_saat.txt
report_power -file sentez/cikti/${on}_guc.txt
report_route_status -file sentez/cikti/${on}_rota.txt
report_drc -file sentez/cikti/${on}_drc.txt
write_checkpoint -force sentez/cikti/${on}_routed.dcp
if {$bit} {
    write_bitstream -force sentez/cikti/${ust}.bit
    puts "BITSTREAM YAZILDI: sentez/cikti/${ust}.bit"
}
puts "IMPL BITTI: $ust"
