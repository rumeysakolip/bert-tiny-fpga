@echo off
rem Vivado xsim ile komutsuz akis sinamasi: bayt akisi (denetim kodlu) -> cizelge -> katman 0 Q, K, V; cumle uzunlugu akistan okunur.
rem Cift tiklayin. Once Python ile bayt akisi uretilir (sim\akis_dogru.hex), sonra benzetim calisir. Gunluk: vivado\gunluk_komutsuz_akis.txt
set VIVADO=C:\Xilinx\2025.1\Vivado\bin
set RTL3=%~dp0..\..\03-RTL\rtl
set RTL4=%~dp0..\rtl
set TB=%~dp0..\tb
cd /d %~dp0
if not exist %~dp0..\sim mkdir %~dp0..\sim
python %~dp0..\scripts\akis_uret.py %~dp0..\sim\akis_dogru.hex --ns 4
call %VIVADO%\xvlog.bat -i %RTL4% %TB%\tb_komutsuz_ust.v %RTL4%\akis_ayristirici.v %RTL4%\cizelge_siralayici.v %RTL4%\komutsuz_ust.v %RTL3%\islem_elemani.v %RTL3%\sistolik_dizi.v %RTL3%\cift_kapili_bellek.v %RTL3%\panel_tamponu.v %RTL3%\tile_denetleyici.v %RTL3%\yeniden_olcekle.v %RTL3%\gelu_tablosu.v %RTL3%\cikis_sozcuk_toplayici.v %RTL3%\dogrusal_katman.v > xvlog_akis.log
call %VIVADO%\xelab.bat tb_komutsuz_ust -s komutsuz_akis -debug typical > xelab_akis.log
call %VIVADO%\xsim.bat komutsuz_akis -R > gunluk_komutsuz_akis.txt
type gunluk_komutsuz_akis.txt | findstr /C:"====" /C:"cumle" /C:"TEST" /C:"HATA" /C:"FAIL"
echo.
echo Tam gunluk: %~dp0gunluk_komutsuz_akis.txt
pause
