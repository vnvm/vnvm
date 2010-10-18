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

RIO_OP_base <- RIO_OP;
class RIO_OP extends RIO_OP_base
{
	</ id=0x28, format=".....", description="" />
	static function UNK_28()
	{
		this.TODO();
	}
}

RIO_OP_SCENE_base <- RIO_OP_SCENE;
class RIO_OP_SCENE extends RIO_OP_SCENE_base
{
	</ id=0x64, format="1221", description="" />
	static function CHARA_PUT_INFO(index, size, rotation, unk6)
	{
		local object = this.scene.sprites_l1[index];
		object.size = size / 100.0;
		object.rotation = rotation / -640.0;
		this.TODO();
	}
}