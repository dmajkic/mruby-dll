@echo off
setlocal
set MRUBY_DLL_DIR=%cd%
set MRUBY_CONFIG=%MRUBY_DLL_DIR%\build_config.rb

echo Parse source and create mruby.def
ruby create_def.rb

echo Build mruby
cd mruby
ruby minirake
if errorlevel 1 goto :end

echo Build mruby.dll
set INSTALL_SHARED_DIR=%cd%\bin\shared
set HOST_PATH=%cd%\build\host
set BUILD_SHARED_DIR=%HOST_PATH%\bin\shared
set GEMDIR=%HOST_PATH%\mrbgems

md %INSTALL_SHARED_DIR% %BUILD_SHARED_DIR% 2> nul
windres %MRUBY_DLL_DIR%\mruby.rc %BUILD_SHARED_DIR%\mrubyres.o
cd %BUILD_SHARED_DIR%
gcc -s -shared -Wl,--out-implib,libmruby.a -o mruby.dll %MRUBY_DLL_DIR%\mruby.def %HOST_PATH%\lib\libmruby.a mrubyres.o

echo Build shared binaries
gcc -s -o mrbc.exe %HOST_PATH%\tools\mrbc\mrbc.o %HOST_PATH%\src\print.o libmruby.a

gcc -s -o mruby.exe %GEMDIR%\mruby-bin-mruby\tools\mruby\mruby.o %HOST_PATH%\src\print.o libmruby.a
gcc -s -o mirb.exe  %GEMDIR%\mruby-bin-mirb\tools\mirb\mirb.o libmruby.a 

echo Install binaries
for %%f in (mruby.dll libmruby.a *.exe) do copy %%f %INSTALL_SHARED_DIR% > nul
:end
endlocal
