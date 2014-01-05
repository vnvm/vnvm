@echo off
rem MS-DOS batch file to build for Windows with MS Visual C++.
rem Supplied by George Yohng <yohng@dosware.8m.com>.
rem
rem $Id: build_msvc.bat,v 1.3 1999/07/27 02:36:04 greg Rel $

ren config.h config.was
md lib
copy config.h.win config.h
del *.obj
cl /I. /c /Ox /G5 /Gs /GR- /GA -Zp1 /MD *.c
lib /out:mpegcrt.lib *.obj
copy mpegcrt.lib lib
del *.obj
cl /I. /c /Ox /G5 /Gs /GR- /GA -Zp1 /ML *.c
lib /out:mpegc.lib *.obj
copy mpegc.lib lib
cl /I. /c /Ox /G5 /Gs /GR- /GA -Zp1 /MT *.c
lib /out:mpegcmt.lib *.obj
copy mpegcmt.lib lib
del *.obj
del mpegcrt.lib
del mpegc.lib
del mpegcmt.lib
del config.h
ren config.was config.h
