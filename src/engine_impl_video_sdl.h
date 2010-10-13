#include <SDL_syswm.h>
#include <SDL_mouse.h>

#include <iostream>
#include <map>
#include <vector>
#include <utility>
#include <string>
#include <algorithm>

using namespace std;

#ifdef USE_OPENGL
	#define GL_BIND_EXT(func) *((void **)&func##EXT) = wglGetProcAddress(#func "EXT"); if (!func##EXT) { fprintf( stderr, "OpenGL: Can't find function '%s'\n", #func ); exit(-1); }
	#define GL_BIND_NOR(func) *((void **)&func     ) = wglGetProcAddress(#func      ); if (!func     ) { fprintf( stderr, "OpenGL: Can't find function '%s'\n", #func ); exit(-1); }
	#define GL_BIND(func)     *((void **)&func     ) = wglGetProcAddress(#func "EXT"); if (!func     ) { fprintf( stderr, "OpenGL: Can't find function '%s'\n", #func ); exit(-1); }
	#define GL_DEF(type, name) type name = NULL;
	#define GL_DEF_PROC(type, name) PFN##type##PROC name = NULL;

	GL_DEF(PFNGLRENDERBUFFERSTORAGEEXTPROC,   glRenderbufferStorage);
	GL_DEF(PFNGLBINDFRAMEBUFFEREXTPROC,       glBindFramebuffer);
	GL_DEF(PFNGLGENFRAMEBUFFERSEXTPROC,       glGenFramebuffers);
	GL_DEF(PFNGLCHECKFRAMEBUFFERSTATUSEXTPROC,glCheckFramebufferStatus);
	GL_DEF(PFNGLFRAMEBUFFERTEXTURE2DEXTPROC,  glFramebufferTexture2D);
	GL_DEF(PFNGLBLENDFUNCSEPARATEPROC,        glBlendFuncSeparate);

	//GL_DEF(PFN PROC, glCreateProgram);

	GL_DEF(PFNGLCREATESHADERPROC    , glCreateShader);
	GL_DEF(PFNGLCREATEPROGRAMPROC   , glCreateProgram);
	GL_DEF(PFNGLDELETEPROGRAMPROC   , glDeleteProgram);
	GL_DEF(PFNGLDELETESHADERPROC    , glDeleteShader);
	GL_DEF(PFNGLGETSHADERIVPROC     , glGetShaderiv);
	GL_DEF(PFNGLGETSHADERINFOLOGPROC, glGetShaderInfoLog);
	GL_DEF(PFNGLSHADERSOURCEPROC    , glShaderSource);
	GL_DEF(PFNGLCOMPILESHADERPROC   , glCompileShader);
	GL_DEF(PFNGLATTACHSHADERPROC    , glAttachShader);
	GL_DEF(PFNGLLINKPROGRAMPROC     , glLinkProgram);
	GL_DEF(PFNGLUSEPROGRAMPROC      , glUseProgram);
	GL_DEF(PFNGLGETUNIFORMLOCATIONPROC, glGetUniformLocation);
	GL_DEF(PFNGLUNIFORM1IVPROC      , glUniform1iv);
	GL_DEF(PFNGLUNIFORM1FVPROC      , glUniform1fv);
	GL_DEF(PFNGLUNIFORM2IVPROC      , glUniform2iv);
	GL_DEF(PFNGLUNIFORM2FVPROC      , glUniform2fv);
	GL_DEF(PFNGLUNIFORM3IVPROC      , glUniform3iv);
	GL_DEF(PFNGLUNIFORM3FVPROC      , glUniform3fv);
	GL_DEF(PFNGLUNIFORM4IVPROC      , glUniform4iv);
	GL_DEF(PFNGLUNIFORM4FVPROC      , glUniform4fv);
	GL_DEF(PFNGLACTIVETEXTUREPROC   , glActiveTexture);

	//glBlendFuncSeparate

	void gl_ext_prepare()
	{
		static int initialized = 0; if (initialized) return;

		GL_BIND(glBlendFuncSeparate);
		GL_BIND(glRenderbufferStorage);
		GL_BIND(glBindFramebuffer);
		GL_BIND(glGenFramebuffers);
		GL_BIND(glCheckFramebufferStatus);
		GL_BIND(glFramebufferTexture2D);

		GL_BIND_NOR(glCreateShader);
		GL_BIND_NOR(glCreateProgram);
		GL_BIND_NOR(glDeleteProgram);
		GL_BIND_NOR(glDeleteShader);
		GL_BIND_NOR(glGetShaderiv);
		GL_BIND_NOR(glGetShaderInfoLog);
		GL_BIND_NOR(glShaderSource);
		GL_BIND_NOR(glCompileShader);
		GL_BIND_NOR(glAttachShader);
		GL_BIND_NOR(glLinkProgram);
		GL_BIND_NOR(glUseProgram);
		GL_BIND_NOR(glGetUniformLocation);
		GL_BIND_NOR(glUniform1iv);
		GL_BIND_NOR(glUniform1fv);
		GL_BIND_NOR(glUniform2iv);
		GL_BIND_NOR(glUniform2fv);
		GL_BIND_NOR(glUniform3iv);
		GL_BIND_NOR(glUniform3fv);
		GL_BIND_NOR(glUniform4iv);
		GL_BIND_NOR(glUniform4fv);
		GL_BIND_NOR(glActiveTexture);

		initialized = 1;
	}
