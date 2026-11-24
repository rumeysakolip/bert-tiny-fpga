@echo off
rem Vivado xsim ile dikkat zinciri sinamasi: Q.K^T -> olcekleme -> Softmax, 2 katman x 2 bas x 2 cumle, altin modelle bit-birebir.
rem Cift tiklayin. Gunluk: vivado\gunluk_dikkat_zinciri.txt  (birkac dakika)
set VIVADO=C:\Xilinx\2025.1\Vivado\bin
set RTL3=%~dp0..\..\03-RTL\rtl
set RTL4=%~dp0..\rtl
set TB=%~dp0..\tb
cd /d %~dp0
copy /Y %RTL4%\*.mem . > nul
call %VIVADO%\xvlog.bat -i %RTL4% %TB%\tb_dikkat_zinciri.v %RTL4%\dikkat_cekirdegi.v %RTL4%\panel_kopyalayici.v %RTL4%\yeniden_olcekle_ortak.v %RTL4%\softmax_birim_gomulu.v %RTL3%\ters_bolucu.v %RTL3%\seri_bolucu.v %RTL3%\islem_elemani.v %RTL3%\sistolik_dizi.v %RTL3%\cift_kapili_bellek.v %RTL3%\panel_tamponu.v %RTL3%\tile_denetleyici.v %RTL3%\cikis_sozcuk_toplayici.v > xvlog_dikkat.log
call %VIVADO%\xelab.bat tb_dikkat_zinciri -s dikkat -debug typical > xelab_dikkat.log
call %VIVADO%\xsim.bat dikkat -R > gunluk_dikkat_zinciri.txt
type gunluk_dikkat_zinciri.txt | findstr /C:"====" /C:"katman" /C:"TEST" /C:"HATA"
echo.
echo Tam gunluk: %~dp0gunluk_dikkat_zinciri.txt
pause
