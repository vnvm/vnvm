#define SQTAG_Screen (SQUserPointer)0x80000100
//DSQ_RELEASE_AUTO(Screen);

DSQ_FUNC(sign)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_FLO(2, r, 0);
	RETURN_FLOAT((r < 0.0) ? -1.0 : ((r > 0.0) ? 1.0 : 0.0) );
}

DSQ_FUNC(printf)
{
	EXTRACT_PARAM_START();
	const char *s = NULL;
	sq_pushroottable(v);
	sq_pushstring(v, "format", -1);
	sq_get(v, -2); //get the function from the root table
	//sq_pushroottable(v); //íthisí (function environment object)
	for (int n = 1; n <= nargs; n++) sq_push(v, n);
	sq_call(v, nargs, 1, 0);
	sq_getstring(v, -1, &s);
	printf("%s", s);
	return 0;
}

DSQ_FUNC(replace)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, base, NULL);
	EXTRACT_PARAM_STR(3, find, NULL);
	EXTRACT_PARAM_STR(4, replace, NULL);
	
	SQChar *replace_str = NULL, *replace_str_base = NULL;
	int outn = 0;
	
	for (int dowrite = 0; dowrite <= 1; dowrite++) {
		int size = 0;
		for (int n = 0; n < base.len;) {
			int found = 1;
			for (int m = 0; m < find.len; m++) {
				if (base.data[n + m] != find.data[m]) {
					found = 0;
					break;
				}
			}
			if (found) {
				if (dowrite) {
					memcpy(replace_str, replace.data, replace.len * sizeof(SQChar));
					replace_str += replace.len * sizeof(SQChar);
				}
				size += replace.len;
				n += find.len;
			} else {
				if (dowrite) {
					*replace_str++ = base.data[n];
				}
				size++;
				n++;
			}
		}
		if (dowrite == 0) {
			replace_str_base = replace_str = sq_getscratchpad(v, size + 1);
		}
	}
	*replace_str++ = '\0';
	RETURN_STR(replace_str_base);
}

DSQ_FUNC(include)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, s, NULL);
	sq_pop(v, 1);
	if (SQ_FAILED(sqstd_dofile(v, (const char *)s.data, 1, 1))) {
		fprintf(stderr, "Can't read '%s'.\n", s.data);
		return 0;
	}
	return 0;
}

static int last_b = 0;

SDL_Rect flip_rects[0x1000];

DSQ_METHOD(Screen, flip_old)
{
	int flip_rects_count = 0;
	EXTRACT_PARAM_START();
	
	if (nargs >= 2) {
		flip_rects_count = sq_getsize(v, 2);
		sq_pushnull(v);
		for (int n = 0; n < flip_rects_count; n++) {
			sq_next(v, 2);
			{
				int rect_count = sq_getsize(v, -1);
				sq_pushnull(v);
				for (int m = 0; m < rect_count; m++) {
					sq_next(v, -2);
					{
						int cval = 0;
						sq_getinteger(v, -1, &cval);
						switch (m) {
							case 0: flip_rects[n].x = cval; break;
							case 1: flip_rects[n].y = cval; break;
							case 2: flip_rects[n].w = cval; break;
							case 3: flip_rects[n].h = cval; break;
						}
					}
					sq_pop(v, 2);
				}
				sq_poptop(v);
			}
			sq_pop(v, 2);
		}
		sq_poptop(v);
	}
	
	//printf("%d\n", flip_rects_count);

	/*if (0)
	{
		SDL_GL_SwapBuffers();
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}
	else*/
	{
		if (flip_rects_count != 0) {
			//printf("%d\n", flip_rects_count);
			for (int n = 0; n < flip_rects_count; n++) {
				SDL_Rect *r = &flip_rects[n];
				//printf("%d, %d, %d, %d\n", r->x, r->y, r->w, r->h);
			}
			SDL_UpdateRects(Video::screen->surface, flip_rects_count, flip_rects);
		} else {
			SDL_Flip(Video::screen->surface);
		}
	}

	return 0;
}

DSQ_METHOD(Screen, flip)
{
	Video::flip();
	RETURN_VOID;
}