#endif

SDL_Surface *Video_screen = NULL;

typedef struct {
	union {
		struct { unsigned char r, g, b, a; };
		unsigned char v[4];
	};
} ImplColor;

#define ITERATE_ALPHA_START(_color, _alpha) \
	SDL_LockSurface(_color); \
	SDL_LockSurface(_alpha); \
	{ \
		unsigned char *alpha, *color, *end; int ainc, x, y, w, h; \
		ainc  = (_alpha)->format->BytesPerPixel; \
		w = (_color)->w; h = (_color)->h; \
		if ((_alpha)->h < h) h = (_alpha)->h; \
		for (y = 0; y < h; y++) { \
			alpha = (unsigned char *)(_alpha)->pixels + y * (_alpha)->pitch; \
			color = (unsigned char *)(_color)->pixels + (_color)->format->Ashift / 8 + y * (_color)->pitch; \
			for (x = 0; x < w; x++, color += 4, alpha += ainc) {

#define ITERATE_ALPHA_END(_color, _alpha) \
			} \
		} \
	} \
	SDL_UnlockSurface(_color); \
	SDL_UnlockSurface(_alpha);
	
int blend_alpha(int mode, int ca, int step, bool reverse) {
	int a;
	if (reverse) {
		a = step + ca;
	} else {
		a = step + 0xFF - ca;
	}
	if (a > 0xFF) a = 0xFF;
	if (a < 0x00) a = 0x00;
	return a;
}

int mask_alpha(int mode, int ca, int step, bool reverse) {
	if (!reverse) {
		return (ca >= step) ? 0x00 : 0xFF;
	} else {
		return (ca >= 0xFF - step) ? 0xFF : 0x00;
	}
}

void bitmap_shader_invert(SDL_Surface *surface, void *state, int x, int y, ImplColor *inout_color) {
	inout_color->r = 0xFF - inout_color->r;
	inout_color->g = 0xFF - inout_color->g;
	inout_color->b = 0xFF - inout_color->b;
	inout_color->a = *(int *)state;
}

void bitmap_shader(SDL_Surface *buffer, void (* shader)(SDL_Surface *surface, void *state, int x, int y, ImplColor *inout_color), void *state = NULL) {
	int x, y;
	int w = buffer->w, h = buffer->h;
	ImplColor *pixels;
	for (y = 0; y < h; y++) {
		pixels = (ImplColor *)(((char *)buffer->pixels) + y * buffer->pitch);
		for (x = 0; x < w; x++) {
			shader(buffer, state, x, y, &pixels[x]);
		}
	}
}
	
