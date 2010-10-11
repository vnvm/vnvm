
struct FontGlyph {
	int code;
	int minx, maxx;
	int miny, maxy;
	int advance;
	SDL_Surface *surface;
	int usecount;
};

class Font {
public:
	TTF_Font *ttf;
	int smooth;
	ImplColor color;
	int from, to;
	FontGlyph glyphs[256];
	Bitmap *bitmap;
	Effect *effect;
	
	int tw, th;
	int local_size;
	int characters_per_row;
	int characters_per_column;
	int font_height;
	unsigned short characters_ch[4096];
	unsigned short characters_width[4096];

	static void init()
	{
		if (!TTF_WasInit()) TTF_Init();
	}
	
	FontGlyph *get_glyph(unsigned int ch) {
		return &glyphs[ch % 256];
	}

	void localinit() {
		init();
		this->from = -1;
		this->to = -1;
		printf("FONT_HEIGHT: %d\n", TTF_FontHeight(ttf));
		for (int n = 0; n < 256; n++) {
			SDL_Color color = {0, 0, 0, 0xFF};
			glyphs[n].code = n;
			glyphs[n].surface = TTF_RenderGlyph_Blended(ttf, n, color);
			TTF_GlyphMetrics(ttf, n, &glyphs[n].minx, &glyphs[n].maxx, &glyphs[n].miny, &glyphs[n].maxy, &glyphs[n].advance);
			//glyphs[n].surface = TTF_RenderGlyph_Blended(ttf, n, color);
			//glyphs[n].surface = TTF_RenderGlyph_Solid(ttf, n, color);
			glyphs[n].usecount = 0;
		}
	}
	
	Font() {
		bitmap = Bitmap::create(IMG_Convert_TO_32(IMG_Load("lucon.ttf.png")));
		effect = new Effect("tint");
		characters_per_row = 16;
		characters_per_column = 16;
		font_height = 32;
		for (int n = 0; n < 256; n++) {
			characters_ch[n] = n;
			characters_width[n] = 26;
		}
		tw = bitmap->surface->w / characters_per_row;
		th = bitmap->surface->h / characters_per_column;
	}

	~Font() {
		TTF_CloseFont(this->ttf);
	}
	
	static Font *createFrom(SDL_RWops *src, int size = 12, int smooth = 1)
	{
		Font     *font = NULL;
		TTF_Font *ttf  = NULL;
		{
			if ((font = new Font()) == NULL) goto error;
			if ((ttf  = TTF_OpenFontRW(src, 1, size)) == NULL) goto error;
			{
				font->ttf = ttf;
				font->smooth = smooth;
			}
			font->local_size = size;
			font->localinit();
			return font;
		}
		error:
		{
			if (ttf  != NULL) TTF_CloseFont(ttf);
			if (font != NULL) delete font;
		}
		return NULL;
	}
	
	static Font *create(STRING src, int size = 12, int smooth = 1)
	{
		return createFrom(SDL_RWFromConstMem(src.data, src.len), size, smooth);
	}

	static Font *create(char *name, int size = 12, int smooth = 1)
	{
		return createFrom(SDL_RWFromFile(name, "rb"), size, smooth);
	}
	
	void setColor(ImplColor color)
	{
		float colorf[4];
		this->color = color;
		for (int n = 0; n < 4; n++) colorf[n] = (float)color.v[n] / (float)255;
		int test = 0;
		effect->set_vars(EVT_FLOAT, "ccolor", 4, colorf);
	}

	void setSlice(int from, int to)
	{
		this->from = from;
		this->to   = to;
	}
	
	void _tint_surface(SDL_Surface *surface, SDL_Color *color) {
		int bpp = surface->format->BytesPerPixel;
		int total_size = surface->pitch * surface->h;
		unsigned char *pixels = (unsigned char *)surface->pixels;
		SDL_LockSurface(surface);
		{
			for (int n = 0; n < total_size; n += bpp) {
				pixels[n + 2] = color->r;
				pixels[n + 1] = color->g;
				pixels[n + 0] = color->b;
			}
		}
		SDL_UnlockSurface(surface);
	}
	
	void renderGlyph(unsigned short ch, int x, int y) {
		int tx = ch % characters_per_row;
		int ty = ch / characters_per_row;
		//printf("%d, %d, %d, %d, %d, %d\n", x, y, tx, ty, tw, th);
		Bitmap::gl_draw_slice(x, y, tx * tw, ty * th, tw, th);
	}
	
	void print2(char *text, int x, int y)
	{
		int text_len = strlen(text);
		
		//printf("%08X, %s, %d, %d\n", to, text, x, y);
		//if (x > dst_bmp->clip.w || y > dst_bmp->clip.h) return;
		if (!text_len) return;
		
		//SDL_Rect rect = {x, y, 0, 0};
		int sy = y;
		int sx = x;
		for (int n = 0; n < text_len; n++) {
			bool showGlyph = (from == -1 && to == -1) || (n >= from && n < to);
			//text[n]
			int ch = (unsigned char)text[n];
			if (ch == '\n') {
				//y2 += TTF_FontLineSkip(ttf);
				y += th + 2;
				x = sx;
			} else {
				/*
				FontGlyph *glpyh = get_glyph(ch);
				if (glpyh != NULL) {
					if ((from == -1 && to == -1) || (n >= from && n < to)) {
						if (glpyh->surface != NULL) {
							rect.y = y2 + TTF_FontAscent(ttf) - glpyh->maxy;
							_tint_surface(glpyh->surface, (SDL_Color *)&color);
							SDL_BlitSurface(glpyh->surface, NULL, dst_bmp->surface, &rect);
						}
					}
					rect.x += glpyh->advance;
				}
				*/
				if (showGlyph) {
					renderGlyph(ch, x, y);
				}
				x += characters_width[ch];
			}
		}
	}
	
	void print(Bitmap *dst_bmp, char *text, int x, int y)
	{
		if ((dst_bmp == NULL) || (text == NULL)) return;
		Video::pushEffect(effect);
		{
			glMatrixMode(GL_MODELVIEW); glLoadIdentity();
			glTranslatef(x, y, 0);
			float scale = ((float)local_size / (float)font_height) * 0.76;
			glScalef(scale, scale, 1.0);
			dst_bmp->gl_render_to();
			bitmap->gl_bind();
			print2(text, 0, 0);
		}
		Video::popEffect();
	}
};
