@echo off
rem SAF HESAP SURESI olcumu (agirlik akisi beklenmez; HIZLI_OLCUM=1). Sonuclar anlamsizdir, yalniz cevrim sayilir.
rem Kullanim: sim_ortak_ust_saf_hesap.bat [HIZLI_OLCUM: 1 varsayilan; 0 = normal akis] [DOLGU_ATLA: 0 varsayilan (8 blok); 1 = nb blok] [akis dosyasi (istege bagli)] [cumle sayisi, varsayilan 1]
rem Ornek: sim_ortak_ust_saf_hesap.bat 1 1 C:/yol/akis_nb2.hex      -> sim\xs_saf_1_1\gunluk.txt
set VIVADO=C:\Xilinx\2025.1\Vivado\bin
set RTL3=%~dp0..\..\03-RTL\rtl
set RTL4=%~dp0..\rtl
set TB=%~dp0..\tb
set HO=%1
if "%HO%"=="" set HO=1
set DA=%2
if "%DA%"=="" set DA=0
set NS=%4
if "%NS%"=="" set NS=1
set AKIS=
if not "%3"=="" set AKIS=-testplusarg "akis=%3"
set DIZIN=%~dp0..\sim\xs_saf_%HO%_%DA%
mkdir %DIZIN% 2> nul
cd /d %DIZIN%
copy /Y %RTL4%\*.mem . > nul
call %VIVADO%\xvlog.bat -i %RTL4% %TB%\tb_ortak_ust.v %RTL4%\ortak_ust.v %RTL4%\cizelge_ortak.v %RTL4%\akis_ayristirici.v %RTL4%\ortak_cekirdek.v %RTL4%\birlesik_bellek_2o.v %RTL4%\artik_ln_ortak.v %RTL4%\yeniden_olcekle_ortak.v %RTL4%\layernorm_birim_dz.v %RTL4%\panel_kopyalayici.v %RTL4%\panel_parametre_yukleyici.v %RTL4%\parametre_rom.v %RTL4%\gelu_yukleyici.v %RTL4%\cikis_sozcuk_toplayici_devrik.v %RTL4%\softmax_birim_gomulu.v %RTL3%\ters_bolucu.v %RTL3%\seri_bolucu.v %RTL3%\cift_kapili_bellek.v %RTL3%\cikis_sozcuk_toplayici.v %RTL3%\panel_tamponu.v %RTL3%\tile_denetleyici.v %RTL3%\gelu_tablosu.v %RTL3%\sistolik_dizi.v %RTL3%\islem_elemani.v > cikti_xvlog.txt
call %VIVADO%\xelab.bat tb_ortak_ust -s olcum -debug typical -generic_top "HIZLI_OLCUM=%HO%" -generic_top "DOLGU_ATLA=%DA%" > cikti_xelab.txt
call %VIVADO%\xsim.bat olcum -R -testplusarg "hizli=1" -testplusarg "aralik=1" -testplusarg "ns=%NS%" %AKIS% > gunluk.txt
findstr /C:"SAF HESAP" /C:"toplam" gunluk.txt
