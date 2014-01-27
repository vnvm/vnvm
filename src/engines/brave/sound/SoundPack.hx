package engines.brave.sound;
//import haxe.io.Input;
import lang.promise.Deferred;
import lang.promise.IPromise;
import common.ByteArrayUtils;
import vfs.Stream;
import haxe.Log;
import flash.errors.Error;
import flash.media.Sound;
import flash.utils.ByteArray;

//typedef Input = sys.io.FileInput;

/**
 * ...
 * @author 
 */

class SoundPack 
{
	public var stream:Stream;
	private var startPosition:Int;
	private var entries:Map<String, SoundEntry>;
	public var numberOfChannels:Int;

	private function new(numberOfChannels:Int = 1)
	{
		this.entries = new Map<String, SoundEntry>();
		this.numberOfChannels = numberOfChannels;
	}
	
	static public function newAsync(numberOfChannels:Int = 1, stream:Stream):IPromise<SoundPack> {
		var soundPack:SoundPack = new SoundPack(numberOfChannels);
		return soundPack.loadAsync(stream).then(function(empty) {
			return soundPack;
		});
	}
	
	public function getSoundAsync(soundFile:String):IPromise<Sound> {
		var entry:SoundEntry = entries.get(soundFile);
		if (entry == null) throw(new Error('Can\'t find sound \'${soundFile}\''));
		return entry.getSoundAsync();
	}
	
	private function readEntry(stream:ByteArray):SoundEntry {
		// 24 bytes per entry
		var name:String = ByteArrayUtils.readStringz(stream, 10);
		var length:Int = stream.readInt();
		var position:Int = stream.readInt() + startPosition;
		stream.readUTFBytes(6);
		return new SoundEntry(this, name, position, length);
	}
	
	public function loadAsync(stream:Stream):IPromise<Dynamic> {
		this.stream = stream;
		
		var header1:ByteArray;
		var header2:ByteArray;
		
		return stream.readBytesAsync(8).pipe(function(header1:ByteArray) {
			header1.readInt();
			var headerBlocks:Int = header1.readUnsignedShort();
			var entryCount:Int = header1.readUnsignedShort();
			
			stream.position += headerBlocks * 20 +  2;
			startPosition = 4 + 2 + 2 + (headerBlocks * 20) + 2 + (entryCount * 24);
			
			return stream.readBytesAsync((entryCount * 24)).then(function(header2:ByteArray) {
				for (n in 0 ... entryCount) {
					var entry:SoundEntry = readEntry(header2);
					entries.set(entry.name, entry);
					//BraveLog.trace(entry.name);
				}
			});
		});
	}
}
