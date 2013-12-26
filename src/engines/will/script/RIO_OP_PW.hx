package engines.will.script;
import flash.media.SoundTransform;
import flash.utils.ByteArray;
import flash.media.Sound;
import haxe.Log;
import lang.exceptions.NotImplementedException;
class RIO_OP_PW extends RIO_OP
{
	@Opcode({ id:0x4C, format:"1.", description:"" })
	public function ANIMATE_PLAY(can_skip)
	{
		throw(new NotImplementedException());
		//RIO_OP_EFFECTS_base.ANIMATE_PLAY(can_skip);
	}

	@Opcode({ id:0x21, format:"121s", description:"" })
	public function MUSIC_PLAY(repeats:Int, fadein_ms:Int, unk:Int, bgm_file:String)
	{
		return this.scene.soundPlayStopAsync('music', bgm_file, fadein_ms);
	}

	@Opcode({ id:0x25, format:"111122.s", description:"" })
	public function SOUND_PLAY(channel:Int, repeat:Int, blocking:Int, start_time:Int, fade_in_ms:Int, volume:Int, sound_file:String)
	{
		return this.scene.soundPlayStopAsync('sound', sound_file, 0);

		//Log.trace('SOUND_PLAY: $channel, $repeat, $blocking, $start_time, $fade_in_ms, $volume, $sound_file');
	}

	@Opcode({ id:0x28, format:".....", description:"" })
	public function UNK_28()
	{
		//throw(new NotImplementedException());
	}

	@Opcode({ id:0x64, format:"1221", description:"" })
	public function CHARA_PUT_INFO(index, size, rotation, unk6)
	{
		throw(new NotImplementedException());
		/*
		local object = this.scene.sprites_l1[index];
		object.size = size / 100.0;
		object.rotation = rotation / -640.0;
		this.TODO();
		*/
	}
}
