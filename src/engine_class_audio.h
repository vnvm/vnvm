#define SQTAG_Audio (SQUserPointer)0x80000010
DSQ_RELEASE_AUTO(Audio);


DSQ_METHOD(Audio, init)
{
	EXTRACT_PARAM_START();
	//EXTRACT_PARAM_INT(2, frequency, 22050);
	EXTRACT_PARAM_INT(2, frequency, 44100);
	
	RETURN_INT(Audio::init(frequency));
}

DSQ_METHOD(Audio, channelPlaying)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, channel, 0);
	
	RETURN_INT(Audio::channelPlaying(channel));
}

DSQ_METHOD(Audio, channelProgress)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, channel, 0);
	
	RETURN_FLOAT(Audio::channelProgress(channel));
}

DSQ_METHOD(Audio, channelStop)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, channel, 0);
	
	RETURN_INT(Audio::channelStop(channel));
}

DSQ_METHOD(Audio, gc)
{
	EXTRACT_PARAM_START();
	
	Audio::gc();
	
	RETURN_INT(0);
}

void engine_register_audio()
{
	// Audio.
	CLASS_START(Audio);
	{
		NEWSLOT_METHOD(Audio, init, 0, "");
		NEWSLOT_METHOD(Audio, channelPlaying, 0, "");
		NEWSLOT_METHOD(Audio, channelProgress, 0, "");
		NEWSLOT_METHOD(Audio, channelStop, 0, "");
		NEWSLOT_METHOD(Audio, gc, 0, "");
	}
	CLASS_END;
}