@echo off
rem Vivado xsim ile UCTAN UCA sinama: bayt akisi -> CRC-16 ayristirici -> sabit cizelge (14 satir/katman) -> ortak cekirdek, altin modelle bit-birebir.
rem Cift tiklayin. Gunluk: vivado\gunluk_ortak_ust.txt  (uzun surer: Vivado'da ~20-40 dakika olabilir)
set VIVADO=C:\Xilinx\2025.1\Vivado\bin
set RTL3=%~dp0..\..\03-RTL\rtl
set RTL4=%~dp0..\rtl
set TB=%~dp0..\tb
cd /d %~dp0
copy /Y %RTL4%\*.mem . > nul
call %VIVADO%\xvlog.bat -i %RTL4% %TB%\tb_ortak_ust.v %RTL4%\ortak_ust.v %RTL4%\cizelge_ortak.v %RTL4%\akis_ayristirici.v %RTL4%\ortak_cekirdek.v %RTL4%\ek_hat.v %RTL4%\yaz_fifo.v %RTL4%\agirlik_rom_banka.v %RTL4%\artik_ln_par.v %RTL4%\birlesik_bellek_2o.v %RTL4%\artik_ln_ortak.v %RTL4%\yeniden_olcekle_ortak.v %RTL4%\layernorm_birim_dz.v %RTL4%\panel_kopyalayici.v %RTL4%\panel_parametre_yukleyici.v %RTL4%\parametre_rom.v %RTL4%\gelu_yukleyici.v %RTL4%\cikis_sozcuk_toplayici_devrik.v %RTL4%\softmax_birim_gomulu.v %RTL3%\ters_bolucu.v %RTL3%\seri_bolucu.v %RTL3%\cift_kapili_bellek.v %RTL3%\cikis_sozcuk_toplayici.v %RTL3%\panel_tamponu.v %RTL3%\tile_denetleyici.v %RTL3%\gelu_tablosu.v %RTL3%\sistolik_dizi.v %RTL3%\islem_elemani.v > xvlog_ust.log
call %VIVADO%\xelab.bat tb_ortak_ust -s ortak_ust -debug typical > xelab_ust.log
call %VIVADO%\xsim.bat ortak_ust -R > gunluk_ortak_ust.txt
type gunluk_ortak_ust.txt | findstr /C:"====" /C:"----" /C:"bitti" /C:"BASARI" /C:"TEST" /C:"HATA"
echo.
echo Tam gunluk: %~dp0gunluk_ortak_ust.txt
pause
