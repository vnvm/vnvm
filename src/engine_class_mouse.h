#define SQTAG_Mouse (SQUserPointer)0x80000021
DSQ_RELEASE_AUTO(Mouse);

DSQ_METHOD(Mouse, constructor)
{
	EXTRACT_PARAM_START();

	Mouse *self = new Mouse();
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Mouse));
	return 0;
}


DSQ_METHOD(Mouse, update)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Mouse);
	self->update();
	return 0;
}

DSQ_METHOD(Mouse, _get)
{
	EXTRACT_PARAM_START();
	
	if (nargs >= 2) {
		EXTRACT_PARAM_SELF(Mouse);
		EXTRACT_PARAM_STR(2, s, NULL);
		
		char *c = (char *)s.data;
		int l = strlen(c);
		
		switch (l) {
			case 1:
				if (strcmp(c, "x" ) == 0) RETURN_INT(self->x_now);
				if (strcmp(c, "y" ) == 0) RETURN_INT(self->y_now);
				if (strcmp(c, "b" ) == 0) RETURN_INT(self->buttons_now);
			break;
			case 2:
				if (strcmp(c, "dx" ) == 0) RETURN_INT(self->dx);
				if (strcmp(c, "dy" ) == 0) RETURN_INT(self->dy);
			break;
			default:
				if (strcmp(c, "wheel" ) == 0) RETURN_INT(self->wheel_now);
				if (strcmp(c, "dwheel" ) == 0) RETURN_INT(self->wheel_now - self->wheel_before);
			break;
		}
	}
	
	return 0;
}

DSQ_METHOD(Mouse, pressed)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Mouse);
	EXTRACT_PARAM_INT(2, button, 0);
	RETURN_INT(self->pressed_now(button));
}

DSQ_METHOD(Mouse, clicked)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Mouse);
	EXTRACT_PARAM_INT(2, button, 0);
	RETURN_INT(self->clicked(button));
}

void engine_register_mouse()
{
	CLASS_START(Mouse);
	{
		NEWSLOT_METHOD(Mouse, constructor, 0, "");
		NEWSLOT_METHOD(Mouse, update, 0, "");
		NEWSLOT_METHOD(Mouse, pressed, 0, "");
		NEWSLOT_METHOD(Mouse, clicked, 0, "");
		NEWSLOT_METHOD(Mouse, _get, 0, "");
	}
	CLASS_END;
}
