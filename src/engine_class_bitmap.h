#define SQTAG_Bitmap (SQUserPointer)0x80000000
//DSQ_RELEASE_AUTO_RELEASECAPTURE(Bitmap);
DSQ_RELEASE_AUTO(Bitmap);

DSQ_METHOD(Bitmap, constructor)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, width, 0);
	EXTRACT_PARAM_INT(3, height, 0);
	EXTRACT_PARAM_INT(4, bpp, 32);

	Bitmap *self = Bitmap::create(width, height, bpp);
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Bitmap));
	return 0;
}

DSQ_METHOD(Bitmap, _typeof)
{
	RETURN_STR("Bitmap");
}

DSQ_METHOD(Bitmap, _tostring)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);

	char temp[64];
	sprintf(temp, "Bitmap(0x%08X, %d, %d, %d, %d)", self, (int)self->clip.x, (int)self->clip.y, (int)self->clip.w, (int)self->clip.h);
	RETURN_STR(temp);
}

DSQ_METHOD(Bitmap, _set)
{
	EXTRACT_PARAM_START();

	if (nargs >= 3) {
		EXTRACT_PARAM_SELF(Bitmap);
		EXTRACT_PARAM_STR(2, s, NULL);
		EXTRACT_PARAM_INT(3, vi, 0);
		
		char *c = (char *)s.data;
		
		if (strcmp(c, "x" ) == 0) self->clip.x  = vi;
		else if (strcmp(c, "y" ) == 0) self->clip.y  = vi;
		else if (strcmp(c, "w" ) == 0) self->clip.w  = vi;
		else if (strcmp(c, "h" ) == 0) self->clip.h  = vi;
		else if (strcmp(c, "cx") == 0) self->cx      = vi;
		else if (strcmp(c, "cy") == 0) self->cy      = vi;
	}
	
	return 0;
}

DSQ_METHOD(Bitmap, _get)
{
	EXTRACT_PARAM_START();

	if (nargs >= 2) {
		EXTRACT_PARAM_SELF(Bitmap);
		EXTRACT_PARAM_STR(2, s, NULL);
		
		char *c = (char *)s.data;
		
		if (strcmp(c, "x" ) == 0) RETURN_INT(self->clip.x);
		if (strcmp(c, "y" ) == 0) RETURN_INT(self->clip.y);
		if (strcmp(c, "w" ) == 0) RETURN_INT(self->clip.w);
		if (strcmp(c, "h" ) == 0) RETURN_INT(self->clip.h);
		if (strcmp(c, "cx") == 0) RETURN_INT(self->cx);
		if (strcmp(c, "cy") == 0) RETURN_INT(self->cy);
		if (strcmp(c, "memory_size") == 0) RETURN_INT(self->surface->pitch * self->surface->h);
	}
	
	RETURN_VOID;
}

DSQ_METHOD(Bitmap, fromFile)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, s, NULL);
	EXTRACT_PARAM_INT(3, smooth, 1);

	Bitmap *newbmp = Bitmap::createFromFile(s.stringz);
	CREATE_OBJECT(Bitmap, newbmp);
	return 1;
}

DSQ_METHOD(Bitmap, fromStream)
{
	SQStream *data = NULL;
	Bitmap *newbmp = NULL;
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(3, smooth, 1);

	if (SQ_FAILED(sq_getinstanceup(v, 2, (SQUserPointer*)&data, (SQUserPointer)0x80000000)))
	{
		printf("Bitmap.fromStream | not a Stream.\n");
		return SQ_ERROR;
	}

	STRING image_data = STRING_READSTREAM(data);
	{
		newbmp = Bitmap::createFromStream(image_data);
		STRING_FREE(&image_data);
	}
	CREATE_OBJECT(Bitmap, newbmp);
	return 1;
}

