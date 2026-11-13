@echo off
rem Vivado xsim ile artik toplama + LayerNorm sinamasi: 4 LayerNorm, altin modelin tam tamsayi hattiyla bit-birebir.
rem Cift tiklayin. Gunluk: vivado\gunluk_artik_ln.txt  (birkac dakika)
rem (Test vektorlerini yenilemek icin: python ..\scripts\uret_ln_vektor.py)
set VIVADO=C:\Xilinx\2025.1\Vivado\bin
set RTL3=%~dp0..\..\03-RTL\rtl
set RTL4=%~dp0..\rtl
set TB=%~dp0..\tb
cd /d %~dp0
copy /Y %RTL4%\*.mem . > nul
call %VIVADO%\xvlog.bat -i %RTL4% %TB%\tb_artik_ln.v %RTL4%\artik_ln_blogu.v %RTL4%\birlesik_bellek.v %RTL4%\yeniden_olcekle_ortak.v %RTL4%\layernorm_birim_dz.v %RTL3%\ters_bolucu.v %RTL3%\seri_bolucu.v %RTL3%\cift_kapili_bellek.v > xvlog_artik_ln.log
call %VIVADO%\xelab.bat tb_artik_ln -s artik_ln -debug typical > xelab_artik_ln.log
call %VIVADO%\xsim.bat artik_ln -R > gunluk_artik_ln.txt
type gunluk_artik_ln.txt | findstr /C:"====" /C:"LayerNorm" /C:"TEST" /C:"HATA"
echo.
echo Tam gunluk: %~dp0gunluk_artik_ln.txt
pause
