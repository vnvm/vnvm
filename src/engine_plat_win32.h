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
	SDL_Init(0);
	SDL_Init(SDL_INIT_VIDEO);
	SDL_EnableKeyRepeat(SDL_DEFAULT_REPEAT_DELAY, SDL_DEFAULT_REPEAT_INTERVAL);
	SDL_putenv("SDL_VIDEO_CENTERED=center");
}

extern "C" void game_main();

//char game_path[PATH_MAX + 1];

void init_vm_system() {
	NEWSLOT_STR("platform", "win32");
	NEWSLOT_INT("native_width", 0);
	NEWSLOT_INT("native_height", 0);
	NEWSLOT_STR("engine_path", _getcwd(NULL, 0));
}

int main() {
	SetCurrentDirectory("engine");
	game_init();
	game_main();
	return 0;
}
