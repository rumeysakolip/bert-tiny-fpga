@echo off
rem Vivado xsim ile tam dikkat basi sinamasi: Q.K^T -> Softmax -> P.V; olasiliklar cip icinde uretilir; baglam altin modelle bit-birebir.
rem Cift tiklayin. Gunluk: vivado\gunluk_dikkat_pv.txt  (birkac dakika)
set VIVADO=C:\Xilinx\2025.1\Vivado\bin
set RTL3=%~dp0..\..\03-RTL\rtl
set RTL4=%~dp0..\rtl
set TB=%~dp0..\tb
cd /d %~dp0
python %~dp0..\scripts\uret_dikkat_vektor.py
copy /Y %RTL4%\*.mem . > nul
call %VIVADO%\xvlog.bat -i %RTL4% %TB%\tb_dikkat_pv.v %RTL4%\dikkat_cekirdegi.v %RTL4%\panel_kopyalayici.v %RTL4%\yeniden_olcekle_ortak.v %RTL4%\softmax_birim_gomulu.v %RTL3%\ters_bolucu.v %RTL3%\seri_bolucu.v %RTL3%\islem_elemani.v %RTL3%\sistolik_dizi.v %RTL3%\cift_kapili_bellek.v %RTL3%\panel_tamponu.v %RTL3%\tile_denetleyici.v %RTL3%\cikis_sozcuk_toplayici.v > xvlog_dikkat_pv.log
call %VIVADO%\xelab.bat tb_dikkat_pv -s dikkat_pv -debug typical > xelab_dikkat_pv.log
call %VIVADO%\xsim.bat dikkat_pv -R > gunluk_dikkat_pv.txt
type gunluk_dikkat_pv.txt | findstr /C:"====" /C:"katman" /C:"TEST" /C:"HATA"
echo.
echo Tam gunluk: %~dp0gunluk_dikkat_pv.txt
pause