DSQ_METHOD(Bitmap, fromData)
{
	SQStream *image = NULL, *pal_data = NULL;
	int pal_swap[4] = {0, 1, 2, 3};
	int width = 0, height = 0, bpp = 32, interleaved = 1, pal_bpp = 4, pal_bpp_use = 4, flip_x = 0, flip_y = 0;
	Bitmap *bitmap = NULL;
	STRING color_order = {0};
	color_order.stringz = (char *)"rgba";
	//color_order.stringz = "argb";

	EXTRACT_PARAM_START();
	
	if (SQ_FAILED(sq_getinstanceup(v, 2, (SQUserPointer*)&image, (SQUserPointer)0x80000000)))
	{
		printf("Bitmap.fromData | not a Stream.\n");
		return SQ_ERROR;
	}

	sq_pushnull(v);  //null iterator
	while (SQ_SUCCEEDED(sq_next(v, 3))) { //here -1 is the value and -2 is the key
		const SQChar *key; sq_getstring(v, -2, &key);
		{
			if      (strcmp(key, "width"      ) == 0) sq_getinteger(v, -1, &width);
			else if (strcmp(key, "height"     ) == 0) sq_getinteger(v, -1, &height);
			else if (strcmp(key, "color_order") == 0) sq_getstring (v, -1, (const SQChar **)&color_order.stringz);
			else if (strcmp(key, "bpp"        ) == 0) sq_getinteger(v, -1, &bpp);
			else if (strcmp(key, "interleaved") == 0) sq_getinteger(v, -1, &interleaved);
			else if (strcmp(key, "flip_x"     ) == 0) sq_getinteger(v, -1, &flip_x);
			else if (strcmp(key, "flip_y"     ) == 0) sq_getinteger(v, -1, &flip_y);
			else if (strcmp(key, "pal_bpp"    ) == 0) sq_getinteger(v, -1, &pal_bpp);
			else if (strcmp(key, "pal_bpp_use") == 0) sq_getinteger(v, -1, &pal_bpp_use);
			else if (strcmp(key, "pal_swap"   ) == 0) extract_vector_int(v, -1, pal_swap, 4);
			else if (strcmp(key, "pal_data"   ) == 0) {
				if (SQ_FAILED(sq_getinstanceup(v, -1, (SQUserPointer*)&pal_data, (SQUserPointer)0x80000000)))
				{
					pal_data = NULL;
				}
			} else {
				printf("Unknown param '%s' for Bitmap.fromData\n", key);
			}
		}
		sq_pop(v, 2); //pops key and val before the nex iteration
	}
	sq_pop(v, 1); //pops the null iterator
	
	int Bpp = bpp / 8;
	
	//printf("%d\n", Bpp);
	
	//printf("color_order: '%s'\n", color_order.stringz);
	
	unsigned int cmask[4] = {0, 0, 0, 0};
	unsigned int cindex[4] = {0, 0, 0, 0};
	for (int n = 0, l = strlen(color_order.stringz); n < l; n++) {
		char comp = color_order.stringz[n];
		switch (comp) {
			case 'r': cmask[0] = 0xFF << ((3 - n) * 8); cindex[0] = n; break;
			case 'g': cmask[1] = 0xFF << ((3 - n) * 8); cindex[1] = n; break;
			case 'b': cmask[2] = 0xFF << ((3 - n) * 8); cindex[2] = n; break;
			case 'a': cmask[3] = 0xFF << ((3 - n) * 8); cindex[3] = n; break;
		}
	}
	
	if (image) {
		STRING image_data = STRING_READSTREAM(image);
		
		// Palletized.
		if (Bpp == 1)
		{
			STRING pal = {0}; if (pal_data) pal = STRING_READSTREAM(pal_data);
			{
				ImplColor colors[0x100] = {0};
				int ncolors = pal.len / pal_bpp;
				if (pal_data) {
					for (int n = 0; n < ncolors; n++) {
						ubyte *colptr = pal.data + n * pal_bpp;
						for (int m = 0; m < pal_bpp_use; m++) colors[n].v[m] = colptr[pal_swap[m]];
						for (int m = pal_bpp_use; m < 4; m++) colors[n].v[m] = 0xFF;
					}
				}
				bitmap = Bitmap::createFrom(image_data, width, height, 8, ncolors, colors);
			}
			STRING_FREE(&pal);
		}
		// Truecolor.
		else {
			STRING data_str;
			data_str.data = (ubyte *)malloc(width * height * 4);
			data_str.len = width * height * 4;
			char *data = (char *)data_str.data;
			int size = width * height;
			char *src = (char *)image_data.data;
			
			if (interleaved) {
				char *ptr = data;
				while (size-- > 0) {
					for (int n = 0; n < Bpp; n++) ptr[n] = src[cindex[n]];
					for (int n = 3; n >= Bpp; n--) ptr[n] = 0xFF;
					ptr += 4;
					src += Bpp;
				}
			} else {
				for (int n = 0; n < 4; n++) {
					char *ptr = data + cindex[n];
					if (n < Bpp) {
						for (int m = 0; m < size; m++, ptr += 4) *ptr = *src++;
					} else {
						for (int m = 0; m < size; m++, ptr += 4) *ptr = 0xFF;
					}
				}
			}

			//bitmap = Bitmap::createFrom(data_str, width, height, 32, 0, NULL, cmask[0], cmask[1], cmask[2], cmask[3]);
			bitmap = Bitmap::createFrom(data_str, width, height, 32, 0, NULL, 0xFF000000, 0x00FF0000, 0x0000FF00, 0x000000FF);
			free(data);
		}
		STRING_FREE(&image_data);
	}
	
	if (bitmap) {
		bitmap->flip_x = flip_x;
		bitmap->flip_y = flip_y;
		CREATE_OBJECT(Bitmap, bitmap);
		return 1;
	} else {
		return 0;
	}
}

