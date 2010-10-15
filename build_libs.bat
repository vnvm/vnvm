@echo off

SET LIBS_PATH=%CD%\src\platforms\win32\lib

SET SMPEG_INCLUDE=
SET SMPEG_INCLUDE=%SMPEG_INCLUDE% /I"%CD%\src\platforms\win32\include"
SET SMPEG_INCLUDE=%SMPEG_INCLUDE% /I"%CD%\src\platforms\win32\include\SDL"
SET SMPEG_INCLUDE=%SMPEG_INCLUDE% /I"%CD%\src\smpeg"
REM SET SMPEG_INCLUDE=
REM SET SMPEG_INCLUDE=%SMPEG_INCLUDE% -I"%CD%\src\platforms\win32\include"
REM SET SMPEG_INCLUDE=%SMPEG_INCLUDE% -I"%CD%\src\platforms\win32\include\SDL"
REM SET SMPEG_INCLUDE=%SMPEG_INCLUDE% -I"%CD%\src\smpeg"

pushd src\smpeg
	REM gcc -O2 %SMPEG_INCLUDE% -c *.cpp
	"%VCINSTALLDIR%\bin\cl" /c *.c *.cpp %SMPEG_INCLUDE% /DWIN32=1
	pushd video
		REM gcc -O2 %SMPEG_INCLUDE% -c *.cpp
		"%VCINSTALLDIR%\bin\cl" /c *.cpp %SMPEG_INCLUDE% /DWIN32=1
	popd
	pushd audio
		REM gcc -O2 %SMPEG_INCLUDE% -c *.cpp
		"%VCINSTALLDIR%\bin\cl" /c *.cpp %SMPEG_INCLUDE% /DWIN32=1
	popd
	"%VCINSTALLDIR%\bin\lib" *.obj video\*.obj audio\*.obj /OUT:"%LIBS_PATH%\smpeg.lib"
	REM ar  rcs "%LIBS_PATH%\libsqtdlib.a" *.o video\*.o audio\*.o
	del *.obj video\*.obj audio\*.obj *.o video\*.o audio\*.o 2> NUL
popd

pushd src\sqstdlib
	REM g++ -O2 -I ..\include -c *.cpp
	REM ar  rcs "%LIBS_PATH%\libsqstdlib.a" *.o
	"%VCINSTALLDIR%\bin\cl" *.cpp /I..\include /I"%VCINSTALLDIR%\include" /c /EHsc
	"%VCINSTALLDIR%\bin\lib" *.obj /OUT:"%LIBS_PATH%\sqstdlib.lib"
	del *.obj *.o 2> NUL
popd
pushd src\squirrel
	REM g++ -O2 -I ..\include -c *.cpp
	REM ar  rcs "%LIBS_PATH%\libsquirrel.a" *.o
	"%VCINSTALLDIR%\bin\cl" *.cpp /I..\include /I"%VCINSTALLDIR%\include" /c /EHsc
	"%VCINSTALLDIR%\bin\lib" *.obj /OUT:"%LIBS_PATH%\squirrel.lib"
	del *.obj *.o 2> NUL
popd