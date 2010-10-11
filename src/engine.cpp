#include "engine_utils.h"
#include "engine_common.h"

#include "engine_plat.h"

#include "engine_class_bitmap.h"
#include "engine_class_effect.h"
#include "engine_class_font.h"
#include "engine_class_sound.h"
#include "engine_class_audio.h"
#include "engine_class_music.h"
#include "engine_class_mouse.h"
#include "engine_class_keyboard.h"
#include "engine_class_movie.h"
#include "engine_class_base.h"

#ifdef SQUNICODE
#define scfprintf fwprintf
#define scfopen	_wfopen
#define scvprintf vfwprintf
#else
#define scfprintf fprintf
#define scfopen	fopen
#define scvprintf vfprintf
#endif

void errorfunc(HSQUIRRELVM v,const SQChar *s,...)
{
	va_list vl;
	va_start(vl, s);
	scvprintf(stderr, s, vl);
	va_end(vl);
}

extern "C" void game_main() {
	v = sq_open(1024);	
	//sq_setprintfunc(v, printfunc, errorfunc);
	sq_setprintfunc(v, printfunc);
	
	sq_pushroottable(v);
	{
		engine_register_bitmap();
		engine_register_effect();
		engine_register_audio();
		engine_register_sound();
		engine_register_music();
		engine_register_font();
		engine_register_screen();
		engine_register_mouse();
		engine_register_keyboard();
		engine_register_functions();
		engine_register_movie();

		sqstd_register_bloblib(v);
		sqstd_register_iolib(v);
		sqstd_register_systemlib(v);
		sqstd_register_mathlib(v);
		sqstd_register_stringlib(v);

		sqstd_seterrorhandlers(v);
		sq_enabledebuginfo(v, 1);
		
		sq_newtable(v);
		sq_pushstring(v, "info", -1);
		sq_push(v, -2);
		sq_createslot(v, -4);
		{
			init_vm_system();
		}
		sq_pop(v, 1);

		/*
		CREATE_OBJECT(Mouse, new Mouse);
		sq_pushstring(v, "mouse", -1);
		sq_push(v, -2);
		*/
		//sq_pop(v, 2);
	}
	if (SQ_FAILED(sqstd_dofile(v, "main.nut", SQFalse, SQTrue))) {
		printf("Can't open 'main.nut'\n");
	}
	sq_pop(v, 1);

	sq_close(v);
}
