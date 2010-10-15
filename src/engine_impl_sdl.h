#if defined(_WIN32) && !defined(_XBOX)
	#include <windows.h>
	#include <math.h>
#endif

#define USE_OPENGL 1

//#undef M_PI
//#include "math.h"
#ifndef M_PI
	#define M_PI 3.141592653589793238462643
#endif

#include <SDL.h>
#include <SDL_stdinc.h>
#include <SDL_image.h>
#include <SDL_ttf.h>
#include <SDL_mixer.h>
#ifdef USE_OPENGL
	#include <SDL_opengl.h>
#endif
//#include <SDL_compat.h>

#undef main

#if 0
	#define sdl_long long
	#define sdl_size_t size_t
	#define SDL_GetKeyState SDL_GetKeyboardState
#else
	#define sdl_long int
	#define sdl_size_t int
#endif

sdl_long SDLCALL sqstream_rwops_seek(struct SDL_RWops *context, sdl_long offset, int whence) {
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

sdl_size_t SDLCALL sqstream_rwops_read(struct SDL_RWops *context, void *ptr, sdl_size_t size, sdl_size_t maxnum) {
	SQStream *stream = (SQStream *)context->hidden.unknown.data1;
	//int pos_start = stream->Tell();
	sdl_size_t ret = stream->Read(ptr, size * maxnum);
	//int pos_end = stream->Tell();
	//int readed = pos_end - pos_start;
	//printf("Read(%08X:%08X, %d) : %d,%d '%c%c%c'\n", ptr, pos_start, size * maxnum, ret, readed, ((char *)ptr)[0], ((char *)ptr)[1], ((char *)ptr)[2]);
	return ret;
}

sdl_size_t SDLCALL sqstream_rwops_write(struct SDL_RWops *context, const void *ptr, sdl_size_t size, sdl_size_t num) {
	SQStream *stream = (SQStream *)context->hidden.unknown.data1;
	sdl_size_t ret = stream->Write((void *)ptr, size * num);
	//printf("Write(%08X, %d) : %d\n", ptr, size * num, ret);
	return ret;
}

int SDLCALL sqstream_rwops_close(struct SDL_RWops * context) {
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
		//buttons_now = SDL_GetMouseState(1, &x_now, &y_now);
		buttons_now = SDL_GetMouseState(&x_now, &y_now);
		dx = x_now - x_before;
		dy = y_now - y_before;
		wheel_now = mouse_wheel;
	}
};