DSQ_METHOD(Screen, frame)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, fps, 30);
	//EXTRACT_PARAM_INT(3, doflip, 1);

	//touches_count = 0;
	
	game_frame_events();
	game_frame_delay(1000 / fps);
	
	RETURN_VOID;
}

DSQ_FUNC(time_ms)
{
	RETURN_INT(SDL_GetTicks());
}


DSQ_METHOD(Screen, delay)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, ms, 1000);
	
	game_frame_delay(ms);
	
	RETURN_VOID;
}

DSQ_METHOD(Screen, init)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, width, 640);
	EXTRACT_PARAM_INT(3, height, 480);
	EXTRACT_PARAM_INT(4, real_width, width);
	EXTRACT_PARAM_INT(5, real_height, height);
	
	CREATE_OBJECT(Bitmap, Video::set(width, height, real_width, real_height));
	return 1;
}

DSQ_METHOD(Screen, pushEffect)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_OBJ(2, Effect, effect);
	
	Video::pushEffect(effect);
	RETURN_VOID;
}

DSQ_METHOD(Screen, popEffect)
{
	EXTRACT_PARAM_START();
	Video::popEffect();
	RETURN_VOID;
}

struct BIT_INFO {
	int pos;
	int bits;
	int mask;
};

struct LZ_PARAMS {
	int bufsize;
	int opsize;
	int writepos;
	int comp_bit;
	int debug;
	int bit_count_add;
	int special0;
	int src_pos, dst_pos;
	BIT_INFO bit_pos;
	BIT_INFO bit_count;
};

void print_lz_params(LZ_PARAMS params)
{
	printf("LZ_PARAMS:\n");
	printf("  bufsize:  0x%04X\n", params.bufsize);
	printf("  opsize:   %d\n",     params.opsize);
	printf("  writepos: 0x%04X\n", params.writepos);
	printf("  comp_bit: %d\n",     params.comp_bit);
	printf("  init:     - (unimplemented)\n");
	printf("  debug:    %d\n",     params.debug);
	printf("  bits:\n");
	printf("    position: %d(%d) 0x%04X\n", params.bit_pos.pos, params.bit_pos.bits, params.bit_pos.mask);
	printf("    count:    %d(%d) 0x%04X +%d\n", params.bit_count.pos, params.bit_count.bits, params.bit_count.mask, params.bit_count_add);
	printf("\n");
}

#define LZ_INC(var) var = (var + 1) & MASK
#define LZ_INSERT(value) *dst++ = ringbuf[ringpos_write] = value; LZ_INC(ringpos_write)

// Generic LZ decoding.
int lz_decode(STRING in, STRING out, LZ_PARAMS &params)
{
	ubyte *ringbuf = (ubyte *)malloc(params.bufsize);
	//memset(ringbuf, 0, params.bufsize);
	uint ringpos_write = params.writepos, ops;
	ubyte *src = in.data, *dst = out.data;
	ubyte *src_end = in.data + in.len, *dst_end = out.data + out.len;
	int MASK = (params.bufsize - 1);
	
	if (ringbuf != NULL) {
		if (params.opsize == 1) {
			while (src < src_end) for (ops = *src++ | 0x100; ops != 1; ops >>= 1) {
				if (src + 1 >= src_end) break;
				if (dst + 1 >= dst_end) break;

				// Compressed
				if ((ops & 1) == params.comp_bit) {
					ushort data, ringpos_read;
					ubyte count;
					
					if (src + 2 >= src_end) break;
					
					data  = *src++ << 8;
					data |= *src++;
					count        = ((data >> params.bit_count.pos) & params.bit_count.mask) + params.bit_count_add;
					ringpos_read = ((data >> params.bit_pos.pos  ) & params.bit_pos.mask  );
					
					if (ringpos_read == 0) break;
					if (dst + count > dst_end) break;
					
					while (count--) {
						LZ_INSERT(ringbuf[ringpos_read]);
						LZ_INC(ringpos_read);
					} //while
				}
				// Uncompressed
				else {
					LZ_INSERT(*src++);
				} // else
			} // while, for
		}
		
		free(ringbuf);
	}
	
	params.src_pos = src - in.data;
	params.dst_pos = dst - out.data;
	return params.dst_pos;
}

