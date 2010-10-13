class RIO_OP_AUDIO_base
{
	</ id=0x21, format="12s", description="" />
	static function MUSIC_PLAY(repeats, fadein_ms, bgm_file)
	{
		if (this.state.music_name != bgm_file) {
			this.state.music_name = bgm_file;
			this.music = Music.fromStream(arc[bgm_file + ".OGG"]);
			this.music.play(repeats, fadein_ms);
		}
	}
	
	</ id=0x22, format="121", description="" />
	static function MUSIC_STOP(unk, fadeout_ms, idx)
	{
		Music.stop(fadeout_ms);
	}

	// 23 - VOICE_PLAY idx, u2, u3, kind(girl=0,boy=1), unk4, voice_file   //
	</ id=0x23, format="12112s", description="" />
	static function VOICE_PLAY(channel, u2, u3, kind, unk4, voice_file)
	{
		if (!this.skipping()) {
			//this.sound.play(6 + channel, 1, 0);
			this.voice_channel = resman.get_sound(voice_file + ".OGG").play(this.voice_channel, 1, 0);
		}
		//this.TODO();
	}
	
	</ id=0x25, format="111122s", description="" />
	static function SOUND_PLAY(channel, repeat, blocking, start_time, fade_in_ms, volume, sound_file)
	{
		resman.get_sound(sound_file).play(channel, repeat + 1, fade_in_ms);
		//this.TODO();
	}
	
	</ id=0x26, format="2", description="" />
	static function SOUND_STOP(channel)
	{
		Audio.channelStop(channel);
	}

	</ id=0x52, format="2", description="" />
	static function SOUND_WAIT(idx)
	{
		while (Audio.channelProgress(idx) < 0.25) {
			//printf("%f\n", Audio.channelProgress(idx));
			this.frame_draw_tick();
		}
	}
}

switch (engine_version) {
	case "pw": // For Pricess Waltz.
		class RIO_OP_AUDIO extends RIO_OP_AUDIO_base
		{
			</ id=0x21, format="12.s", description="" />
			static function MUSIC_PLAY(repeats, fadein_ms, bgm_file)
			{
				RIO_OP_AUDIO_base.MUSIC_PLAY(repeats, fadein_ms, bgm_file);
			}

			</ id=0x25, format="111122.s", description="" />
			static function SOUND_PLAY(channel, repeat, blocking, start_time, fade_in_ms, volume, sound_file)
			{
				RIO_OP_AUDIO_base.SOUND_PLAY(channel, repeat, blocking, start_time, fade_in_ms, volume, sound_file);
			}
		}
	break;
	// For YMK and others.
	default:
	//case "ymk": 
		class RIO_OP_AUDIO extends RIO_OP_AUDIO_base
		{
		}
	break;
}