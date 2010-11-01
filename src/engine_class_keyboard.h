#define SQTAG_Keyboard (SQUserPointer)0x80000022
DSQ_RELEASE_AUTO(Keyboard);

DSQ_METHOD(Keyboard, constructor)
{
	EXTRACT_PARAM_START();

	Keyboard *self = new Keyboard();
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Keyboard));
	return 0;
}


DSQ_METHOD(Keyboard, update)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Keyboard);
	self->update();
	return 0;
}

DSQ_METHOD(Keyboard, _get)
{
	EXTRACT_PARAM_START();
	
	if (nargs >= 2) {
		EXTRACT_PARAM_SELF(Keyboard);
		EXTRACT_PARAM_STR(2, s, NULL);
		
		char *c = (char *)s.data;
		int l = strlen(c);
		
		if (strcmp(c, "dx" ) == 0) RETURN_INT(self->dx());
		if (strcmp(c, "dy" ) == 0) RETURN_INT(self->dy());
	}
	
	RETURN_VOID;
}

// http://www.libsdl.org/tmp/SDL-1.2/docs/html/sdlkey.html
int pressed_pressing(int get_pressing)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Keyboard);
	EXTRACT_PARAM_STR(2, s, NULL);
	
	char *c = (char *)s.data;
	int l = strlen(c);
	int key = -1;
	int modkey = 0;
	
	switch (l) {
		// Single letter
		case 1:
			if (c[0] >= 'a' && c[0] <= 'z') key = SDLK_a + ('a' - c[0]);
			else if (c[0] >= '0' && c[0] <= '9') key = SDLK_0 + ('0' - c[0]);
		break;
		default:
			if (strcmp(c, "esc"    ) == 0) key = SDLK_ESCAPE;
			else if (strcmp(c, "enter"  ) == 0) key = SDLK_RETURN;
			else if (strcmp(c, "return" ) == 0) key = SDLK_RETURN;
			else if (strcmp(c, "space"  ) == 0) key = SDLK_SPACE;
			else if (strcmp(c, "backenter") == 0) key = SDLK_BACKSPACE;
			else if (strcmp(c, "tab"      ) == 0) key = SDLK_TAB;
			else if (strcmp(c, "clear"    ) == 0) key = SDLK_CLEAR;
			else if (strcmp(c, "insert"   ) == 0) key = SDLK_INSERT;
			else if (strcmp(c, "home"     ) == 0) key = SDLK_HOME;
			else if (strcmp(c, "end"      ) == 0) key = SDLK_END;
			else if (strcmp(c, "pageup"   ) == 0) key = SDLK_PAGEUP;
			else if (strcmp(c, "pagedown" ) == 0) key = SDLK_PAGEDOWN;
			else if (strcmp(c, "up"       ) == 0) key = SDLK_UP;
			else if (strcmp(c, "down"     ) == 0) key = SDLK_DOWN;
			else if (strcmp(c, "left"     ) == 0) key = SDLK_LEFT;
			else if (strcmp(c, "right"    ) == 0) key = SDLK_RIGHT;
			// F1, F2... F9
			else if ((l == 2) && (c[0] == 'f') && (c[1] >= '1' && c[1] <= '9')) {
				key = SDLK_F1 + (c[1] - '1');
				//printf("FX: %d\n", key);
			}
			
			// Special
			else if (strcmp(c, "accept"   ) == 0) key = SDLK_RETURN;
			else if (strcmp(c, "skip"     ) == 0) modkey = KMOD_LCTRL;

			// Mod keys
			else if (strcmp(c, "lshift" ) == 0) modkey = KMOD_LSHIFT;
			else if (strcmp(c, "lctrl"  ) == 0) modkey = KMOD_LCTRL;
			else if (strcmp(c, "lalt"   ) == 0) modkey = KMOD_LALT;
			else if (strcmp(c, "lmeta"  ) == 0) modkey = KMOD_LMETA;

			else if (strcmp(c, "rshift" ) == 0) modkey = KMOD_RSHIFT;
			else if (strcmp(c, "rctrl"  ) == 0) modkey = KMOD_RCTRL;
			else if (strcmp(c, "ralt"   ) == 0) modkey = KMOD_RALT;
			else if (strcmp(c, "rmeta"  ) == 0) modkey = KMOD_RMETA;
			
			else if (strcmp(c, "num"    ) == 0) modkey = KMOD_NUM;
			else if (strcmp(c, "caps"   ) == 0) modkey = KMOD_CAPS;
			else if (strcmp(c, "mode"   ) == 0) modkey = KMOD_MODE;
			
		break;
	}

	if (key >= 0) {
		RETURN_INT(get_pressing ? self->pressing(key) : self->pressed(key));
	} else if (modkey >= 0) {
		RETURN_INT(get_pressing ? self->mod_pressing(modkey) : self->mod_pressed(modkey));
	} else {
		RETURN_VOID;
	}
}

DSQ_METHOD(Keyboard, pressed)
{
	return pressed_pressing(0);
}

DSQ_METHOD(Keyboard, pressing)
{
	return pressed_pressing(1);
}

void engine_register_keyboard()
{
	CLASS_START(Keyboard);
	{
		NEWSLOT_METHOD(Keyboard, constructor, 0, "");
		NEWSLOT_METHOD(Keyboard, update, 0, "");
		NEWSLOT_METHOD(Keyboard, pressed, 0, "");
		NEWSLOT_METHOD(Keyboard, pressing, 0, "");
		//NEWSLOT_METHOD(Keyboard, pressed_pressing, 0, "");
		NEWSLOT_METHOD(Keyboard, _get, 0, "");
	}
	CLASS_END;
}