int do_transition_tick(SDL_Surface *buffer, SDL_Surface *transition, float stepf, int mode, bool reverse, bool invert = false) {
	if (buffer == NULL) return -1;
	if (transition == NULL) return -1;

	//printf("(%d, %d) - (%d, %d)", buffer->w, buffer->h, transition->w, transition->h);
	if (buffer->w != transition->w) return -1;
	//if (buffer->h != transition->h) return -1;
	
	//printf("reverse:%d\n", reverse);
	
	if (buffer->format->BytesPerPixel != 4) return -1;
	
	int aindex = 3 - buffer->format->Ashift / 8;
	int step, step_min, step_max;
	
	int (* func)(int, int, int, bool);
	switch (mode) {
		case 1:
			func = mask_alpha;
			step_min = 0x00;
			step_max = 0xFF;
		break;
		case 0:
		default:
			step_min = -0xFF;
			step_max = +0xFF;
			func = blend_alpha;
		break;
	}
	
	step = (int)((stepf * (step_max - step_min)) + step_min);

	ITERATE_ALPHA_START(buffer, transition);

		color[aindex] = func(mode, alpha[0], step, reverse);
		if (invert) {
			color[aindex] = 0xFF - color[aindex];
		}

	ITERATE_ALPHA_END(buffer, transition);
	
	return 0;
}

#define RGBA_MASK 0xFF000000, 0x00FF0000, 0x0000FF00, 0x000000FF
//#define RGBA_MASK 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000
//#define RGBA_MASK 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000
//#define RGBA_MASK Video_screen->format->Rmask, Video_screen->format->Gmask, Video_screen->format->Bmask, Video_screen->format->Amask

SDL_Surface *IMG_Convert_TO_32(SDL_Surface *src, bool free_src = true) {
	SDL_Surface *new_surface = SDL_CreateRGBSurface(SDL_SWSURFACE, src->w, src->h, 32, RGBA_MASK);
	SDL_BlitSurface(src, NULL, new_surface, NULL); 
	if (free_src) SDL_FreeSurface(src);
	return new_surface;
}

struct BitmapSlice {
	int x, y;
	int tx, ty;
	int w, h;
};

class Bitmap {
public:
	SDL_Surface *surface;
	SDL_Rect clip;
	int cx, cy;
	int flip_x, flip_y;
	#ifdef USE_OPENGL
		GLuint gltex;
	#endif
	ImplColor color;
	float colorf[4];
	
	Bitmap()
	{
		color.r = 0xFF;
		color.g = 0xFF;
		color.b = 0xFF;
		color.a = 0xFF;
		colorf[0] = colorf[1] = colorf[2] = colorf[3] = 1.0;
	}

	// Destructs the surface;
	~Bitmap()
	{
		if (surface != NULL) {
			surface->refcount--;
			if (surface->refcount <= 1) {
				SDL_FreeSurface(surface);
				#ifdef USE_OPENGL
					glDeleteTextures(1, &gltex);
				#endif
			}
		}
	}

	/*void setColorKey(int color) {
		SDL_SetColorKey(surface, SDL_SRCCOLORKEY, color);
	}*/
	
	// Sets the palette.
	void colors(ImplColor *col, int count)
	{
		SDL_SetPalette(surface, SDL_LOGPAL, (SDL_Color *)col, 0, count);
	}
	
	bool isScreen()
	{
		return surface == Video_screen;
	}

	#ifdef USE_OPENGL
		void gl_set_color()
		{
			glColor4fv(colorf);
		}

		int gl_gl_updated;
		int gl_sdl_updated;
		
		static int gl_channel_name_to_constant(char *name)
		{
			if (strcmp(name, "red"  ) == 0) return GL_RED;
			if (strcmp(name, "green") == 0) return GL_GREEN;
			if (strcmp(name, "blue" ) == 0) return GL_BLUE;
			if (strcmp(name, "alpha") == 0) return GL_ALPHA;
			return GL_RED;
		}
		
		static Bitmap *lastBitmapBind;