#ifdef WIN32
	#define XINPUT_GAMEPAD_DPAD_UP          0x00000001
	#define XINPUT_GAMEPAD_DPAD_DOWN        0x00000002
	#define XINPUT_GAMEPAD_DPAD_LEFT        0x00000004
	#define XINPUT_GAMEPAD_DPAD_RIGHT       0x00000008
	#define XINPUT_GAMEPAD_START            0x00000010
	#define XINPUT_GAMEPAD_BACK             0x00000020
	#define XINPUT_GAMEPAD_LEFT_THUMB       0x00000040
	#define XINPUT_GAMEPAD_RIGHT_THUMB      0x00000080
	#define XINPUT_GAMEPAD_LEFT_SHOULDER    0x00000100
	#define XINPUT_GAMEPAD_RIGHT_SHOULDER   0x00000200
	#define XINPUT_GAMEPAD_A                0x00001000
	#define XINPUT_GAMEPAD_B                0x00002000
	#define XINPUT_GAMEPAD_X                0x00004000
	#define XINPUT_GAMEPAD_Y                0x00008000

	typedef struct {
		WORD  wButtons;      /// Bitmask of the device digital buttons, as follows. A set bit indicates that the corresponding button is pressed. Bits that are set but not defined above are reserved, and their state is undefined. XINPUT_GAMEPAD_*
		BYTE  bLeftTrigger;  /// The current value of the left  trigger analog control. The value is between 0 and 255.
		BYTE  bRightTrigger; /// The current value of the right trigger analog control. The value is between 0 and 255.
		SHORT sThumbLX;      /// Left thumbstick x-axis value. Each of the thumbstick axis members is a signed value between -32768 and 32767 describing the position of the thumbstick. A value of 0 is centered. Negative values signify down or to the left. Positive values signify up or to the right. The constants XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE or XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE can be used as a positive and negative value to filter a thumbstick input.
		SHORT sThumbLY;      /// Left thumbstick y-axis value. The value is between -32768 and 32767.
		SHORT sThumbRX;      /// Right thumbstick x-axis value. The value is between -32768 and 32767.
		SHORT sThumbRY;      /// Right thumbstick y-axis value. The value is between -32768 and 32767.
	} XINPUT_GAMEPAD;
	
	/**
	 * Represents the state of a controller.
	 *
	 *  The dwPacketNumber member is incremented only if the status of the controller has changed since the controller was last polled.
	 */
	typedef struct {
		DWORD dwPacketNumber;   /// State packet number. The packet number indicates whether there have been any changes in the state of the controller. If the dwPacketNumber member is the same in sequentially returned XINPUT_STATE structures, the controller state has not changed.
		XINPUT_GAMEPAD Gamepad; /// XINPUT_GAMEPAD structure containing the current state of an Xbox 360 Controller.
	} XINPUT_STATE;

	typedef struct {
		WORD wLeftMotorSpeed;  /// Speed of the left  motor. Valid values are in the range 0 to 65,535. Zero signifies no motor use; 65,535 signifies 100 percent motor use.
		WORD wRightMotorSpeed; /// Speed of the right motor. Valid values are in the range 0 to 65,535. Zero signifies no motor use; 65,535 signifies 100 percent motor use.
	} XINPUT_VIBRATION;
	
	void  (__stdcall * XInputEnable)(BOOL enable) = NULL;
	DWORD (__stdcall * XInputSetState)(DWORD dwUserIndex, XINPUT_VIBRATION* pVibration) = NULL;
	DWORD (__stdcall * XInputGetState)(DWORD dwUserIndex, XINPUT_STATE* pState);
#endif

typedef struct {
	int dpad_x, dpad_y;
	float lthumb_x, lthumb_y;
	float rthumb_x, rthumb_y;
	unsigned int buttons[14];
} JoypadState;

#define JOYPAD_UP       0
#define JOYPAD_RIGHT    1
#define JOYPAD_DOWN     2
#define JOYPAD_LEFT     3
#define JOYPAD_ACCEPT   4
#define JOYPAD_CANCEL   5
#define JOYPAD_SKIP     5
#define JOYPAD_MENU     6
#define JOYPAD_SPECIAL  7
#define JOYPAD_SELECT   8
#define JOYPAD_START    9
#define JOYPAD_LMENU    10
#define JOYPAD_RMENU    11
#define JOYPAD_LMENU2   12
#define JOYPAD_RMENU2   13

typedef struct {
	int passtime;
	int time;
	float left, right;
} VibrationInfo;

class Joypad { public:
	JoypadState now;
	JoypadState before;
	static VibrationInfo vibrationInfo;

	static void setVibrationRaw(float left, float right) {
		#ifdef WIN32
			XINPUT_VIBRATION vibration;
			vibration.wLeftMotorSpeed  = left  * 60000;
			vibration.wRightMotorSpeed = right * 60000;
			if (XInputSetState) XInputSetState(0, &vibration);
		#endif
	}

	static int vibrationThread(void *_info) {
		VibrationInfo *info = (VibrationInfo *)_info;
		while (1) {
			while (info->passtime <= info->time) {
				float stepf = sin(M_PI * ((float)info->passtime / (float)info->time));
				//printf("%f, %f, %f\n", left, right, stepf);
				setVibrationRaw(info->left * stepf, info->right * stepf);
				SDL_Delay(1);
				info->passtime++;
			}
			SDL_Delay(1);
		}
		return 0;
	}
	
	void setVibration(float left, float right, int time = 20, int wait = 0) {
		if (wait) waitVibration();
		vibrationInfo.left = left;
		vibrationInfo.right = right;
		vibrationInfo.passtime = 0;
		vibrationInfo.time = time;
	}
	
