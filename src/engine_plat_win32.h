#include "engine_impl_sdl.h"
#include "engine_impl_video_sdl.h"
#include "engine_impl_audio_sdl.h"
//#include "engine_impl_movie_sdl_ffmpeg.h"
#include "engine_impl_movie_sdl_smpeg.h"

#include <direct.h>
#include <stdlib.h>
#include <stdio.h>
//#include <unistd.h>

void game_init() {
	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
	SDL_EnableKeyRepeat(SDL_DEFAULT_REPEAT_DELAY, SDL_DEFAULT_REPEAT_INTERVAL);
	SDL_putenv("SDL_VIDEO_CENTERED=center");
}

extern "C" void game_main(int argc, char **argv);

//char game_path[PATH_MAX + 1];

void init_vm_system(int argc, char **argv) {
	NEWSLOT_STR("platform", "win32");
	NEWSLOT_INT("native_width", 0);
	NEWSLOT_INT("native_height", 0);
	NEWSLOT_STR("engine_path", _getcwd(NULL, 0));

	sq_pushstring(v, "argv", -1);
	sq_newarray(v, 0);
	
	for (int n = 0; n < argc; n++) {
		//printf("%s\n", argv[n]);
		sq_pushstring(v, argv[n], -1); sq_arrayappend(v, -2);
	}
	
	sq_createslot(v, -3);
}

int main(int argc, char **argv) {
	SetCurrentDirectory("engine");
	game_init();
	game_main(argc, argv);
	return 0;
}
