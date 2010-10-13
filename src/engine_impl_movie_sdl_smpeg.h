#include "smpeg/smpeg.h"

class Movie { public:
    SMPEG* mpeg;
	SDL_Surface *surface;
    SMPEG_Info mpeg_info;
	SDL_Rect rect;
	static Movie *movie;
	static int updated_surface, last_updated_surface;
	
	Movie() {
		mpeg = NULL;
		surface = NULL;
		movie = this;
		updated_surface = 0;
		last_updated_surface = -1;
	}

	~Movie() {
		unload();
	}
	
	int width () { return mpeg_info.width; }
	int height() { return mpeg_info.height; }
	
	void load(char *file_name) {
		updated_surface = 0;
		last_updated_surface = -1;
		//mpeg = SMPEG_new_rwops(RING_RW_open(SDL_RWFromFile(file_name, "rw"), 0x200000, 0x2000), &mpeg_info, 0);
		unload();
		mpeg = SMPEG_new(file_name, &mpeg_info, 0);

		if (0) {
			printf("\n");
			printf("MOVIE('%s') {\n", file_name);
			printf(" mpeg : %08X\n", mpeg);
			printf(" VIDEO: %d\n", mpeg_info.has_video);
			printf(" AUDIO: %d (%s)\n", mpeg_info.has_audio, mpeg_info.audio_string);
			printf(" SIZE : %dx%d\n", mpeg_info.width, mpeg_info.height);
			printf(" FPS  : %f\n", (float)mpeg_info.current_fps);
			printf(" TIME : %f\n", (float)mpeg_info.total_time);
			printf("}...");
		}
		
		if ((mpeg == NULL) || (mpeg_info.width == 0)) { printf("Invalid file\n"); return; }
		
		surface = SDL_CreateRGBSurface(SDL_SWSURFACE, mpeg_info.width, mpeg_info.height, 32, 0xFF000000, 0x00FF0000, 0x0000FF00, 0x000000FF);
		
		if (0) {
			printf("Ok\n");
		}
		rect.y = rect.x = 0;
		rect.w = width();
		rect.h = height();
		center();
		//rect.x = 100;
		//rect.y = 100;
	}
	
	void viewport(int x1, int y1, int x2, int y2) {
		rect.x = x1;
		rect.y = y1;
		rect.w = x2 - x1;
		rect.h = y2 - y1;
		if (0) {
			printf("Movie.viewport(%d, %d, %d, %d)\n", rect.x, rect.y, rect.w, rect.h);
		}
	}
	
	void unload() {
		if (surface != NULL) {
			SDL_FreeSurface(surface);
			surface = NULL;
		}
		if (mpeg != NULL) {
			stop();
			SMPEG_delete(mpeg);
			mpeg = NULL;
		}
	}
	
	void stop() {
		if (mpeg == NULL) return;
		SMPEG_stop(mpeg);
		Mix_HookMusic(NULL, NULL);
	}
	
	bool playing() {
		if (mpeg == NULL) return false;
		return (SMPEG_status(mpeg) == SMPEG_PLAYING);
	}
	
	void center() {
		rect.x = Video::screen->surface->w / 2 - mpeg_info.width / 2;
		rect.y = Video::screen->surface->h / 2 - mpeg_info.height / 2;
	}
	
	static void updateSurface(SDL_Surface *surface, int x, int y, unsigned int w, unsigned int h) {
		//printf("updateSurface\n");
		updated_surface++;
	}

	void update() {
		#ifdef USE_OPENGL
			Video::screen->gl_render_to();
			if (last_updated_surface != updated_surface) {
				last_updated_surface = updated_surface;
				ImplColor color = {0, 0, 0, 255};
				Video::screen->clear(color);
				Bitmap::gl_unbind();
				glRasterPos2i(0, 0);
				glPixelZoom(1.0f, -1.0f);
				glDrawPixels(surface->w, surface->h, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, surface->pixels);
				SDL_GL_SwapBuffers();
			}
		#endif
	}

	void play(int skip = 0) {
		if (mpeg == NULL) return;
		SMPEG_enableaudio(mpeg, 0);
		
		if (1)
		{
			SDL_AudioSpec audiofmt;
			Uint16 format;
			int freq, channels;

			Mix_QuerySpec(&freq, &format, &channels);
			audiofmt.format = format;
			audiofmt.freq = freq;
			audiofmt.channels = channels;
			SMPEG_actualSpec(mpeg, &audiofmt);

			Mix_HookMusic(SMPEG_playAudioSDL, mpeg);
			SMPEG_enableaudio(mpeg, 1);
		}

		int rw = mpeg_info.width;
		int rh = mpeg_info.height;

		//typedef void(*SMPEG_DisplayCallback)(SDL_Surface* dst, int x, int y, unsigned int w, unsigned int h);
		#ifdef USE_OPENGL
			SMPEG_setdisplay(mpeg, surface, NULL, updateSurface);
		#else
			SMPEG_setdisplay(mpeg, Video::screen->surface, NULL, NULL);
		#endif
		SMPEG_move(mpeg, rect.x, rect.y);
		SMPEG_scaleXY(mpeg, rect.w, rect.h);
		SMPEG_filter(mpeg, SMPEGfilter_bilinear());

		if (0) {
			printf("Play...");
		}
		SMPEG_play(mpeg);

		if (0) {
			printf("MOVIE_PLAY:END\n");
		}
	}
};

int Movie::updated_surface = 0;
int Movie::last_updated_surface = 0;

Movie *Movie::movie;
