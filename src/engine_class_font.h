#define SQTAG_Font (SQUserPointer)0x80000010
DSQ_RELEASE_AUTO(Font);

DSQ_METHOD(Font, constructor)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, file, "");
	EXTRACT_PARAM_INT(3, size, 12);
	EXTRACT_PARAM_INT(4, smooth, 1);

	Font::init();

	Font *self = Font::create((char *)file.data, size, smooth);
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Font));
	return 0;
}

DSQ_METHOD(Font, setColor)
{
	float fcolor[] = {1, 1, 1, 1};
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Font);
	EXTRACT_PARAM_COL(2, fcolor);
	ImplColor color = {0}; for (int n = 0; n < 4; n++) color.v[n] = (unsigned char)(fcolor[n] * 0xFF);
	self->setColor(color);
	return 0;
}

DSQ_METHOD(Font, setSlice)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Font);
	EXTRACT_PARAM_INT(2, from, 0);
	EXTRACT_PARAM_INT(3, to, 0);
	self->setSlice(from, to);
	return 0;
}

DSQ_METHOD(Font, setSize)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Font);
	EXTRACT_PARAM_FLO(2, size, 0);
	self->setSize(size);
	return 0;
}

DSQ_METHOD(Font, print)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Font);
	EXTRACT_PARAM_OBJ(2, Bitmap, dst); if (dst == NULL) return 0;
	EXTRACT_PARAM_STR(3, text, "");
	EXTRACT_PARAM_INT(4, x, 0);
	EXTRACT_PARAM_INT(5, y, 0);
	self->print(dst, (char *)text.data, x, y);
	return 0;
}

void engine_register_font()
{
	// Font.
	CLASS_START(Font);
	{
		NEWSLOT_METHOD(Font, constructor, 0, "");
		NEWSLOT_METHOD(Font, print, 0, ".");
		NEWSLOT_METHOD(Font, setSlice, 0, ".");
		NEWSLOT_METHOD(Font, setColor, 0, ".");
		NEWSLOT_METHOD(Font, setSize, 0, ".");
	}
	CLASS_END;
}
