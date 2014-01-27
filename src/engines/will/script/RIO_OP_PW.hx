package engines.will.script;
import lang.promise.Promise;
import flash.media.SoundTransform;
import flash.utils.ByteArray;
import flash.media.Sound;
import haxe.Log;
import lang.exceptions.NotImplementedException;
class RIO_OP_PW extends RIO_OP
{
	@Opcode({ id:0x21, format:"121s", description:"" })
	public function MUSIC_PLAY(repeats:Int, fadein_ms:Int, unk:Int, bgm_file:String)
	{
		return this.scene.soundPlayStopAsync('music', bgm_file, fadein_ms);
	}

	@Opcode({ id:0x25, format:"111122.s", description:"" })
	public function SOUND_PLAY(channel:Int, repeat:Int, blocking:Int, start_time:Int, fade_in_ms:Int, volume:Int, sound_file:String)
	{
		//if (this.scene.isSkiping()) return null;
		return this.scene.soundPlayStopAsync('sound', sound_file, 0);

		//Log.trace('SOUND_PLAY: $channel, $repeat, $blocking, $start_time, $fade_in_ms, $volume, $sound_file');
	}

	@Opcode({ id:0x28, format:".....", description:"" })
	public function UNK_28()
	{
		//throw(new NotImplementedException());
	}

	@Opcode({ id:0x64, format:"1221", description:"" })
	@Unimplemented
	public function CHARA_PUT_INFO(index:Int, size:Int, rotation:Int, unk6:Int)
	{
		//Log.trace(unk6);
		scene.getLayerWithName("layer2").setObjectSizeRotation(index, size / 100, rotation / -640.0);

		//throw(new NotImplementedException());
		/*
		local object = this.scene.sprites_l1[index];
		object.size = size / 100.0;
		object.rotation = rotation / -640.0;
		this.TODO();
		*/
	}
}
