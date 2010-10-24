#define SQTAG_Movie (SQUserPointer)0x80000030
DSQ_RELEASE_AUTO(Movie);

DSQ_METHOD(Movie, constructor)
{
	EXTRACT_PARAM_START();

	Movie *self = new Movie();
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Movie));
	RETURN_VOID;
}


DSQ_METHOD(Movie, load)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Movie);
	EXTRACT_PARAM_STR(2, filename, NULL);
	self->load((char *)filename.data);
	CREATE_OBJECT(Bitmap, self->buffer);
	self->buffer->capture();
	return 1;
}

DSQ_METHOD(Movie, _get)
{
	EXTRACT_PARAM_START();
	
	if (nargs >= 2) {
		EXTRACT_PARAM_SELF(Movie);
		EXTRACT_PARAM_STR(2, s, NULL);
		
		char *c = (char *)s.data;
		int l = strlen(c);
		
		if (strcmp(c, "playing" ) == 0) RETURN_INT(self->playing());
		if (strcmp(c, "width"   ) == 0) RETURN_INT(self->width());
		if (strcmp(c, "height"  ) == 0) RETURN_INT(self->height());
	}
	
	RETURN_VOID;
}

DSQ_METHOD(Movie, stop)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Movie);
	self->stop();
	RETURN_VOID;
}

DSQ_METHOD(Movie, play)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Movie);
	self->play();
	RETURN_VOID;
}

DSQ_METHOD(Movie, update)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Movie);
	self->update();
	RETURN_VOID;
}


DSQ_METHOD(Movie, viewport)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Movie);
	EXTRACT_PARAM_INT(2, x1, 0);
	EXTRACT_PARAM_INT(3, y1, 0);
	EXTRACT_PARAM_INT(4, x2, 0);
	EXTRACT_PARAM_INT(5, y2, 0);
	self->viewport(x1, y1, x2, y2);
	RETURN_VOID;
}


void engine_register_movie()
{
	CLASS_START(Movie);
	{
		NEWSLOT_METHOD(Movie, constructor, 0, "");
		NEWSLOT_METHOD(Movie, load, 0, ".");
		NEWSLOT_METHOD(Movie, play, 0, ".");
		NEWSLOT_METHOD(Movie, update, 0, ".");
		NEWSLOT_METHOD(Movie, viewport, 0, ".");
		NEWSLOT_METHOD(Movie, _get, 0, ".");
		NEWSLOT_METHOD(Movie, stop, 0, ".");
	}
	CLASS_END;
}
