@echo off
rem
rem $Id: compile_bcc.bat $
rem

:COMPILE_BCC

   if "%HG_ROOT%" == "" goto ERROR1
   if "%HG_HRB%"  == "" goto ERROR1
   if "%HG_BCC%"  == "" goto ERROR1
   if "%LIB_GUI%" == "" goto ERROR1
   if "%LIB_HRB%" == "" goto ERROR1
   if "%BIN_HRB%" == "" goto ERROR1

:CHECK

   if "%1" == "" goto ERROR2
   if not exist %1.prg goto ERROR3

:CLEAN_EXE

   if exist %1.exe del %1.exe
   if exist %1.exe goto ERROR4
   if exist _temp.rc del _temp.rc
   if exist _temp.rc goto ERROR5
   if exist oohglog.txt del oohglog.txt

:PARSE_SWITCHES

   set HG_C_FLAGS=
   set HG_C_LIBS=
   set HG_C_LOG=1^>nul 2^>^&1
   set HG_COMP_TYPE=STD
   set HG_DEFINES=
   set HG_EXTRA=
   set HG_FILE=%1
   set HG_NO_RUN=FALSE
   set HG_PRG_LOG=
   set HG_USE_ADS=TRUE
   set HG_USE_MYSQL=TRUE
   set HG_USE_ODBC=TRUE
   set HG_USE_RC=TRUE
   set HG_USE_ZLIB=TRUE
   set HG_W_LIBS=

:LOOP_START
   if    "%2" == ""    goto LOOP_END
   if /I "%2" == "/D"  goto SW_DEBUG
   if /I "%2" == "-D"  goto SW_DEBUG
   if /I "%2" == "/C"  goto SW_CONSOLE
   if /I "%2" == "-C"  goto SW_CONSOLE
   if /I "%2" == "/I"  goto SW_NORC
   if /I "%2" == "-I"  goto SW_NORC
   if /I "%2" == "-P"  goto SW_PPO
   if /I "%2" == "/P"  goto SW_PPO
   if /I "%2" == "-W3" goto SW_W3
   if /I "%2" == "/W3" goto SW_W3
   if /I "%2" == "-NR" goto SW_NORUN
   if /I "%2" == "/NR" goto SW_NORUN
   if /I "%2" == "/L"  goto SW_USELOG
   if /I "%2" == "-L"  goto SW_USELOG
   if /I "%2" == "/O"  goto SW_ODBC
   if /I "%2" == "-O"  goto SW_ODBC
   if /I "%2" == "/Z"  goto SW_ZLIB
   if /I "%2" == "-Z"  goto SW_ZLIB
   if /I "%2" == "/A"  goto SW_ADS
   if /I "%2" == "-A"  goto SW_ADS
   if /I "%2" == "/M"  goto SW_MYSQL
   if /I "%2" == "-M"  goto SW_MYSQL
   if /I "%2" == "/S"  goto SW_SILENT
   if /I "%2" == "-S"  goto SW_SILENT

   set HG_EXTRA=%HG_EXTRA% %2
   shift
   goto LOOP_START

:SW_DEBUG

   set HG_COMP_TYPE=DEBUG
   shift
   goto LOOP_START

:SW_CONSOLE

   set HG_COMP_TYPE=CONSOLE
   set HG_DEFINES=-d_OOHG_CONSOLEMODE_
   shift
   goto LOOP_START

:SW_NORC

   set HG_USE_RC=FALSE
   shift
   goto LOOP_START

:SW_PPO

   set HG_EXTRA=%HG_EXTRA% -p
   shift
   goto LOOP_START

:SW_W3

   set HG_EXTRA=%HG_EXTRA% -w3
   shift
   goto LOOP_START

:SW_NORUN

   set HG_NO_RUN=TRUE
   shift
   goto LOOP_START

:SW_USELOG

   set HG_PRG_LOG=-q 1^>^>oohglog.txt 2^>^>^&1
   set HG_C_LOG=1^>^>oohglog.txt 2^>^>^&1
   shift
   goto LOOP_START

:SW_SILENT

   set HG_PRG_LOG=1^>nul 2^>^&1
   set HG_C_LOG=1^>nul 2^>^&1
   set HG_C_FLAGS=-q
   shift
   goto LOOP_START

:SW_ODBC

   set HG_USE_ODBC=TRUE
   shift
   goto LOOP_START

