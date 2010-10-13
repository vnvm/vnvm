#if defined(_WIN32) && !defined(_XBOX)
	#include <windows.h>
#endif

#define USE_OPENGL 1

#include <SDL.h>
#include <SDL_image.h>
#include <SDL_ttf.h>
#include <SDL_mixer.h>
#ifdef USE_OPENGL
	#include <SDL_opengl.h>
#endif

#undef main

#define sdl_long int
#define sdl_size_t int
//#define sdl_size_t size_t
//#define SDL_GetKeyboardState SDL_GetKeyState

sdl_long sqstream_rwops_seek(struct SDL_RWops *context, sdl_long offset, int whence) {
	SQStream *stream = (SQStream *)context->hidden.unknown.data1;
	int ret = 0;
	switch (whence) {
		//default:
		case RW_SEEK_SET: ret = stream->Seek(offset, SQ_SEEK_SET); break;
		case RW_SEEK_CUR: ret = stream->Seek(offset, SQ_SEEK_CUR); break;
		case RW_SEEK_END: ret = stream->Seek(offset, SQ_SEEK_END); break;
	}
	//printf("Seek(%d, %d) : %d\n", offset, whence, ret);
	return ret;
}

sdl_size_t sqstream_rwops_read(struct SDL_RWops *context, void *ptr, sdl_size_t size, sdl_size_t maxnum) {
	SQStream *stream = (SQStream *)context->hidden.unknown.data1;
	//int pos_start = stream->Tell();
	sdl_size_t ret = stream->Read(ptr, size * maxnum);
	//int pos_end = stream->Tell();
	//int readed = pos_end - pos_start;
	//printf("Read(%08X:%08X, %d) : %d,%d '%c%c%c'\n", ptr, pos_start, size * maxnum, ret, readed, ((char *)ptr)[0], ((char *)ptr)[1], ((char *)ptr)[2]);
	return ret;
}

sdl_size_t sqstream_rwops_write(struct SDL_RWops *context, const void *ptr, sdl_size_t size, sdl_size_t num) {
	SQStream *stream = (SQStream *)context->hidden.unknown.data1;
	sdl_size_t ret = stream->Write((void *)ptr, size * num);
	//printf("Write(%08X, %d) : %d\n", ptr, size * num, ret);
	return ret;
}

int sqstream_rwops_close(struct SDL_RWops * context) {
	SQStream *stream = (SQStream *)context->hidden.unknown.data1;
	//printf("Close()\n");
	return 0;
}

SDL_RWops *SQStream_to_RWops(SQStream *stream) {
	SDL_RWops *rwops = SDL_AllocRW();
	rwops->hidden.unknown.data1 = (void *)stream;
	rwops->seek  = sqstream_rwops_seek;
	rwops->read  = sqstream_rwops_read;
	rwops->write = sqstream_rwops_write;
	rwops->close = sqstream_rwops_close;
	return rwops;
}

class Mouse { public:
	int x_now, y_now;
	int x_before, y_before;
	int dx, dy;
	int buttons_now;
	int buttons_before;
	int wheel_now;
	int wheel_before;
	
	Mouse() {
		this->x_now = 0;
		this->y_now = 0;
		this->x_before = 0;
		this->y_before = 0;
		this->dx = 0;
		this->dy = 0;
		this->buttons_now = 0;
		this->buttons_before = 0;
		this->wheel_now = 0;
		this->wheel_before = 0;
	}
	
	bool pressed_now(int button) { return (buttons_now & (1 << button)) != 0; }
	bool pressed_before(int button) { return (buttons_before & (1 << button)) != 0; }
	bool clicked(int button) { return !pressed_before(button) && pressed_now(button); }

	void update() {
		wheel_before = wheel_now;
		buttons_before = buttons_now;
		x_before = x_now;
		y_before = y_now;
		buttons_now = SDL_GetMouseState(&x_now, &y_now);
		dx = x_now - x_before;
		dy = y_now - y_before;
		wheel_now = mouse_wheel;
	}
};

class Keyboard { public:
	int sdlk_count;
	Uint8 *keys_now;
	Uint8 *keys_before;
	int keymod_now;
	int keymod_before;

	Keyboard() {
		sdlk_count = 0;
		SDL_GetKeyState(&sdlk_count);
		keys_now    = (Uint8 *)malloc(sdlk_count);
		keys_before = (Uint8 *)malloc(sdlk_count);
		keymod_now = 0;
		keymod_before = 0;
		memset(keys_now, 0, sdlk_count);
		memset(keys_before, 0, sdlk_count);
	}
	
	~Keyboard() {
		free(keys_now);
		free(keys_before);
	}

	void update() {
		memcpy(keys_before, keys_now, sdlk_count);
		keymod_before = keymod_now;

		Uint8 *keys_current = NULL;
		keys_current = SDL_GetKeyState(NULL);
		memcpy(keys_now, keys_current, sdlk_count);
		keymod_now = SDL_GetModState();
	}
	
	int dx() { return (keys_now[SDLK_LEFT] ? -1 : (keys_now[SDLK_RIGHT] ? +1 : 0)); }
	int dy() { return (keys_now[SDLK_UP  ] ? -1 : (keys_now[SDLK_DOWN ] ? +1 : 0)); }
	int pressed(int key) {
		if (key < 0 || key >= sdlk_count) return 0;
		return !keys_before[key] && keys_now[key];
	}
	int pressing(int key) {
		if (key < 0 || key >= sdlk_count) return 0;
		return keys_now[key];
	}
	int mod_pressed(int mask) {
		return ((keymod_before & mask) == 0) && ((keymod_now & mask) != 0);
	}
	int mod_pressing(int mask) {
		return ((keymod_now & mask) != 0);
	}
};

void game_frame_events()
{
	SDL_Event event;
	static int clicking = 0;
	int clicking_back = clicking;
	
	while (SDL_PollEvent(&event)) {
		switch (event.type) {
			case SDL_QUIT:
				game_quit();
			break;
			case SDL_KEYUP: case SDL_KEYDOWN: {
				int v = (event.key.type == SDL_KEYDOWN);
				int k = event.key.keysym.sym;
				//keys_status [k]  = v;
				//keys_pressed[k] |= v;
				if (k == SDLK_ESCAPE) {
					game_quit();
				}
			} break;
			case SDL_MOUSEBUTTONUP: case SDL_MOUSEBUTTONDOWN: {
				int v = (event.button.type == SDL_MOUSEBUTTONDOWN);
				clicking = v;
				if (v) {
					switch (event.button.button) {
						case SDL_BUTTON_WHEELUP: case SDL_BUTTON_WHEELDOWN: {
							mouse_wheel += (event.button.button == SDL_BUTTON_WHEELDOWN) ? +1 : -1;
						} break;
					}
				}
			} break;
		}
	}
	//printf("%d\n", mouse_wheel);
	
	/*touches_count = clicking;
	if (clicking) {
		int x = 0, y = 0;
		SDL_GetMouseState(&x, &y);
		if (clicking_back == 0) {
			touches[0].bx = x;
			touches[0].by = y;
		}
		touches[0].x = x;
		touches[0].y = y;
	}*/
}

void game_frame_delay(int ms = 60)
{
	static unsigned int ticks = 0;
	//Audio::gc();
	game_frame_events();
	SDL_PumpEvents(); SDL_Delay(0);
	while (SDL_GetTicks() < ticks + ms) { SDL_PumpEvents(); SDL_Delay(1); }
	ticks = SDL_GetTicks();
	//Audio::gc();
}