		static void gl_unbind()
		{
			//if (lastBitmapBind != NULL)
			{
				lastBitmapBind = NULL;
				glDisable(GL_BLEND);
				glDisable(GL_TEXTURE_2D);
				glBindTexture(GL_TEXTURE_2D, 0);
				glMatrixMode(GL_TEXTURE); glLoadIdentity();
			}
		}
		
		void gl_bind()
		{
			//if (lastBitmapBind != this)
			{
				lastBitmapBind = this;
				glEnable(GL_BLEND);
				//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
				glEnable(GL_TEXTURE_2D);
				glBindTexture(GL_TEXTURE_2D, gltex);
				glMatrixMode(GL_TEXTURE); glLoadIdentity(); glScalef(1.0 / surface->w, 1.0 / surface->h, 1.0);
			}
		}
		
		static void gl_draw_slice(int x, int y, int tx, int ty, int w, int h) {
			glBegin(GL_QUADS);
				glTexCoord2i(tx + 0, ty + 0); glVertex2i(x + 0, y + 0); 
				glTexCoord2i(tx + w, ty + 0); glVertex2i(x + w, y + 0);
				glTexCoord2i(tx + w, ty + h); glVertex2i(x + w, y + h);
				glTexCoord2i(tx + 0, ty + h); glVertex2i(x + 0, y + h);
			glEnd();
		}

		void gl_draw_clip() {
			gl_draw_slice(0, 0, clip.x, clip.y, clip.w, clip.h);
		}

