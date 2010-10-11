@echo off

SET LIBS_PATH=%CD%\src\platforms\win32\lib

SET SMPEG_INCLUDE=
SET SMPEG_INCLUDE=%SMPEG_INCLUDE% /I"%CD%\src\platforms\win32\include"
SET SMPEG_INCLUDE=%SMPEG_INCLUDE% /I"%CD%\src\platforms\win32\include\SDL"
SET SMPEG_INCLUDE=%SMPEG_INCLUDE% /I"%CD%\src\smpeg"

pushd src\smpeg
	"%VCINSTALLDIR%\bin\cl" /c *.c *.cpp %SMPEG_INCLUDE% /DWIN32=1
	pushd video
		"%VCINSTALLDIR%\bin\cl" /c *.cpp %SMPEG_INCLUDE% /DWIN32=1
	popd
	pushd audio
		"%VCINSTALLDIR%\bin\cl" /c *.cpp %SMPEG_INCLUDE% /DWIN32=1
	popd
	"%VCINSTALLDIR%\bin\lib" *.obj video\*.obj audio\*.obj /OUT:"%LIBS_PATH%\smpeg.lib"
	del *.obj video\*.obj audio\*.obj
popd

pushd src\sqstdlib
	"%VCINSTALLDIR%\bin\cl" *.cpp /I..\include /I"%VCINSTALLDIR%\include" /c /EHsc
	"%VCINSTALLDIR%\bin\lib" *.obj /OUT:"%LIBS_PATH%\sqstdlib.lib"
	del *.obj
popd
pushd src\squirrel
	"%VCINSTALLDIR%\bin\cl" *.cpp /I..\include /I"%VCINSTALLDIR%\include" /c /EHsc
	"%VCINSTALLDIR%\bin\lib" *.obj /OUT:"%LIBS_PATH%\squirrel.lib"
	del *.obj
popd