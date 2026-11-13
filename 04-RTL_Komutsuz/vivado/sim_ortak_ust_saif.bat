@echo off
rem Guc cozumlemesi icin etkinlik dosyasi (SAIF) uretir: tek cumle, bayt araligi 1 (tam hiz, hesap suresince en yogun etkinlik).
rem Kullanim: sim_ortak_ust_saif.bat   -> sim\xs_saif\ortak_ust.saif
set VIVADO=C:\Xilinx\2025.1\Vivado\bin
set RTL3=%~dp0..\..\03-RTL\rtl
set RTL4=%~dp0..\rtl
set TB=%~dp0..\tb
mkdir %~dp0..\sim\xs_saif 2> nul
cd /d %~dp0..\sim\xs_saif
copy /Y %RTL4%\*.mem . > nul
copy /Y %~dp0saif.tcl . > nul
call %VIVADO%\xvlog.bat %TB%\tb_ortak_ust.v %RTL4%\ortak_ust.v %RTL4%\cizelge_ortak.v %RTL4%\akis_ayristirici.v %RTL4%\ortak_cekirdek.v %RTL4%\birlesik_bellek_2o.v %RTL4%\artik_ln_ortak.v %RTL4%\yeniden_olcekle_ortak.v %RTL4%\layernorm_birim_dz.v %RTL4%\panel_kopyalayici.v %RTL4%\panel_parametre_yukleyici.v %RTL4%\parametre_rom.v %RTL4%\gelu_yukleyici.v %RTL4%\cikis_sozcuk_toplayici_devrik.v %RTL4%\softmax_birim_gomulu.v %RTL3%\ters_bolucu.v %RTL3%\seri_bolucu.v %RTL3%\cift_kapili_bellek.v %RTL3%\cikis_sozcuk_toplayici.v %RTL3%\panel_tamponu.v %RTL3%\tile_denetleyici.v %RTL3%\gelu_tablosu.v %RTL3%\sistolik_dizi.v %RTL3%\islem_elemani.v > cikti_xvlog.txt
call %VIVADO%\xelab.bat tb_ortak_ust -s saifsim -debug typical > cikti_xelab.txt
call %VIVADO%\xsim.bat saifsim -tclbatch saif.tcl -testplusarg "hizli=1" -testplusarg "aralik=1" -testplusarg "ns=1" > gunluk.txt
