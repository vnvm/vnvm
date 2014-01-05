@echo off
rem MS-DOS batch file to build for Windows with Borland C++.
rem Supplied by George Yohng <yohng@dosware.8m.com>.
rem
rem $Id: build_bc.bat,v 1.3 1999/08/06 02:18:21 greg Rel $

del *.obj
ren config.h config.was
copy config.h.win config.h
bcc32 -c -5 -N- -v- -k- -RT- -a1 /I. *.c
del mpegbc.lib
tlib /C /0 mpegbc.lib +24bit.obj 
tlib /C /0 mpegbc.lib +2x2.obj 
tlib /C /0 mpegbc.lib +decoders.obj 
tlib /C /0 mpegbc.lib +fs2.obj 
tlib /C /0 mpegbc.lib +fs2fast.obj 
tlib /C /0 mpegbc.lib +fs4.obj 
tlib /C /0 mpegbc.lib +gdith.obj 
tlib /C /0 mpegbc.lib +globals.obj 
tlib /C /0 mpegbc.lib +gray.obj 
tlib /C /0 mpegbc.lib +hybrid.obj 
tlib /C /0 mpegbc.lib +hybriderr.obj 
tlib /C /0 mpegbc.lib +jrevdct.obj 
tlib /C /0 mpegbc.lib +mb_ordered.obj 
tlib /C /0 mpegbc.lib +mono.obj 
tlib /C /0 mpegbc.lib +motionvector.obj 
tlib /C /0 mpegbc.lib +ordered.obj 
tlib /C /0 mpegbc.lib +ordered2.obj 
tlib /C /0 mpegbc.lib +parseblock.obj 
tlib /C /0 mpegbc.lib +util.obj 
tlib /C /0 mpegbc.lib +video.obj 
tlib /C /0 mpegbc.lib +wrapper.obj 
del mpegbc.bak
md lib
copy mpegbc.lib lib
del *.obj
del mpegbc.lib
del config.h
ren config.was config.h