:SW_ZLIB

   set HG_USE_ZLIB=TRUE
   shift
   goto LOOP_START

:SW_ADS

   set HG_USE_ADS=TRUE
   shift
   goto LOOP_START

:SW_MYSQL

   set HG_USE_MYSQL=TRUE
   shift
   goto LOOP_START

:LOOP_END

   if "%HG_USE_RC%" == "FALSE" goto WITHOUT_HG_RC

   if     exist %HG_FILE%.rc copy /b %HG_ROOT%\resources\oohg_bcc.rc + %HG_FILE%.rc _temp.rc %HG_C_LOG%
   if not exist %HG_FILE%.rc copy /b %HG_ROOT%\resources\oohg_bcc.rc                _temp.rc %HG_C_LOG%
   %HG_BCC%\bin\brc32.exe -r -i%HG_ROOT%\resources _temp.rc %HG_DEFINES% %HG_C_LOG%
   if errorlevel 1 goto CLEANUP
   goto COMPILE_PRG

:WITHOUT_HG_RC

   if not exist %HG_FILE%.rc goto COMPILE_PRG

   copy /b %HG_FILE%.rc _temp.rc %HG_C_LOG%
   %HG_BCC%\bin\brc32.exe -r _temp.rc %HG_DEFINES% %HG_C_LOG%
   if errorlevel 1 goto CLEANUP

:COMPILE_PRG

   if "%HG_COMP_TYPE%" == "DEBUG" echo OPTIONS NORUNATSTARTUP > init.cld
   if "%HG_COMP_TYPE%" == "DEBUG" set %HG_EXTRA%=-b %HG_EXTRA%
   %HG_HRB%\%BIN_HRB%\harbour %HG_FILE%.prg -n %HG_EXTRA% -i%HG_HRB%\include;%HG_ROOT%\include;. %HG_DEFINES% %HG_PRG_LOG%
   if errorlevel 1 goto CLEANUP

:COMPILE_C

   %HG_BCC%\bin\bcc32 -c -O2 -tW -tWM -M -w -I%HG_HRB%\include;%HG_BCC%\include;%HG_ROOT%\include; -L%HG_BCC%\lib; %HG_FILE%.c %HG_DEFINES% %HG_C_LOG%
   if errorlevel 1 goto CLEANUP
   if "%HG_FLAVOR%" == "HARBOUR" goto LIBS_HARBOUR

:LIBS_XHARBOUR

   set HG_C_LIBS=gtgui gtwin
   if "%HG_COMP_TYPE%" == "DEBUG" set HG_C_LIBS=gtwin gtgui debug
   if "%HG_COMP_TYPE%" == "CONSOLE" set HG_C_LIBS=gtwin gtgui
   set HG_C_LIBS=%HG_C_LIBS% codepage common ct dbfcdx dbfdbt dbffpt dbfntx hbsix hsx lang
   set HG_C_LIBS=%HG_C_LIBS% libmisc macro pp rdd rtl tip vmmt %HG_ADDLIBS%
   set HG_C_LIBS=%HG_C_LIBS% hbzebra hbhpdf libharu png zlib
   goto LIBS_WINDOWS

:LIBS_HARBOUR

   set HG_C_LIBS=gtgui gtwin
   if "%HG_COMP_TYPE%" == "DEBUG" set HG_C_LIBS=gtwin gtgui hbdebug
   if "%HG_COMP_TYPE%" == "CONSOLE" set HG_C_LIBS=gtwin gtgui
   set HG_C_LIBS=%HG_C_LIBS% hbcpage hbcommon hbct rddcdx rddfpt rddntx hbsix hbhsx
   set HG_C_LIBS=%HG_C_LIBS% hblang hbmacro hbpp hbrdd hbrtl hbvmmt %HG_ADDLIBS%
   rem hbhpdf must precede hbwin png xhb
   set HG_C_LIBS=%HG_C_LIBS% hbmemio hbmisc hbmzip hbnulrdd hbtip hbhpdf hbzebra
   set HG_C_LIBS=%HG_C_LIBS% hbziparc hbzlib minizip hbwin png rddsql sddodbc xhb

:LIBS_WINDOWS

   set HG_W_LIBS=cw32mt import32 user32 winspool gdi32 comctl32 comdlg32 shell32 ole32 oleaut32 uuid mpr wsock32 ws2_32 mapi32 winmm vfw32 msimg32 iphlpapi

