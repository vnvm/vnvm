package engines.tlove;

import common.ByteArrayUtils;
import common.io.SliceStream;
import common.io.Stream;
import nme.errors.Error;
import nme.utils.ByteArray;

class PAK
{
	var items:Hash<SliceStream>;
	
	private function new() {
		this.items = new Hash<SliceStream>();
	}
	
	public function get(name:String):Stream {
		var item:SliceStream = items.get(name);
		if (item == null) throw(new Error(Std.format("Can't find '$name'")));
		return item;
	}
	
	public function getNames():Array<String> {
		var a = [];
		for (item in items.keys()) a.push(item);
		return a;
	}
	
	static public function newPakAsync(pakStream:Stream, done:PAK -> Void):Void
	{
		var pak:PAK = new PAK();
		var countByteArray:ByteArray;
		var headerByteArray:ByteArray;
		
		pakStream.readBytesAsync(2, function(countByteArray:ByteArray):Void {
			var headerSize:Int = countByteArray.readUnsignedShort();

			pakStream.readBytesAsync(headerSize, function(headerByteArray:ByteArray):Void {
				var names:Array<String> = [];
				var offsets:Array<Int> = [];

				while (headerByteArray.position < headerByteArray.length) {
					var name:String = ByteArrayUtils.readStringz(headerByteArray, 0xC);
					var offset:Int = headerByteArray.readUnsignedInt();
					names.push(name);
					offsets.push(offset);
				}
				
				for (n in 0 ... names.length - 1) {
					pak.items.set(names[n], SliceStream.fromBounds(pakStream, offsets[n], offsets[n + 1] - 1));
				}
				
				done(pak);
			});
		});
	}
}