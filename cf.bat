cls
echo use cf -r for no terminal window

if "%1"=="-r" dmj -ofbin\Debug\jyble *.d bgate\kjv.d ..\OtherPeoples\dunit\dunit.d ..\Jeca\jeca\misc.d arsd\*.d -L/SUBSYSTEM:WINDOWS \jpro\dmd2\windows\import\ini\ini.d -L+gtkd.lib

if not "%1"=="-r" dmj -w -wi %1 %2 %3 %4 %5 %6 %7 %8 %9 -ofbin\Debug\jyble *.d bgate\kjv.d ..\OtherPeoples\dunit\dunit.d ..\Jeca\jeca\misc.d  arsd\*.d \jpro\dmd2\windows\import\ini\ini.d -L+gtkd.lib