		void gl_init()
		{
			gl_gl_updated = 0;
			gl_sdl_updated = 0;
			glGenTextures(1, &gltex);
			gl_bind();
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
			switch (surface->format->BitsPerPixel) {
				case 8 : glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, surface->w, surface->h, 0, GL_RED , GL_UNSIGNED_BYTE       , surface->pixels); break;
				case 24: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, surface->w, surface->h, 0, GL_RGB , GL_UNSIGNED_INT_8_8_8_8, surface->pixels); break;
				case 32: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, surface->w, surface->h, 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, surface->pixels); break;
				default:
					fprintf(stderr, "Invalid bpp for opengl\n");
				break;
			}
		}
		
		void gl_render_to()
		{
			static GLuint g_frameBuffer = 0;
			static GLuint g_depthRenderBuffer = 0;
			static GLuint prevTex = -2;
			GLuint curTex = isScreen() ? -1 : gltex;
			
			if (prevTex != curTex) {
				prevTex = curTex;
				//printf("%08X, %08X\n", surface, Video_screen);

				if (isScreen()) {
					if (g_frameBuffer != 0) glBindFramebuffer(GL_FRAMEBUFFER_EXT, 0);
					glPixelZoom(1.0f, -1.0f);
				} else {
					if (g_frameBuffer == 0) {
						glGenFramebuffers(1, &g_frameBuffer);
						glRenderbufferStorage(GL_RENDERBUFFER_EXT, GL_RGBA, surface->w, surface->h);
						GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER_EXT);

						switch (status) {
							case GL_FRAMEBUFFER_COMPLETE_EXT: break;
							case GL_FRAMEBUFFER_UNSUPPORTED_EXT: fprintf(stderr, "GL_FRAMEBUFFER_UNSUPPORTED_EXT!\n"); exit(-1);
							default: fprintf(stderr, "Unknown GL_FRAMEBUFFER error!\n"); exit(-1);
						}
					}

					glBindFramebuffer(GL_FRAMEBUFFER_EXT, g_frameBuffer);
					glFramebufferTexture2D(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, gltex, 0);

					glPixelZoom(1.0f, 1.0f);
				}
				glViewport(0, 0, surface->w, surface->h);
				glRasterPos2i(0, 0);

				glMatrixMode(GL_PROJECTION); glLoadIdentity();

				if (isScreen()) {
					glOrtho(clip.x, clip.x + clip.w, clip.y + clip.h, clip.y, -1.0, 1.0);
					//glOrtho(0.0f, w, h, 0.0f, -1.0f, 1.0f);
				} else {
					glOrtho(clip.x, clip.x + clip.w, clip.y, clip.y + clip.h, -1.0, 1.0);
				}

				glMatrixMode(GL_MODELVIEW); glLoadIdentity();
			}
		}
	#endif
	
	// Create a bitmap from a surface.
	static Bitmap *create(SDL_Surface *surface)
	{
		Bitmap *that = new Bitmap();
		{
			that->surface = surface; that->surface->refcount++;
			that->clip.w = surface ? surface->w : 0;
			that->clip.h = surface ? surface->h : 0;
			that->clip.y = that->clip.x = 0;
			that->cy = that->cx = 0;
			that->flip_y = that->flip_x = 0;
		}
		#ifdef USE_OPENGL
			that->gl_init();
		#endif
		return that;
	}

	// data, width, height, 8, ncolors, colors
	static Bitmap *createFrom(STRING data, int w, int h, int Bpp = 32, int ncolors = 0, ImplColor *colors = NULL, int rmask = 0, int gmask = 0, int bmask = 0, int amask = 0)
	{
		Bitmap *bitmap = create(w, h, Bpp, rmask, gmask, bmask, amask);
		bitmap->colors(colors, ncolors);
		{
			SDL_Surface *surface = bitmap->surface;
			SDL_LockSurface(surface);
			{
				memcpy(surface->pixels, data.data, surface->pitch * h);
			}
			SDL_UnlockSurface(surface);
			// TODO.
			//printf("data.len:%d\n", data.len);
		}
		#ifdef USE_OPENGL
			bitmap->gl_init();
		#endif
		return bitmap;
	}

	// Create an empty bitmap for drawing.
	static Bitmap *create(int w, int h, int Bpp = 32, int rmask = 0, int gmask = 0, int bmask = 0, int amask = 0)
	{
		if (w < 0 || h < 0 || w > 4096 || h > 4096) return NULL;
		
		SDL_Surface *surface = SDL_CreateRGBSurface(SDL_SWSURFACE, w, h, Bpp, rmask, gmask, bmask, amask);
		SDL_FillRect(surface, NULL, 0xFF000000);
		return create(surface);
		//return create(SDL_CreateRGBSurface(SDL_SWSURFACE, w, h, Bpp, 0xFF000000, 0x00FF0000, 0x00000FF00, 0x000000FF));
	}

	// Create a bitmap from a file.
	static Bitmap *createFromRW(SDL_RWops *rw)
	{
		if (rw == NULL)
		{
			fprintf(stderr, "Can't open RW\n");
			return Bitmap::create(1, 1);
		}
		return Bitmap::create(IMG_Convert_TO_32(IMG_Load_RW(rw, 1)));
	}

	// Create a bitmap from a file.
	static Bitmap *createFromFile(char *name)
	{
		SDL_RWops *rw = SDL_RWFromFile(name, "rb");
		if (rw == NULL)
		{
			fprintf(stderr, "Can't locate file '%s'\n", name);
		}
		return Bitmap::createFromRW(rw);
	}
	
	// Create a bitmap from a stream.
	static Bitmap *createFromStream(STRING data)
	{
		return Bitmap::createFromRW(SDL_RWFromConstMem(data.data, data.len));
	}
	
	//void drawSlices(int count, BitmapSlice *slices)
	void drawSlices(Bitmap *src, std::vector<BitmapSlice> slices)
	{
		Bitmap *dst = this;
	
		#ifdef USE_OPENGL
			dst->gl_render_to();
			src->gl_bind();
		
			for (std::vector<BitmapSlice>::iterator slice = slices.begin(); slice != slices.end(); slice++) {
				Bitmap::gl_draw_slice(slice->x, slice->y, slice->tx, slice->ty, slice->w, slice->h);
			}
		#else
			assert(0);
		#endif
	}

	// Creates a slice bitmap of this bitmap.
	Bitmap *slice(int x, int y, int w, int h)
	{
		Bitmap *that = new Bitmap();
		{
			#ifdef USE_OPENGL
				that->gltex = this->gltex;
			#endif
			that->surface = this->surface;
			that->surface->refcount++;
			
			ClampMin(x, 0);
			ClampMin(y, 0);
			ClampMax(w, this->clip.w - x);
			ClampMax(h, this->clip.h - y);
			that->clip.x = x;
			that->clip.y = y;
			that->clip.w = w;
			that->clip.h = h;
			that->cy = that->cx = 0;
			that->flip_y = that->flip_x = 0;
		}
		return that;
	}

	// Duplicates a bitmap.
	Bitmap *dup()
	{
		Bitmap *that;
		//SDL_LockSurface(this->surface);
		{
			that = Bitmap::create(this->clip.w, this->clip.h, this->surface->format->BitsPerPixel);
			#ifdef USE_OPENGL
				assert(0);
			#else
				SDL_BlitSurface(this->surface, NULL, that->surface, NULL); 
			#endif
		}
		//SDL_UnlockSurface(this->surface);
		
		return that;
	}
	
	void drawFillRect(int x, int y, int w, int h)
	{
		if (w == -1) w = Video_screen->w;
		if (h == -1) h = Video_screen->h;
		#ifdef USE_OPENGL
			this->gl_render_to();
			//gl_unbind();
			glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
			glMatrixMode(GL_MODELVIEW); glLoadIdentity(); glTranslatef(x, y, 0);
			glBegin(GL_QUADS);
				glTexCoord2i(x + 0, y + 0); glVertex2i(0, 0); 
				glTexCoord2i(x + w, y + 0); glVertex2i(w, 0);
				glTexCoord2i(x + w, y + h); glVertex2i(w, h);
				glTexCoord2i(x + 0, y + h); glVertex2i(0, h);
			glEnd();
		#else
			assert(0);
		#endif
	}
	
	// Draws a bitmap over another.
	void drawBitmap(Bitmap *src, int x = 0, int y = 0, float alpha = 1.0, float size = 1.0, float angle = 0.0)
	{
		Bitmap *dst = this;
		if ((dst->surface == NULL)) return;
		if ((src == NULL) || (src->surface == NULL)) return;
		if (alpha < 0) alpha = 0;
		if (alpha > 1) alpha = 1;
		#ifdef USE_OPENGL
			dst->gl_render_to();
			src->gl_bind();
			glColor4f(1.0f, 1.0f, 1.0f, alpha);
			
			glMatrixMode(GL_MODELVIEW); glLoadIdentity(); glTranslatef(x, y, 0);
			glRotatef(angle * 57.295779513082, 0, 0, 1);
			glScalef(size, size, 1);
			
			src->gl_draw_clip();
		#else
			assert(0);
			// @TODO: EFFECT
			/*
			SDL_Surface *new_surface = SDL_ConvertSurface(src->surface, src->surface->format, 0);
			if (effect != NULL) {
				int alpha = (int)(stepf * 255);
				if (strcmp(effect, "invert") == 0) bitmap_shader(new_surface, bitmap_shader_invert, &alpha);
				else printf("Unknown effect '%s'\n", effect);
			} else {
				do_transition_tick(new_surface, mask->surface, stepf, mode, reverse);
			}
			SDL_Rect dst_rect = {x - cx, y - cy, 0, 0};
			SDL_SetAlpha(new_surface, SDL_SRCALPHA, 0xFF);
			//SDL_SetAlpha(src->surface, 0, 0xFF);
			SDL_BlitSurface(new_surface, &src->clip, dst->surface, &dst_rect); 
			SDL_FreeSurface(new_surface);
			*/
			/*
			SDL_Rect dst_rect = {x - cx, y - cy, 0, 0};

			SDL_SetClipRect(dst->surface, &dst->clip);

			//printf("alpha: %f\n", alpha);
			if (alpha == 1.0) {
				SDL_SetAlpha(src->surface, SDL_SRCALPHA, 0xFF);
				SDL_BlitSurface(src->surface, &src->clip, dst->surface, &dst_rect); 
			} else {
				int alpha2 = (int)(alpha * 0xFF);
				//SDL_SetAlpha(src->surface, 0, 0xFF);
				SDL_Surface *new_surface = SDL_ConvertSurface(dst->surface, dst->surface->format, 0);
				SDL_LockSurface(new_surface);
				{
					unsigned char *pixels = (unsigned char *)new_surface->pixels;
					int total_size = new_surface->pitch * new_surface->h;
					pixels += 3;
					for (int n = 0; n < total_size; n += 4, pixels += 4) {
						*pixels = (*pixels * alpha2) / 0xFF;
					}
				}
				SDL_UnlockSurface(new_surface);
				SDL_BlitSurface(new_surface, &dst->clip, dst->surface, &dst_rect); 
				SDL_FreeSurface(new_surface);
			}

			//SDL_gfxMultiplyAlpha(dst->surface, (int)(alpha * 0xFF));
			//SDL_gfxBlitRGBA(dst->surface, &dst->clip, dst->surface, &dst_rect);
			*/
		#endif
	}
	
	void save(char *filename) {
		SDL_SaveBMP(this->surface, filename);
	}
	
	int gl_channel_name_to_pos(char *name)
	{
		if (strcmp(name, "red"  ) == 0) return 0;
		if (strcmp(name, "green") == 0) return 1;
		if (strcmp(name, "blue" ) == 0) return 2;
		if (strcmp(name, "alpga") == 0) return 3;
		return 0;
	}
	
	void copyChannel(Bitmap *mask, char *channel_from = "red", char *channel_to = "alpha", int invert = 0)
	{
		#if USE_OPENGL
			int v_channel_from = gl_channel_name_to_constant(channel_from);
			int v_channel_to   = gl_channel_name_to_constant(channel_to);
			glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
			glPixelStorei(GL_PACK_ALIGNMENT, 1);
			int mw = mask->surface->w, mh = mask->surface->h;
			int msize = mw * mh;
			unsigned char *mask_data = (unsigned char *)malloc(msize);
			{
				//mask->gl_render_to();
				//mask->gl_render_to(); glReadPixels(0, 0, mw, mh, v_channel_from, GL_UNSIGNED_BYTE, mask_data);
				mask->gl_bind(); glGetTexImage(GL_TEXTURE_2D, 0, v_channel_from, GL_UNSIGNED_BYTE, mask_data);
				//STRING str = {mask_data, mw * mh}; STRING_FILE_PUT(str, "../game_data/test.bin");
				if (glGetError() > 0) {
					printf("glGetError(): %d\n", glGetError());
				}

				if (!invert) for (int n = 0; n < msize; n++) mask_data[n] = 0xFF - mask_data[n];
				
				switch (v_channel_to) {
					case GL_RED  : glColorMask(1, 0, 0, 0); break;
					case GL_GREEN: glColorMask(0, 1, 0, 0); break;
					case GL_BLUE : glColorMask(0, 0, 1, 0); break;
					case GL_ALPHA: glColorMask(0, 0, 0, 1); break;
				}
				{
					Bitmap::gl_unbind();
					mask->gl_render_to();
					this->gl_render_to();
					glDisable(GL_BLEND);				
					glDrawPixels(mw, mh, v_channel_to, GL_UNSIGNED_BYTE, mask_data);
				}
				glColorMask(1, 1, 1, 1);
			}
			free(mask_data);
		#else
			do_transition_tick(this->surface, mask->surface, 0.5f, 0, 0, invert);
		#endif
	}
	
	void setColor(ImplColor color)
	{
		#ifdef USE_OPENGL
			this->color = color;
			colorf[0] = (float)color.r / (float)0xFF;
			colorf[1] = (float)color.g / (float)0xFF;
			colorf[2] = (float)color.b / (float)0xFF;
			colorf[3] = (float)color.a / (float)0xFF;
		#else
			assert(0);
		#endif
	}

	void setColorf(float colorf[4])
	{
		#ifdef USE_OPENGL
			this->colorf[0] = colorf[0];
			this->colorf[1] = colorf[1];
			this->colorf[2] = colorf[2];
			this->colorf[3] = colorf[3];
		#else
			assert(0);
		#endif
	}
	
	// Clears the bitmap.
	void clear(ImplColor color)
	{
		//if (Video::use_opengl)
		#ifdef USE_OPENGL
			//printf("%d, %d, %d, %d\n", color.r, color.g, color.b, color.a);
			this->gl_render_to();
			glClearColor((float)color.r / 255.0f, (float)color.g / 255.0f, (float)color.b / 255.0f, (float)color.a / 255.0f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			if (!isScreen()) {
				//SDL_FillRect(surface, &clip, *(unsigned int *)&color);
			}
		#else
			SDL_FillRect(surface, &clip, *(unsigned int *)&color);
		#endif
	}
	
	unsigned int getpixel(int x, int y)
	{
		unsigned int value = 0;
		unsigned char value8 = 0;
		#ifdef USE_OPENGL
			this->gl_render_to();
			if (surface->format->BytesPerPixel == 1) {
				glReadPixels(x, y, 1, 1, GL_RED, GL_UNSIGNED_BYTE, &value8);
				value = value8;
			} else {
				glReadPixels(x, y, 1, 1, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, &value);
			}
		#else
			if (x < 0 || y < 0) return -1;
			if (x >= surface->w || y >= surface->h) return 0;
			unsigned char *pa = ((unsigned char *)surface->pixels) + surface->pitch * y + surface->format->BytesPerPixel * x;
			unsigned int bpp = surface->format->BytesPerPixel;
			for (int n = 0, shift = 0; n < bpp; n++, shift += 8) value |= (pa[n] << shift);
		#endif
		return value;
	}
};

