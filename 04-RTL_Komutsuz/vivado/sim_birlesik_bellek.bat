@echo off
rem Vivado xsim ile birlesik aktivasyon belleği sinamasi: katmanlar kopyalamadan zincirlenir (Q,K,V ve ileri besleme 1 -> 2), altin modelle bit-birebir.
rem Cift tiklayin. Once Python ile ileri besleme zincirinin beklenen cikisi uretilir. Gunluk: vivado\gunluk_birlesik_bellek.txt  (birkac dakika)
set VIVADO=C:\Xilinx\2025.1\Vivado\bin
set RTL3=%~dp0..\..\03-RTL\rtl
set RTL4=%~dp0..\rtl
set TB=%~dp0..\tb
cd /d %~dp0
python %~dp0..\scripts\uret_zincir_vektor.py
copy /Y %RTL4%\*.mem . > nul
call %VIVADO%\xvlog.bat -i %RTL4% %TB%\tb_birlesik_bellek.v %RTL4%\dogrusal_katman_birlesik.v %RTL4%\cikis_sozcuk_toplayici_devrik.v %RTL4%\birlesik_bellek.v %RTL4%\yeniden_olcekle_ortak.v %RTL4%\parametre_rom.v %RTL4%\panel_parametre_yukleyici.v %RTL4%\gelu_yukleyici.v %RTL3%\islem_elemani.v %RTL3%\sistolik_dizi.v %RTL3%\cift_kapili_bellek.v %RTL3%\panel_tamponu.v %RTL3%\tile_denetleyici.v %RTL3%\gelu_tablosu.v %RTL3%\cikis_sozcuk_toplayici.v > xvlog_birlesik.log
call %VIVADO%\xelab.bat tb_birlesik_bellek -s birlesik -debug typical > xelab_birlesik.log
call %VIVADO%\xsim.bat birlesik -R > gunluk_birlesik_bellek.txt
type gunluk_birlesik_bellek.txt | findstr /C:"====" /C:"Senaryo" /C:"sonucu" /C:"TEST" /C:"HATA" /C:"calisti" /C:"deger paneli"
echo.
echo Tam gunluk: %~dp0gunluk_birlesik_bellek.txt
pause
