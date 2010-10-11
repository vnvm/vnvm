@echo off
cls
del engine.exe 2> NUL

SET LIBS=
SET LIBS=%LIBS% squirrel.lib
SET LIBS=%LIBS% sqstdlib.lib
SET LIBS=%LIBS% smpeg.lib
SET LIBS=%LIBS% SDL.lib
SET LIBS=%LIBS% SDL_mixer.lib
SET LIBS=%LIBS% SDL_image.lib
SET LIBS=%LIBS% SDL_ttf.lib
SET LIBS=%LIBS% opengl32.lib
SET LIBS=%LIBS% kernel32.lib
SET LIBS=%LIBS% user32.lib

SET ENGINE_INCLUDE=
SET ENGINE_INCLUDE=%ENGINE_INCLUDE% /Isrc\platforms\win32\include
SET ENGINE_INCLUDE=%ENGINE_INCLUDE% /Isrc\platforms\win32\include\SDL
SET ENGINE_INCLUDE=%ENGINE_INCLUDE% /Isrc\smpeg
SET ENGINE_INCLUDE=%ENGINE_INCLUDE% /Isrc\include

DEL /Q engine.exe 2> NUL
IF NOT DEFINED VNVM_DLL_PATH2_SET SET PATH=%PATH%;%CD%\src\platforms\win32\bin
SET VNVM_DLL_PATH2_SET=1
rc.exe src\platforms\win32\res\vnvm.rc
"%VCINSTALLDIR%\bin\cl.exe" /nologo src/engine.cpp src\platforms\win32\res\vnvm.res %LIBS% %ENGINE_INCLUDE% /EHsc /Zi /MD /Ox /link /LIBPATH:src\platforms\win32\lib /NODEFAULTLIB:LIBCMT
IF EXIST "engine.exe" (
	del engine.ilk 2> NUL
	del engine.obj 2> NUL
	REM del engine.pdb 2> NUL
	del engine.exp 2> NUL
	del engine.lib 2> NUL
	del vc90.pdb 2> NUL
	del vc100.pdb 2> NUL
	engine.exe
)