// Dividead lz decoding.
int lz_decode_dividead(STRING src, STRING dst, LZ_PARAMS &params)
{
	ubyte ring[0x1000]; ushort rinp = 0xFEE; int n;
	for (n = 0; n < 0x1000; n++) ring[n] = 0;
	ubyte *i = (ubyte *)src.data, *ie  = (ubyte *)src.data + src.len;
	ubyte *o = (ubyte *)dst.data, *oe = (ubyte *)dst.data + dst.len;
	
	while (i < ie && o < oe) {
		uint code = *i | 0x100;
		for (i++; code != 1; code >>= 1) {
			if (code & 1) {
				ring[rinp++] = *o++ = *i++;
				rinp &= 0xFFF;
			} else {
				ubyte l, h;
				if (i >= ie) break;
				l = *i++; h = *i++;
				ushort d = l | (h << 8);
				ushort p = (d & 0xFF) | ((d >> 4) & 0xF00);
				ushort s = ((d >> 8) & 0xF) + 3;
				while (s--) {
					*o++ = ring[rinp++] = ring[p++];
					p &= 0xFFF; rinp &= 0xFFF;
				}
			}
		}
	}

	params.src_pos = i - src.data;
	params.dst_pos = o - dst.data;
	return params.dst_pos;
}

// Shuffle! LZ decoding.
int lz_decode_shuffle(STRING src, STRING dst, LZ_PARAMS &params)
{
	ubyte *i = src.data, *ie = src.data + src.len;
	ubyte *o = dst.data, *oe = dst.data + dst.len;
	
	while (i < ie) {
		uint fields = (uint)(*(i++)) | (1 << 8);
		for (; !(fields & (1 << 16)); fields <<= 1) {
			// Uncompressed
			if (fields & 0x80) {
				if (i >= ie) break;
				if (o >= oe) break;
				*(o++) = *(i++);
			}
			// Compressed
			else {
				if (o + 2 >= oe) break;
				ushort z = *(ushort *)i;
				uint lz_len = ((z >> 0) & 0x00F) + 2;
				uint lz_off = ((z >> 4) & 0xFFF) + 1;
				while (lz_len--) *(o++) = *(o - lz_off);
				i += 2;
			}
		}
	}

	params.src_pos = i - src.data;
	params.dst_pos = o - dst.data;
	return params.dst_pos;
}

// True Love LZ decoding.
int lz_decode_tlove(STRING vsrc, STRING vdst, LZ_PARAMS &params)
{
	ubyte *dst = vdst.data, *dste = dst + vdst.len;
	ubyte *src = vsrc.data, *srce = src + vsrc.len;
	
	//params.debug = 1;
	
	if (params.debug) printf("IN(%08X), OUT(%08X) {\n", vsrc.len, vdst.len);
	
	while ((dst < dste) && (src < srce))
	{
		int c = *src++;
		
		//printf("CODE: %02X\n", c);
	
		// LZ
		if (c & 0x80) { c &= ~0x80; // 0b10000000;
			int offset = ((c & 0xF) << 8) | *src++;
			c = (c >> 4) & 0xF;

			if (c) c += 2; else c = *src++ + 0x0A;
			
			if (dst + c > dste) { c = dste - dst; }

			if (params.debug) printf("  %06X | %06X: PATTERN OFFSET(%d) LENGTH(%d)\n", dst - vdst.data, src - vsrc.data, offset, c);
			while (c--) *dst++ = dst[-offset - 1];
		}
		// RLE
		else if (c & 0x40) { c &= ~0x40; // 0b01000000
			if (!c) c = *src++ + 0x40;
			c++;
			
			if (dst + c > dste) { c = dste - dst; }

			if (params.debug) printf("  %06X | %06X: REPEAT LAST BYTE(%02X) TIMES(%d)\n", dst - vdst.data, src - vsrc.data, dst[-1], c);
			memset(dst, dst[-1], c);
			dst += c;
		}
		// Uncompressed block.
		else {
			if (!c) c = *src++ + 0x40;
			
			if (dst + c > dste) { c = dste - dst; }
			
			while (c--) {
				if (params.debug) printf("  %06X | %06X: REPEAT BYTE(%02X) TIMES(%d)\n", dst - vdst.data, src - vsrc.data, *src, c);
				*dst++ = *src++;
			}
		}
	}
	
	if (params.debug) printf("}\n");

	params.src_pos = src - vsrc.data;
	params.dst_pos = dst - vdst.data;
	return params.dst_pos;
}

