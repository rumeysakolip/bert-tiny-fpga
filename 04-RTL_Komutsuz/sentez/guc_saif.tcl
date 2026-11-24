# Yerlestirilmis ortak_ust uzerinde benzetimden gelen etkinlik dosyasiyla (SAIF) guc cozumlemesi
# Kullanim (cwd: 04-RTL_Komutsuz):  vivado -mode batch -source sentez/guc_saif.tcl
set kok [pwd]
open_checkpoint $kok/sentez/cikti_guc/ortak_ust_yerlesik.dcp
read_saif -strip_path tb_ortak_ust/dut -out_file $kok/sentez/cikti_guc/saif_okuma.txt $kok/sim/xs_saif/ortak_ust.saif
report_power -file $kok/sentez/cikti_guc/guc_saif.txt
report_power -hierarchical_depth 3 -file $kok/sentez/cikti_guc/guc_saif_hiyerarsi.txt
puts "GUC_SAIF_BITTI"
