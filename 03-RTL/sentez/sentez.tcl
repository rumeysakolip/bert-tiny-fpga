# Vivado sentez (yalnizca synth_design; yerlestirme/yonlendirme yok) -- G12, G13'te bert_tiny eklendi
# Kullanim:  vivado -mode batch -source sentez/sentez.tcl -tclargs <ust_modul>   (cwd: 03-RTL)
#   <ust_modul>: bert_tiny_uart_ust (varsayilan, tam sistem)  |  bert_tiny_ust ...
# Cikti adlari ust modul adini tasir (sentez/cikti/<ust>_*), bu yuzden iki ust modulun ciktilari birbirinin ustune yazilmaz.
set ust [lindex $argv 0]
if {$ust eq ""} { set ust bert_tiny_uart_ust }
set part xc7a35tcpg236-1
set dosyalar {islem_elemani sistolik_dizi cift_kapili_bellek panel_tamponu tile_denetleyici yeniden_olcekle gelu_tablosu cikis_sozcuk_toplayici dogrusal_katman
              seri_bolucu ters_bolucu softmax_birim layernorm_birim sonuc_tamponu
              komut_cozucu kontrol_birimi veri_yolu uart_alici uart_verici bert_tiny_ust bert_tiny_uart_ust}
foreach f $dosyalar { read_verilog rtl/$f.v }
read_xdc sentez/basys3.xdc
file mkdir sentez/cikti
synth_design -top $ust -part $part -flatten_hierarchy rebuilt
report_utilization -file sentez/cikti/${ust}_kullanim.txt
report_utilization -hierarchical -file sentez/cikti/${ust}_kullanim_hiyerarsik.txt
report_timing_summary -delay_type max -max_paths 3 -file sentez/cikti/${ust}_zamanlama.txt
report_drc -file sentez/cikti/${ust}_drc.txt
write_checkpoint -force sentez/cikti/${ust}_synth.dcp

# Birlesik sentez kontrolu: hicbir alt birim silinmemis olmali.
#  - u_cd/u_kat/u_sm/u_ln hiyerarsik kullanim raporunda gorunmeli
#  - u_smb/u_lnb (cikis tamponlari) -rebuilt- altinda ust module katilir; hucreleri netlistte bulunmali (bellek hucresi dahil)
if {[string match bert_tiny* $ust]} {
    set fp [open sentez/cikti/${ust}_kullanim_hiyerarsik.txt r]
    set rapor [read $fp]
    close $fp
    set eksik {}
    foreach b {u_cd u_kat u_sm u_ln} {
        if {[string first $b $rapor] < 0} { lappend eksik $b }
    }
    foreach b {u_smb u_lnb} {
        if {[llength [get_cells -hierarchical -filter "NAME =~ *$b/*"]] == 0} { lappend eksik $b }
    }
    if {[llength $eksik] > 0} {
        puts "HIYERARSI KONTROL: BASARISIZ, sentezde bulunmayan birimler: $eksik"
        error "birimler sentezde silindi: $eksik"
    }
    puts "HIYERARSI KONTROL: TAMAM (u_cd u_kat u_sm u_ln raporda; u_smb u_lnb hucreleri netlistte)"
}
puts "SENTEZ BITTI: $ust"
