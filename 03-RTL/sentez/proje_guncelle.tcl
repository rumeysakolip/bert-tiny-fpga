# Vivado projesini G13 ve hizlandirma (ters_bolucu) dosyalariyla gunceller: yeni dosyalari ekler, degisenleri yeniler, ust modulu ve simulasyon top'unu ayarlar.
# Proje dosyalari 03-RTL'e yol ile bagli (kopyalanmaz); degisen dosyalar bu yuzden zaten gunceldir, burada yalniz yenilenir.
# Kullanim (Vivado GUI'de proje acikken Tcl Console'a):
#   source C:/Users/rumey/Documents/biitirme-projem/03-RTL/sentez/proje_guncelle.tcl
# veya komut satirindan:
#   vivado -mode batch -source C:/Users/rumey/Documents/biitirme-projem/03-RTL/sentez/proje_guncelle.tcl
set rtl_kok "C:/Users/rumey/Documents/biitirme-projem/03-RTL"
set xpr "C:/Users/rumey/Documents/Vivado-files/bitirme_bert_tiny/bitirme_bert_tiny.xpr"
if {[llength [get_projects -quiet]] == 0} { open_project $xpr }

# 0) Artik diskte olmayan (yeniden adlandirilan/silinen) dosyalari projeden cikar
foreach fs {sources_1 sim_1} {
    foreach f [get_files -quiet -of_objects [get_filesets $fs]] {
        if {![file exists $f]} { remove_files -fileset $fs $f; puts "CIKARILDI ($fs): $f" }
    }
}
# 1) rtl/ altindaki tum tasarim kaynaklari (zaten ekliyse atlanir). bert_tiny_mmcm_ust yalniz kart saati icindir, projeye eklenmez.
foreach yol [glob $rtl_kok/rtl/*.v] {
    if {[file rootname [file tail $yol]] eq "bert_tiny_mmcm_ust"} { continue }
    if {[llength [get_files -quiet $yol]] == 0} {
        add_files -norecurse -fileset sources_1 $yol
        puts "EKLENDI: $yol"
    }
}
# 2) Yeni testbench
set tb "$rtl_kok/tb/tb_bert_tiny_ust.v"
if {[llength [get_files -quiet $tb]] == 0} { add_files -norecurse -fileset sim_1 $tb; puts "EKLENDI: $tb" }

# 3) Vektor dosyalari (.mem): xsim calisma klasorune kopyalanir, tb '.' yedegiyle bulur
foreach m [glob -nocomplain $rtl_kok/tb/vektor_g11/*.mem] {
    if {[llength [get_files -quiet $m]] == 0} { add_files -norecurse -fileset sim_1 $m }
}

# 3b) Kisit dosyasi (saat 100 MHz + pinler). Projede constrs_1 bos oldugunda zamanlama "NA", guc ve metodoloji anlamsiz cikar.
set xdc "$rtl_kok/sentez/basys3.xdc"
if {[llength [get_files -quiet $xdc]] == 0} {
    add_files -norecurse -fileset constrs_1 $xdc
    puts "EKLENDI: $xdc"
}

# 4) Ust modul ve simulasyon top'u
set_property top bert_tiny_uart_ust [get_filesets sources_1]
set_property top tb_bert_tiny_ust [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# 5) Degisen dosyalar (komut_cozucu, kontrol_birimi, veri_yolu, tb_hizlandirici ...) disktekiyle yenilenir
catch {reset_target all [get_files -quiet *.v]}
foreach r {synth_1 impl_1} { catch {reset_run $r} }
puts "PROJE GUNCELLENDI: top=bert_tiny_uart_ust, sim top=tb_bert_tiny_ust"