typedef int (* LZ_DECODE_CALLBACK)(STRING in, STRING out, LZ_PARAMS &params);

DSQ_FUNC(lz_decode)
{
	SQStream *self = NULL;
	LZ_PARAMS params = {0};
	params.bufsize   = 0x1000;
	params.opsize    = 1;
	params.writepos  = 0;
	params.comp_bit  = 0;
	params.bit_count_add = 3;
	params.special0 = 0;
	LZ_DECODE_CALLBACK _lz_decode_func = lz_decode;
	
	//int(int *)(const void*, const void*) func;
	//int (STRING in, STRING out, LZ_PARAMS params) func;

	if (SQ_FAILED(sq_getinstanceup(v, 2, (SQUserPointer*)&self, (SQUserPointer)(0x80000000)))) {
		printf("lz_decode: Not a Stream!\n");
		return SQ_ERROR;
	}

	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(3, max_size, 0);
	
	//printf("go!\n");

	sq_pushnull(v);  //null iterator
	while (SQ_SUCCEEDED(sq_next(v, -2))) //here -1 is the value and -2 is the key
	{
		const SQChar *key; sq_getstring(v, -2, &key);
		
		//printf("key: %s\n", key);
		if      (strcmp(key, "bufsize" ) == 0) sq_getinteger(v, -1, &params.bufsize);
		else if (strcmp(key, "opsize"  ) == 0) sq_getinteger(v, -1, &params.opsize);
		else if (strcmp(key, "writepos") == 0) sq_getinteger(v, -1, &params.writepos);
		else if (strcmp(key, "comp_bit") == 0) sq_getinteger(v, -1, &params.comp_bit);
		else if (strcmp(key, "bit_count_add") == 0) sq_getinteger(v, -1, &params.bit_count_add);
		else if (strcmp(key, "init"    ) == 0) { } // TODO
		else if (strcmp(key, "special" ) == 0) {
			const SQChar *value; sq_getstring(v, -1, &value);
			if      (strcmp(value, "tlove"   ) == 0) _lz_decode_func = lz_decode_tlove;
			else if (strcmp(value, "dividead") == 0) _lz_decode_func = lz_decode_dividead;
			else if (strcmp(value, "shuffle" ) == 0) _lz_decode_func = lz_decode_shuffle;
			else printf("Unknown special lz decoding: '%s'\n", value);
		}
		else if (strcmp(key, "debug"   ) == 0) sq_getinteger(v, -1, &params.debug);
		else if (strcmp(key, "bits"    ) == 0) {
			sq_pushnull(v);  //null iterator
			int cbit = 0;
			BIT_INFO *cur = NULL;
			while (1) {
				if (!SQ_SUCCEEDED(sq_next(v, -2))) break;
				{
					const SQChar *value; sq_getstring(v, -1, &value);
					if      (strcmp(value, "position") == 0) cur = &params.bit_pos;
					else if (strcmp(value, "count"   ) == 0) cur = &params.bit_count;
					else cur = NULL;
					sq_pop(v, 2);
				}
				if (!SQ_SUCCEEDED(sq_next(v, -2))) break;
				{
					int bit_count = 0;
					sq_getinteger(v, -1, &bit_count);
					if (cur != NULL) {
						cur->pos = cbit;
						cur->bits = bit_count;
						cur->mask = (1 << bit_count) - 1;
					}
					cbit += bit_count;
					sq_pop(v, 2);
				}
			}
			sq_pop(v, 1);
		}
		else {
			fprintf(stderr, "Unknown param '%s'!\n", key);
		}
		sq_pop(v, 2); //pops key and val before the nex iteration
	}
	sq_pop(v, 1); //pops the null iterator
	
	if (params.debug) print_lz_params(params);
	
	STRING out = STRING_ALLOC(max_size);
	STRING in  = STRING_READSTREAM(self);
	{
		out.len = _lz_decode_func(in, out, params);
		out.len = params.dst_pos;
		if (params.src_pos < in.len) {
			//printf("LEFT BYTES! (%06X/%06X)\n", params.src_pos, in.len);
		}

		char *blobp = (char *)sqstd_createblob(v, out.len);
		memcpy(blobp, out.data, out.len);
	}
	STRING_FREE(&in);
	STRING_FREE(&out);

	return 1;
}

