# bitirme_bert_tiny projesinin kaynaklarini eski tasarimdan (03-RTL) yeni komutsuz tasarima (04-RTL_Komutsuz) cevirir.
# Vivado acikken Tcl konsolundan: source C:/Users/rumey/Documents/biitirme-projem/04-RTL_Komutsuz/vivado/proje_kaynak_degistir.tcl
set kok "C:/Users/rumey/Documents/biitirme-projem"
set r4 "$kok/04-RTL_Komutsuz/rtl"
set r3 "$kok/03-RTL/rtl"
set tb "$kok/04-RTL_Komutsuz/tb"

# 1) eski dosyalari projeden cikar (diskten silinmez)
set eski [get_files -quiet -of_objects [get_filesets sources_1]]
if {[llength $eski] > 0} { remove_files $eski }
set eski [get_files -quiet -of_objects [get_filesets sim_1]]
if {[llength $eski] > 0} { remove_files $eski }
set eski [get_files -quiet -of_objects [get_filesets constrs_1]]
if {[llength $eski] > 0} { remove_files $eski }

# 2) yeni tasarim dosyalari
set yeni4 {kart_ust kart_mantik ikili_bcd qspi_okuyucu ortak_ust cizelge_ortak akis_ayristirici ortak_cekirdek birlesik_bellek_2o artik_ln_ortak yeniden_olcekle_ortak
           layernorm_birim_dz panel_kopyalayici panel_parametre_yukleyici parametre_rom gelu_yukleyici
           cikis_sozcuk_toplayici_devrik softmax_birim_gomulu}
set yeni3 {ters_bolucu seri_bolucu cift_kapili_bellek cikis_sozcuk_toplayici panel_tamponu tile_denetleyici gelu_tablosu sistolik_dizi islem_elemani}
foreach d $yeni4 { add_files -norecurse -fileset sources_1 "$r4/$d.v" }
foreach d $yeni3 { add_files -norecurse -fileset sources_1 "$r3/$d.v" }
add_files -norecurse -fileset sources_1 [glob "$r4/*.mem"]
add_files -norecurse -fileset constrs_1 "$kok/04-RTL_Komutsuz/sentez/kart_basys3.xdc"
set_property top kart_ust [get_filesets sources_1]

# 3) benzetim: parametresiz uctan uca test (ikinci benzetim: tb_kart = flas modeli + kart mantigi; Simulation Settings > Top module name ile secilir)
add_files -norecurse -fileset sim_1 [list "$tb/tb_ortak_ust.v" "$tb/tb_kart.v" "$tb/flas_modeli.v"]
set_property top tb_ortak_ust [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "TAMAM: kaynaklar yeni tasarima cevrildi. Sol panelde Run Simulation > Run Behavioral Simulation'a basabilirsin."
