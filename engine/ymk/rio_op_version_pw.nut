RIO_OP_EFFECTS_base <- RIO_OP_EFFECTS;
class RIO_OP_EFFECTS extends RIO_OP_EFFECTS_base
{
	</ id=0x4C, format="1.", description="" />
	static function ANIMATE_PLAY(can_skip)
	{
		RIO_OP_EFFECTS_base.ANIMATE_PLAY(can_skip);
	}
}

RIO_OP_AUDIO_base <- RIO_OP_AUDIO;
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
