#define SQTAG_Joypad (SQUserPointer)0x80000023
DSQ_RELEASE_AUTO(Joypad);

DSQ_METHOD(Joypad, constructor)
{
	EXTRACT_PARAM_START();

	Joypad *self = new Joypad();
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Joypad));
	return 0;
}


DSQ_METHOD(Joypad, update)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Joypad);
	self->update();
	return 0;
}

DSQ_METHOD(Joypad, _get)
{
	EXTRACT_PARAM_START();
	
	if (nargs >= 2) {
		EXTRACT_PARAM_SELF(Joypad);
		EXTRACT_PARAM_STR(2, s, NULL);
		
		char *c = (char *)s.data;
		int l = strlen(c);
		
		if (strcmp(c, "lthumb_x") == 0) RETURN_INT(self->now.lthumb_x);
		if (strcmp(c, "lthumb_y") == 0) RETURN_INT(self->now.lthumb_y);
		if (strcmp(c, "rthumb_x") == 0) RETURN_INT(self->now.rthumb_x);
		if (strcmp(c, "rthumb_y") == 0) RETURN_INT(self->now.rthumb_y);
		if (strcmp(c, "dpad_x"  ) == 0) RETURN_INT(self->now.dpad_x);
		if (strcmp(c, "dpad_y"  ) == 0) RETURN_INT(self->now.dpad_y);
	}
	
	return 0;
}

int Joypad_pressed_pressing(Joypad *joypad, char *button, int pressing) {
	int ibutton = -1;
	     if (strcmp(button, "up"     ) == 0) ibutton = JOYPAD_UP;
	else if (strcmp(button, "right"  ) == 0) ibutton = JOYPAD_RIGHT;
	else if (strcmp(button, "down"   ) == 0) ibutton = JOYPAD_DOWN;
	else if (strcmp(button, "left"   ) == 0) ibutton = JOYPAD_LEFT;
	else if (strcmp(button, "accept" ) == 0) ibutton = JOYPAD_ACCEPT;
	else if (strcmp(button, "cancel" ) == 0) ibutton = JOYPAD_CANCEL;
	else if (strcmp(button, "skip"   ) == 0) ibutton = JOYPAD_SKIP;
	else if (strcmp(button, "menu"   ) == 0) ibutton = JOYPAD_MENU;
	else if (strcmp(button, "special") == 0) ibutton = JOYPAD_SPECIAL;
	else if (strcmp(button, "select" ) == 0) ibutton = JOYPAD_SELECT;
	else if (strcmp(button, "start"  ) == 0) ibutton = JOYPAD_START;
	else if (strcmp(button, "lmenu"  ) == 0) ibutton = JOYPAD_LMENU;
	else if (strcmp(button, "rmenu"  ) == 0) ibutton = JOYPAD_RMENU;
	else if (strcmp(button, "lmenu2" ) == 0) ibutton = JOYPAD_LMENU2;
	else if (strcmp(button, "rmenu2" ) == 0) ibutton = JOYPAD_RMENU2;
	return pressing ? joypad->pressing(ibutton) : joypad->pressed(ibutton);
}

DSQ_METHOD(Joypad, pressed_pressing)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Joypad);
	EXTRACT_PARAM_STR(2, button, 0);
	EXTRACT_PARAM_INT(3, pressing, 0);
	RETURN_INT(Joypad_pressed_pressing(self, button.stringz, pressing));
}

DSQ_METHOD(Joypad, pressed)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Joypad);
	EXTRACT_PARAM_STR(2, button, 0);
	RETURN_INT(Joypad_pressed_pressing(self, button.stringz, 0));
}

DSQ_METHOD(Joypad, pressing)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Joypad);
	EXTRACT_PARAM_STR(2, button, 0);
	RETURN_INT(Joypad_pressed_pressing(self, button.stringz, 1));
}

DSQ_METHOD(Joypad, setVibration)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Joypad);
	EXTRACT_PARAM_FLO(2, left, 0.0);
	EXTRACT_PARAM_FLO(3, right, 0.0);
	EXTRACT_PARAM_INT(4, time, 20);
	EXTRACT_PARAM_INT(5, wait, 0);
	self->setVibration(left, right, time, wait);
	RETURN_VOID;
}

void engine_register_joypad()
{
	CLASS_START(Joypad);
	{
		NEWSLOT_METHOD(Joypad, constructor, 0, "");
		NEWSLOT_METHOD(Joypad, update, 0, "");
		NEWSLOT_METHOD(Joypad, pressed, 0, "");
		NEWSLOT_METHOD(Joypad, pressing, 0, "");
		NEWSLOT_METHOD(Joypad, pressed_pressing, 0, "");
		NEWSLOT_METHOD(Joypad, _get, 0, "");
		NEWSLOT_METHOD(Joypad, setVibration, 0, "");
	}
	CLASS_END;
}