void engine_register_screen()
{
	// Screen.
	CLASS_START(Screen);
	{
		NEWSLOT_METHOD(Screen, init, 0, "");
		NEWSLOT_METHOD(Screen, frame, 0, "");
		NEWSLOT_METHOD(Screen, delay, 0, "");
		NEWSLOT_METHOD(Screen, flip, 0, "");
		NEWSLOT_METHOD(Screen, pushEffect, 0, "");
		NEWSLOT_METHOD(Screen, popEffect, 0, "");
	}
	CLASS_END;
}

#include "engine_iconv.h"

DSQ_FUNC(iconv)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, in_charset_name, NULL);
	EXTRACT_PARAM_STR(3, out_charset_name, NULL);
	EXTRACT_PARAM_STR(4, text, NULL);
	
	void *out_ptr = NULL;
	int out_len = 0;
	
	iconv(
		in_charset_name.stringz,
		out_charset_name.stringz,
		text.stringz,
		text.len,
		&out_ptr,
		&out_len
	);
	
	sq_pushstring(v, (char *)out_ptr, out_len);
	return 1;
}

#include "engine_md5.h"

/*
extern void MD5_Init(MD5_CTX *ctx);
extern void MD5_Update(MD5_CTX *ctx, void *data, unsigned long size);
extern void MD5_Final(unsigned char *result, MD5_CTX *ctx);
*/

DSQ_FUNC(md5)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, input, NULL);
	EXTRACT_PARAM_INT(1, output_binary, 0);
	
	unsigned char output_bin[16];
	MD5_CTX ctx;
	MD5_Init(&ctx);
	MD5_Update(&ctx, input.stringz, input.len);
	MD5_Final(output_bin, &ctx);
	if (output_binary) {
		sq_pushstring(v, (const SQChar *)output_bin, 16);
	} else {
		unsigned char output_str[32];
		static const char hex_chars[] = "0123456789abcdef";
		for (int n = 0; n < 16; n++) {
			output_str[n * 2 + 0] = hex_chars[(output_bin[n] >> 4) & 0xF];
			output_str[n * 2 + 1] = hex_chars[(output_bin[n] >> 0) & 0xF];
		}

		sq_pushstring(v, (const SQChar *)output_str, 32);
	}
	return 1;
}

DSQ_FUNC(xor_string)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, input, NULL);
	EXTRACT_PARAM_STR(3, mask, NULL);
	
	//printf("%d, %d\n", input.len, mask.len);

	char *output = (char *)sq_getscratchpad(v, input.len);
	for (int n = 0; n < input.len; n++) {
		output[n] = input.stringz[n] ^ mask.stringz[n % mask.len];
	}
	
	sq_pushstring(v, output, input.len);
	return 1;
}

void engine_register_functions()
{
	NEWSLOT_FUNC(printf, 0, "");
	NEWSLOT_FUNC(include, 0, "");

	NEWSLOT_FUNC(sign, 0, "");
	NEWSLOT_FUNC(replace, 0, "");
	
	NEWSLOT_FUNC(iconv, 0, "");
	NEWSLOT_FUNC(md5, 0, "");
	NEWSLOT_FUNC(xor_string, 0, "");

	NEWSLOT_FUNC(lz_decode, 0, "");
	
	NEWSLOT_FUNC(time_ms, 0, "");
}