DSQ_METHOD(Bitmap, slice)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_INT(2, x, 0);
	EXTRACT_PARAM_INT(3, y, 0);
	EXTRACT_PARAM_INT(4, w, -1);
	EXTRACT_PARAM_INT(5, h, -1);

	Bitmap *newbmp = self->slice(x, y, w, h);
	CREATE_OBJECT(Bitmap, newbmp);
	return 1;
}

DSQ_METHOD(Bitmap, dup)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);

	Bitmap *newbmp = self->dup();
	CREATE_OBJECT(Bitmap, newbmp);
	return 1;
}

DSQ_METHOD(Bitmap, clear)
{
	static int swizzle[] = {2, 1, 0, 3};
	float fcolor[4] = {0, 0, 0, 1};
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_COL(2, fcolor);

	ImplColor color = {0}; for (int n = 0; n < 4; n++) color.v[n] = (unsigned char)(fcolor[swizzle[n]] * 0xFF);
	self->clear(color);
	return 0;
}

DSQ_METHOD(Bitmap, split)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	
	EXTRACT_PARAM_INT(2, w, 64);
	EXTRACT_PARAM_INT(3, h, w);
	EXTRACT_PARAM_INT(4, cx, 0);
	EXTRACT_PARAM_INT(5, cy, 0);
	
	sq_newarray(v, 0);
	for (int y = 0; y < self->clip.h; y += h) {
		for (int x = 0; x < self->clip.w; x += w) {
			Bitmap *newbmp = self->slice(x, y, w, h);
			newbmp->cx = cx;
			newbmp->cy = cy;
			CREATE_OBJECT(Bitmap, newbmp);
			sq_arrayappend(v, -4);
			sq_pop(v, 2);
		}
	}

	return 1;
}

