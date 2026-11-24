@echo off
rem Vivado xsim ile Softmax (gomulu ustel tablo) sinamasi. Cift tiklayin ya da komut satirindan calistirin.
rem Cikti gunlugu: vivado\gunluk_softmax_gomulu.txt   (dalga formu istenirse: xsim ... -gui yerine asagidaki -R satirini -gui ile degistirin)
set VIVADO=C:\Xilinx\2025.1\Vivado\bin
set RTL3=%~dp0..\..\03-RTL\rtl
set RTL4=%~dp0..\rtl
set TB=%~dp0..\tb
cd /d %~dp0
call %VIVADO%\xvlog.bat %TB%\tb_softmax_gomulu.v %RTL4%\softmax_birim_gomulu.v %RTL3%\ters_bolucu.v %RTL3%\seri_bolucu.v > xvlog_softmax.log
call %VIVADO%\xelab.bat tb_softmax_gomulu -s sm_gomulu -debug typical > xelab_softmax.log
call %VIVADO%\xsim.bat sm_gomulu -R > gunluk_softmax_gomulu.txt
type gunluk_softmax_gomulu.txt | findstr /C:"====" /C:"ilerleme" /C:"TEST"
echo.
echo Tam gunluk: %~dp0gunluk_softmax_gomulu.txt
pause
