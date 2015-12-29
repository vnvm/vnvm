package engines.will.script;

import haxe.Log;
import lang.exceptions.NotImplementedException;
class RIO_OP_YMK extends RIO_OP
{
	@Opcode({ id:0x21, format:"12s", description:"" })
	public function MUSIC_PLAY(repeats, fadein_ms, bgm_file)
	{
		throw(new NotImplementedException());
		/*
		if (this.state.music_name != bgm_file) {
			this.state.music_name = bgm_file;
			this.music = Music.fromStream(arc[bgm_file + ".OGG"]);
			this.music.play(repeats, fadein_ms);
		}
		*/
	}

	@Opcode({ id:0x25, format:"111122s", description:"" })
	public function SOUND_PLAY(channel:Int, repeat:Int, blocking:Int, start_time:Int, fade_in_ms:Int, volume:Int, sound_file:String)
	{
		Log.trace('SOUND_PLAY: $channel, $repeat, $blocking, $start_time, $fade_in_ms, $volume, "$sound_file"');
		//throw(new NotImplementedException());

		/*
		//sound_file = "pw003_1.ogg";
		//printf("SOUND_PLAY!: '%s'\n", sound_file);
		resman.get_sound(sound_file).play(channel, repeat + 1, fade_in_ms);
		//this.TODO();
		*/
	}

	@Opcode({ id:0x28, format:"12", description:"" })
	public function UNK_28(param, text)
	{
		throw(new NotImplementedException());
		//this.interface.enabled = false;
		//gameStep();
		//this.TODO();
	}

	@Opcode({ id:0x64, format:"1111", description:"" })
	public function CHARA_PUT_INFO(index, size, rotation, unk4)
	{
		throw(new NotImplementedException());

		/*
		local object = this.scene.sprites_l1[index];
		object.size = size / 100.0;
		this.TODO();
		*/
	}
}