	void waitVibration() {
		while (vibrationInfo.passtime < vibrationInfo.time) {
			SDL_Delay(1);
		}
	}
	
	static void initOnce() {
		static int once = 0;
		if (!once) {
			once = 1;
			
			#ifdef WIN32
				HMODULE lib = LoadLibraryA("xinput1_3.dll");
				if (lib) {
					*(void **)&XInputEnable   = (void *)GetProcAddress(lib, "XInputEnable");
					*(void **)&XInputSetState = (void *)GetProcAddress(lib, "XInputSetState");
					*(void **)&XInputGetState = (void *)GetProcAddress(lib, "XInputGetState");
				}
				if (XInputEnable) XInputEnable(TRUE);
				//XINPUT_VIBRATION vibration = {320, 0};
			#endif
			
			SDL_CreateThread(vibrationThread, &vibrationInfo);
		}
	}

	Joypad() {
		initOnce();
		memset(&now, 0, sizeof(now));
		memset(&before, 0, sizeof(before));
	}
	
	~Joypad() {
	}
	
	void update() {
		before = now;

		#ifdef WIN32
			XINPUT_STATE state = {0};

			if (XInputGetState) XInputGetState(0, &state);

			now.lthumb_x = state.Gamepad.sThumbLX / 32768.0f;
			now.lthumb_y = state.Gamepad.sThumbLY / 32768.0f;
			now.rthumb_x = state.Gamepad.sThumbRX / 32768.0f;
			now.rthumb_y = state.Gamepad.sThumbRY / 32768.0f;

			unsigned int buttons = state.Gamepad.wButtons;

			if (buttons & XINPUT_GAMEPAD_DPAD_UP) now.dpad_y = -1;
			else if (buttons & XINPUT_GAMEPAD_DPAD_DOWN) now.dpad_y = +1;
			else now.dpad_y = 0;

			if (buttons & XINPUT_GAMEPAD_DPAD_LEFT) now.dpad_x = -1;
			else if (buttons & XINPUT_GAMEPAD_DPAD_RIGHT) now.dpad_x = +1;
			else now.dpad_x = 0;

			now.buttons[JOYPAD_UP] = buttons & XINPUT_GAMEPAD_DPAD_UP;
			now.buttons[JOYPAD_RIGHT] = buttons & XINPUT_GAMEPAD_DPAD_RIGHT;
			now.buttons[JOYPAD_DOWN] = buttons & XINPUT_GAMEPAD_DPAD_DOWN;
			now.buttons[JOYPAD_LEFT] = buttons & XINPUT_GAMEPAD_DPAD_LEFT;
			
			now.buttons[JOYPAD_ACCEPT] = buttons & XINPUT_GAMEPAD_A;
			now.buttons[JOYPAD_CANCEL] = buttons & XINPUT_GAMEPAD_B;
			now.buttons[JOYPAD_MENU] = buttons & XINPUT_GAMEPAD_X;
			now.buttons[JOYPAD_SPECIAL] = buttons & XINPUT_GAMEPAD_Y;
			now.buttons[JOYPAD_SELECT] = buttons & XINPUT_GAMEPAD_BACK;
			now.buttons[JOYPAD_START] = buttons & XINPUT_GAMEPAD_START;
			now.buttons[JOYPAD_LMENU] = buttons & XINPUT_GAMEPAD_LEFT_THUMB;
			now.buttons[JOYPAD_RMENU] = buttons & XINPUT_GAMEPAD_RIGHT_THUMB;
			now.buttons[JOYPAD_LMENU2] = buttons & XINPUT_GAMEPAD_LEFT_SHOULDER;
			now.buttons[JOYPAD_RMENU2] = buttons & XINPUT_GAMEPAD_RIGHT_SHOULDER;

		#endif
	}
	
	int pressing(int ibutton) {
		if (ibutton < 0 || ibutton >= 14) return 0;
		return now.buttons[ibutton];
	}

	int pressed(int ibutton) {
		if (ibutton < 0 || ibutton >= 14) return 0;
		return !before.buttons[ibutton] && now.buttons[ibutton];
	}
};

VibrationInfo Joypad::vibrationInfo = {0};

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
