package engines.brave.sound;
import common.ByteArrayUtils;
import haxe.io.Bytes;
import flash.media.Sound;
import flash.utils.ByteArray;

/**
 * ...
 * @author 
 */

class SoundEntry 
{
	public var soundPack:SoundPack;
	public var name:String;
	public var offset:Int;
	public var length:Int;
	public var bytes:Bytes;

	public function new(soundPack:SoundPack, name:String, offset:Int, length:Int) 
	{
		this.soundPack = soundPack;
		this.name = name;
		this.offset = offset;
		this.length = length;
	}
	
	public function getSoundAsync(done:Sound -> Void):Void {
		if (bytes == null) {
			soundPack.stream.position = this.offset;
			soundPack.stream.readBytesAsync(this.length).then(function(_bytes:ByteArray):Void {
				this.bytes = ByteArrayUtils.ByteArrayToBytes(_bytes);
				done((new SoundInstance(this)).getSound());
			});
		} else {
			done((new SoundInstance(this)).getSound());
		}
	}
}