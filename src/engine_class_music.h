#define SQTAG_Music (SQUserPointer)0x80000012
DSQ_RELEASE_AUTO(Music);


DSQ_METHOD(Music, _typeof)
{
	RETURN_STR("Music");
}

DSQ_METHOD(Music, fromStream)
{
	SQStream *stream = NULL;
	Music *music = NULL;
	EXTRACT_PARAM_START();
	HSQOBJECT sqobject;
	
	sq_getstackobj(v, 2, &sqobject);
	
	if (SQ_FAILED(sq_getinstanceup(v, 2, (SQUserPointer*)&stream, (SQUserPointer)0x80000000)))
	{
		printf("Music.fromStream | not a Stream.\n");
		return SQ_ERROR;
	}
	
	sq_addref(v, &sqobject);

	//printf("Music::loadFromSQStream(stream)\n");
	music = Music::loadFromSQStream(stream);
	//printf("[[%08X]] : %08X\n", v, sq_addref);
	//music->sqvm = v;
	//music->sqobject = sqobject;
	//music->capture();
	CREATE_OBJECT(Music, music);
	return 1;
}

DSQ_METHOD(Music, play)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Music);
	EXTRACT_PARAM_INT(2, loops, 1);
	EXTRACT_PARAM_INT(3, fadein_ms, 0);
	EXTRACT_PARAM_FLO(4, position, 0);
	
	RETURN_INT(self->play(loops, fadein_ms, position));
}

DSQ_METHOD(Music, playing)
{
	EXTRACT_PARAM_START();
	
	RETURN_INT(Music::playing());
}

DSQ_METHOD(Music, stop)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, fadeout_ms, 0);
	
	RETURN_INT(Music::stop(fadeout_ms));
}

void engine_register_music()
{
	// Music.
	CLASS_START(Music);
	{
		NEWSLOT_METHOD(Music, fromStream, 0, "");
		NEWSLOT_METHOD(Music, _typeof, 0, "");
		NEWSLOT_METHOD(Music, play, 0, ".");
		NEWSLOT_METHOD(Music, playing, 0, "");
		NEWSLOT_METHOD(Music, stop, 0, "");
	}
	CLASS_END;
}