DSQ_METHOD(Bitmap, drawBitmap)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_OBJ(2, Bitmap, src);
	EXTRACT_PARAM_INT(3, x, 0);
	EXTRACT_PARAM_INT(4, y, 0);
	EXTRACT_PARAM_FLO(5, alpha, 1.0);
	EXTRACT_PARAM_FLO(6, size, 1.0);
	EXTRACT_PARAM_FLO(7, angle, 0.0);
	
	if (self != src) {
		self->drawBitmap(src, x, y, alpha, size, angle);
	}

	return 0;
}

DSQ_METHOD(Bitmap, drawFillRect)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_INT(2, x, 0);
	EXTRACT_PARAM_INT(3, y, 0);
	EXTRACT_PARAM_INT(4, w, -1);
	EXTRACT_PARAM_INT(5, h, -1);
	
	self->drawFillRect(x, y, w, h);

	return 0;
}

DSQ_METHOD(Bitmap, copyChannel)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_OBJ(2, Bitmap, mask);
	EXTRACT_PARAM_STR(3, channel_from, "red");
	EXTRACT_PARAM_STR(4, channel_to, "alpha");
	EXTRACT_PARAM_INT(5, invert, 0);
	
	self->copyChannel(mask, channel_from.stringz, channel_to.stringz, invert);
	RETURN_VOID;
}

DSQ_METHOD(Bitmap, save)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_STR(2, name, NULL);
	EXTRACT_PARAM_STR(3, format, "bmp");
	
	self->save(name.stringz, format.stringz);

	return 0;
}

DSQ_METHOD(Bitmap, getpixel)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_INT(2, x, 0);
	EXTRACT_PARAM_INT(3, y, 0);
	
	int retval = self->getpixel(x, y);

	RETURN_INT(retval);
}

/*
DSQ_METHOD(Bitmap, setpixel)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_INT(2, x, NULL);
	EXTRACT_PARAM_INT(3, y, NULL);
	EXTRACT_PARAM_INT(4, color, NULL);
	
	self->setpixel(x, y);

	return 0;
}
*/

/*
DSQ_METHOD(Bitmap, setColorKey)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_INT(2, color, 0);
	
	self->setColorKey(color);

	return 0;
}
*/

DSQ_METHOD(Bitmap, setColor)
{
	float colorf[] = {1, 1, 1, 1};
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_COL(2, colorf);
	self->setColorf(colorf);
	return 0;
}

void engine_register_bitmap()
{
	// Bitmap.
	CLASS_START(Bitmap);
	{
		NEWSLOT_METHOD(Bitmap, constructor, 0, "");
		NEWSLOT_METHOD(Bitmap, fromFile, 0, ".s");
		NEWSLOT_METHOD(Bitmap, fromData, 0, "");
		NEWSLOT_METHOD(Bitmap, fromStream, 0, "");
		NEWSLOT_METHOD(Bitmap, _typeof, 0, "");
		NEWSLOT_METHOD(Bitmap, _tostring, 0, ".");
		NEWSLOT_METHOD(Bitmap, _set, 0, ".");
		NEWSLOT_METHOD(Bitmap, _get, 0, ".");
		NEWSLOT_METHOD(Bitmap, slice, 0, ".");
		NEWSLOT_METHOD(Bitmap, split, 0, ".");
		NEWSLOT_METHOD(Bitmap, clear, 0, ".");
		NEWSLOT_METHOD(Bitmap, setColor, 0, ".");
		NEWSLOT_METHOD(Bitmap, drawBitmap, 0, ".");
		NEWSLOT_METHOD(Bitmap, drawFillRect, 0, ".");
		NEWSLOT_METHOD(Bitmap, copyChannel, 0, ".");
		//NEWSLOT_METHOD(Bitmap, setColorKey, 0, ".");
		NEWSLOT_METHOD(Bitmap, dup, 0, ".");
		NEWSLOT_METHOD(Bitmap, save, 0, ".");
		NEWSLOT_METHOD(Bitmap, getpixel, 0, ".");
		//NEWSLOT_METHOD(Bitmap, setpixel, 0, ".");
	}
	CLASS_END;
}
