#define SQTAG_Sound (SQUserPointer)0x80000011
DSQ_RELEASE_AUTO_RELEASECAPTURE(Sound);
//DSQ_RELEASE_AUTO(Sound);

/*DSQ_METHOD(Audio, constructor)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, width, 0);
	EXTRACT_PARAM_INT(3, height, 0);
	EXTRACT_PARAM_INT(4, bpp, 32);

	Audio *self = Audio::create(samples);
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Audio));
	return 0;
}*/

DSQ_METHOD(Sound, _typeof)
{
	RETURN_STR("Sound");
}

DSQ_METHOD(Sound, _tostring)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Sound);

	char temp[64];
	//sprintf(temp, "Bitmap(0x%08X, %d, %d, %d, %d)", self, (int)self->clip.x, (int)self->clip.y, (int)self->clip.w, (int)self->clip.h);
	sprintf(temp, "Sound(0x%08X)", self);
	RETURN_STR(temp);
}

DSQ_METHOD(Sound, _get)
{
	EXTRACT_PARAM_START();

	if (nargs >= 2) {
		EXTRACT_PARAM_SELF(Sound);
		EXTRACT_PARAM_STR(2, s, NULL);
		
		char *c = (char *)s.data;
		
		if (strcmp(c, "memory_size") == 0) RETURN_INT(0);
	}
	
	RETURN_VOID;
}

/*DSQ_METHOD(Sound, fromFile)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, s, NULL);
	EXTRACT_PARAM_INT(3, smooth, 0);

	Sound *sound = Sound::createFromFile((char *)s.data);
	CREATE_OBJECT(Sound, sound);
	return 1;
}*/

DSQ_METHOD(Sound, fromStream)
{
	SQStream *stream = NULL;
	Sound *sound = NULL;
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(3, smooth, 0);

	if (SQ_FAILED(sq_getinstanceup(v, 2, (SQUserPointer*)&stream, (SQUserPointer)0x80000000)))
	{
		printf("Sound.fromStream | not a Stream.\n");
		return SQ_ERROR;
	}

	//printf("111111111\n"); fflush(stdout);
	STRING sound_data = STRING_READSTREAM(stream);
	//printf("222222222\n"); fflush(stdout);
	sound = Sound::loadFromData(sound_data);
	//printf("333333333\n"); fflush(stdout);
	STRING_FREE(&sound_data);
	//printf("444444444\n"); fflush(stdout);
	if (sound != NULL)  {
		sound->capture();
		CREATE_OBJECT(Sound, sound);
		return 1;
	} else {
		RETURN_VOID;
	}
}

DSQ_METHOD(Sound, play)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Sound);
	EXTRACT_PARAM_INT(2, channel, -1);
	EXTRACT_PARAM_INT(3, loops, 1);
	EXTRACT_PARAM_INT(4, fadein_ms, 0);
	
	RETURN_INT(self->play(channel, loops, fadein_ms)->index);
}

DSQ_METHOD(Sound, playing)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Sound);
	
	RETURN_INT(self->playing());
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

void engine_register_sound()
{
	// Sound.
	CLASS_START(Sound);
	{
		NEWSLOT_METHOD(Sound, fromStream, 0, "");
		NEWSLOT_METHOD(Sound, _get, 0, "");
		NEWSLOT_METHOD(Sound, _typeof, 0, "");
		NEWSLOT_METHOD(Sound, _tostring, 0, ".");
		NEWSLOT_METHOD(Sound, play, 0, ".");
		NEWSLOT_METHOD(Sound, playing, 0, ".");
	}
	CLASS_END;
}