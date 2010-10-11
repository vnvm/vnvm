#define SQTAG_Effect (SQUserPointer)0x80000003
//DSQ_RELEASE_AUTO_RELEASECAPTURE(Effect);
DSQ_RELEASE_AUTO(Effect);

DSQ_METHOD(Effect, constructor)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, effect, "transition");

	Effect *self = new Effect(effect.stringz);
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Effect));
	return 0;
}

DSQ_METHOD(Effect, _set)
{
	EXTRACT_PARAM_START();

	if (nargs >= 3) {
		EXTRACT_PARAM_SELF(Effect);
		EXTRACT_PARAM_STR(2, s, NULL);
		EXTRACT_PARAM_INT(3, vi, 0);
		
		char *c = s.stringz;
		switch (sq_gettype(v, -1)) {
			case OT_NULL:
			case OT_BOOL:
			case OT_INTEGER: {
				EXTRACT_PARAM_INT(-1, value, 0);
				self->set_i(s.stringz, value);
			} break;
			case OT_FLOAT: {
				EXTRACT_PARAM_FLO(-1, value, 0.0f);
				self->set_f(s.stringz, value);
			} break;
			case OT_INSTANCE: {
				EXTRACT_PARAM_OBJ(-1, Bitmap, value);
				self->set_t(s.stringz, value);
			} break;
			case OT_ARRAY: {
				bool is_int = false;
				int  ints[4];
				float floats[4];
				int count = 0;
				sq_pushnull(v);
				while (SQ_SUCCEEDED(sq_next(v, -2))) {
					if (count == 0) {
						switch (sq_gettype(v, -1)) {
							case OT_INTEGER: is_int = true; break;
							case OT_FLOAT: is_int = false; break;
							default:
								fprintf(stderr, "Effect.set('%s', <invalid_type>)\n", s.stringz);
							break;
						}
					}
					
					if (is_int) {
						sq_getinteger(v, -1, &ints[count]);
					} else {
						sq_getfloat(v, -1, &floats[count]);
					}
					
					sq_pop(v, 2);
					count++;
				}
				
				sq_pop(v,1);

				if (is_int) {
					self->set_vars(EVT_INT, s.stringz, count, ints);
				} else {
					self->set_vars(EVT_FLOAT, s.stringz, count, floats);
				}
				
			} break;
			default: {
				fprintf(stderr, "Effect.set('%s', <invalid_type>)\n", s.stringz);
			} break;

			/*
			case OT_STRING:
			case OT_TABLE:
			case OT_ARRAY =			(_RT_ARRAY|SQOBJECT_REF_COUNTED),
			case OT_USERDATA =		(_RT_USERDATA|SQOBJECT_REF_COUNTED|SQOBJECT_DELEGABLE),
			case OT_CLOSURE =		(_RT_CLOSURE|SQOBJECT_REF_COUNTED),
			case OT_NATIVECLOSURE =	(_RT_NATIVECLOSURE|SQOBJECT_REF_COUNTED),
			case OT_GENERATOR =		(_RT_GENERATOR|SQOBJECT_REF_COUNTED),
			case OT_USERPOINTER =	_RT_USERPOINTER,
			case OT_THREAD =			(_RT_THREAD|SQOBJECT_REF_COUNTED) ,
			case OT_FUNCPROTO =		(_RT_FUNCPROTO|SQOBJECT_REF_COUNTED), //internal usage only
			case OT_CLASS =			(_RT_CLASS|SQOBJECT_REF_COUNTED),
			case OT_WEAKREF =		(_RT_WEAKREF|SQOBJECT_REF_COUNTED)
			*/
		}
	}
	
	RETURN_VOID;
}

DSQ_METHOD(Effect, _get)
{
	EXTRACT_PARAM_START();

	if (nargs >= 2) {
		EXTRACT_PARAM_SELF(Effect);
		EXTRACT_PARAM_STR(2, s, NULL);
		
		char *c = s.stringz;
	}
	
	RETURN_VOID;
}

void engine_register_effect()
{
	// Effect.
	CLASS_START(Effect);
	{
		NEWSLOT_METHOD(Effect, constructor, 0, "");
		NEWSLOT_METHOD(Effect, _set, 0, ".");
		NEWSLOT_METHOD(Effect, _get, 0, ".");
	}
	CLASS_END;
}