#include "engine_impl_video_sdl_effect.h"

class Video
{
public:
	static Bitmap *screen;
	static int rw, rh;
	//static bool use_opengl;

	// Sets the videomode.
	static Bitmap *set(int w, int h, int rw = -1, int rh = -1)
	{
		Video::rw = (rw >= 0) ? rw : w;
		Video::rh = (rh >= 0) ? rh : h;

		int flags = SDL_HWSURFACE | SDL_DOUBLEBUF;
		#ifdef USE_OPENGL
			flags |= SDL_OPENGL;
		#endif
		Video_screen = SDL_SetVideoMode(w, h, 32, flags);
		#ifdef USE_OPENGL
			gl_ext_prepare();
		#endif
		screen = Bitmap::create(Video_screen);
		#ifdef USE_OPENGL
			screen->gl_render_to();
			flip();
		#endif

		return screen;
	}
	
	static void flip()
	{
		#ifdef USE_OPENGL
			SDL_GL_SwapBuffers();
		#else
			SDL_Flip(Video::screen->surface);
		#endif
	}

	static void setEffect(Effect *effect = NULL)
	{
		if (effect) {
			effect->use();
			//printf("Effect: '%s' : %08X\n", effect->effectName, effect);
		} else {
			Effect::unuse();
		}
		//Effect::unuse();
	}

	static vector<Effect *> effect_list;
	static void pushEffect(Effect *effect)
	{
		effect_list.push_back(effect);
		setEffect(effect_list.back());
	}

	static void popEffect()
	{
		if (!effect_list.empty()) effect_list.pop_back();
		setEffect(effect_list.empty() ? NULL : effect_list.back());
	}
};

#ifdef USE_OPENGL
	Bitmap *Bitmap::lastBitmapBind = NULL;
#endif

vector<Effect *> Video::effect_list;

Bitmap *Video::screen = NULL;
//bool Video::use_opengl = false;
int Video::rw = 0;
int Video::rh = 0;
#ifdef USE_OPENGL
	//int Bitmap::gl_gl_updated;
	//int Bitmap::gl_sdl_updated;
#endif

#include "engine_impl_video_sdl_font.h"
