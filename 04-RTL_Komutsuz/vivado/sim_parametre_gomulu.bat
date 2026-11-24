@echo off
rem Vivado xsim ile gomulu sabit parametre sinamasi: 12 dogrusal katman, altin modelle bit-birebir.
rem Cift tiklayin. Gunluk: vivado\gunluk_parametre_gomulu.txt  (yaklasik birkac dakika)
set VIVADO=C:\Xilinx\2025.1\Vivado\bin
set RTL3=%~dp0..\..\03-RTL\rtl
set RTL4=%~dp0..\rtl
set TB=%~dp0..\tb
cd /d %~dp0
rem gomulu bellek dosyalari (param_bias.mem, param_m0.mem, gelu_*.mem, tanh.mem) benzetim klasorune kopyalanir
copy /Y %RTL4%\*.mem . > nul
call %VIVADO%\xvlog.bat -i %RTL4% %TB%\tb_parametre_gomulu.v %RTL4%\dogrusal_katman_gomulu.v %RTL4%\parametre_rom.v %RTL4%\panel_parametre_yukleyici.v %RTL4%\gelu_yukleyici.v %RTL3%\islem_elemani.v %RTL3%\sistolik_dizi.v %RTL3%\cift_kapili_bellek.v %RTL3%\panel_tamponu.v %RTL3%\tile_denetleyici.v %RTL3%\yeniden_olcekle.v %RTL3%\gelu_tablosu.v %RTL3%\cikis_sozcuk_toplayici.v %RTL3%\dogrusal_katman.v > xvlog_parametre.log
call %VIVADO%\xelab.bat tb_parametre_gomulu -s param_gomulu -debug typical > xelab_parametre.log
call %VIVADO%\xsim.bat param_gomulu -R > gunluk_parametre_gomulu.txt
type gunluk_parametre_gomulu.txt | findstr /C:"====" /C:"katman" /C:"sonuc" /C:"TEST" /C:"HATA"
echo.
echo Tam gunluk: %~dp0gunluk_parametre_gomulu.txt
pause