:BUILD_RESPONSE_FILE:

   echo c0w32.obj + > b32.bc
   echo %HG_FILE%.obj, + >> b32.bc
   echo %HG_FILE%.exe, + >> b32.bc
   echo %HG_FILE%.map, + >> b32.bc
   echo %HG_ROOT%\%LIB_GUI%\oohg.lib + >> b32.bc
   echo %HG_ROOT%\%LIB_GUI%\bostaurus.lib + >> b32.bc
   echo %HG_ROOT%\%LIB_GUI%\hbprinter.lib + >> b32.bc
   echo %HG_ROOT%\%LIB_GUI%\miniprint.lib + >> b32.bc
   for %%a in ( %HG_C_LIBS% ) do if exist %HG_HRB%\%LIB_HRB%\%%a.lib echo %HG_HRB%\%LIB_HRB%\%%a.lib + >> b32.bc
   if "%HG_USE_ODBC%"  == "TRUE" echo %HG_HRB%\%LIB_HRB%\hbodbc.lib + >> b32.bc
   if "%HG_USE_ODBC%"  == "TRUE" echo %HG_HRB%\%LIB_HRB%\odbc32.lib + >> b32.bc
   if "%HG_USE_ZLIB%"  == "TRUE" echo %HG_HRB%\%LIB_HRB%\zlib1.lib + >> b32.bc
   if "%HG_USE_ZLIB%"  == "TRUE" echo %HG_HRB%\%LIB_HRB%\ziparchive.lib + >> b32.bc
   if "%HG_USE_ADS%"   == "TRUE" echo %HG_HRB%\%LIB_HRB%\rddads.lib + >> b32.bc
   if "%HG_USE_ADS%"   == "TRUE" echo %HG_HRB%\%LIB_HRB%\ace32.lib + >> b32.bc
   if "%HG_USE_MYSQL%" == "TRUE" echo %HG_HRB%\%LIB_HRB%\mysql.lib + >> b32.bc
   if "%HG_USE_MYSQL%" == "TRUE" echo %HG_HRB%\%LIB_HRB%\libmysqldll.lib + >> b32.bc
   for %%a in ( %HG_W_LIBS% ) do echo %%a.lib + >> b32.bc
   echo , , + >> b32.bc
   if exist _temp.res echo _temp.res >> b32.bc

:LINK

   if not "%HG_COMP_TYPE%" == "DEBUG" set HG_C_FLAGS=-Gn -Tpe -aa %HG_C_FLAGS%
   if     "%HG_COMP_TYPE%" == "DEBUG" set HG_C_FLAGS=-Gn -Tpe -ap %HG_C_FLAGS%
   %HG_BCC%\bin\ilink32.exe %HG_C_FLAGS% -L%HG_BCC%\lib;%HG_BCC%\lib\psdk; @b32.bc %HG_DEFINES% %HG_C_LOG%

:CLEANUP

   del b32.bc
   if exist %HG_FILE%.map del %HG_FILE%.map
   if exist %HG_FILE%.obj del %HG_FILE%.obj
   if exist %HG_FILE%.tds del %HG_FILE%.tds
   if exist %HG_FILE%.c   del %HG_FILE%.c
   for %%a in ( _temp.* ) do del %%a
   set HG_C_FLAGS=
   set HG_C_LIBS=
   set HG_C_LOG=
   set HG_COMP_TYPE=
   set HG_DEFINES=
   set HG_EXTRA=
   set HG_PRG_LOG=
   set HG_USE_ADS=
   set HG_USE_MYSQL=
   set HG_USE_ODBC=
   set HG_USE_RC=
   set HG_USE_ZLIB=
   set HG_W_LIBS=

   rem *** Run ***
   if errorlevel 1 set HG_NO_RUN=TRUE
   if "%HG_NO_RUN%" == "FALSE" %HG_FILE%

   set HG_FILE=
   set HG_NO_RUN=
   if exist init.cld del init.cld
   goto END

:ERROR1

   echo This file must be called from COMPILE.BAT !!!
   goto END

:ERROR2

   echo COMPILE ERROR: No file specified !!!
   goto END

:ERROR3

   echo File %1.prg not found !!!
   goto END

:ERROR4

   echo COMPILE ERROR: Is %1.exe running ?
   goto END

:ERROR5

   echo Cant't delete _temp.rc file !!!
   goto END

:END
