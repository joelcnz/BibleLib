if exist BGate\*.* del BGate\*.*
if not exist BGate\*.* md BGate
@
cd BGate
copy ..\kjvtext.txt
rem copy ..\bgtdos.exe
rem copy ..\bgtwin.exe
rem copy ..\dropswap.exe

copy ..\bgt.exe
copy ..\config.ini

copy ..\aformat.txt

copy ..\readme.txt

copy ..\main.d
copy ..\scraps.d

copy ..\install.bat