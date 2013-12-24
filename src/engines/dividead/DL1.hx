package engines.dividead;

import promhx.Promise;
import vfs.SliceStream;
import vfs.Stream;
import vfs.VirtualFileSystem;
import haxe.Log;
import flash.utils.ByteArray;

class DL1 extends VirtualFileSystem
{
	private var entries:Map<String, Stream>;
	
	private function new() {
		this.entries = new Map<String, Stream>();
	}
	
	static public function loadAsync(stream:Stream, done:DL1 -> Void):Void {
		var header:ByteArray;
		var entriesByteArray:ByteArray;
		var dl1:DL1 = new DL1();

		// Read header
		stream.readBytesAsync(0x10).then(function(header:ByteArray) {
			var magic:String = StringTools.replace(header.readUTFBytes(8), String.fromCharCode(0), '');
			var count:Int = header.readUnsignedShort();
			var offset:Int = header.readUnsignedInt();
			var pos:Int = 0x10;
			
			if (magic != ("DL1.0" + String.fromCharCode(0x1A))) throw('Invalid DL1 file. Magic : \'$magic\'');

			//Log.trace(Std.format("DL1: {offset=$offset, count=$count}"));
			
			// Read entries
			stream.position = offset;
			stream.readBytesAsync(16 * count).then(function(entriesByteArray:ByteArray):Void {
				for (n in 0 ... count) {
					var name:String = StringTools.replace(entriesByteArray.readUTFBytes(12), String.fromCharCode(0), '');
					var size:Int = entriesByteArray.readUnsignedInt();
					
					//Log.trace(name);
					dl1.entries.set(name.toUpperCase(), SliceStream.fromLength(stream, pos, size));
					
					pos += size;
				}
				
				done(dl1);
			});
		});
	}
	
	override public function openAsync(name:String):Promise<Stream> 
	{
		name = name.toUpperCase();
		var entry:Stream = entries.get(name);
		if (entry == null) throw('Can\'t find \'$name\'');
		return Promise.promise(entry);
	}
}
