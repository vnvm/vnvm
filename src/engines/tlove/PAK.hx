package engines.tlove;

import promhx.Promise;
import common.ByteArrayUtils;
import vfs.SliceStream;
import vfs.Stream;
import flash.errors.Error;
import flash.utils.ByteArray;

class PAK
{
	var items:Map<String, SliceStream>;
	
	private function new() {
		this.items = new Map<String, SliceStream>();
	}

	public function getBytesAsync(name:String):Promise<ByteArray> {
		var stream:Stream = get(name);
		return stream.readAllBytesAsync();
	}

	public function get(name:String):Stream {
		var item:SliceStream = items.get(name.toUpperCase());
		if (item == null) throw(new Error('Can\'t find \'$name\''));
		return SliceStream.fromAll(item);
	}
	
	public function getNames():Array<String> {
		var a = [];
		for (item in items.keys()) a.push(item);
		return a;
	}
	
	static public function newPakAsync(pakStream:Stream):Promise<PAK>
	{
		var pak:PAK = new PAK();
		var countByteArray:ByteArray;
		var headerByteArray:ByteArray;
		var promise = new Promise<PAK>();
		
		pakStream.readBytesAsync(2).then(function(countByteArray:ByteArray):Void {
			var headerSize:Int = countByteArray.readUnsignedShort();

			pakStream.readBytesAsync(headerSize).then(function(headerByteArray:ByteArray):Void {
				var names:Array<String> = [];
				var offsets:Array<Int> = [];

				while (headerByteArray.position < headerByteArray.length) {
					var name:String = ByteArrayUtils.readStringz(headerByteArray, 0xC);
					var offset:Int = headerByteArray.readUnsignedInt();
					names.push(name.toUpperCase());
					offsets.push(offset);
				}
				
				for (n in 0 ... names.length - 1) {
					pak.items.set(names[n], SliceStream.fromBounds(pakStream, offsets[n], offsets[n + 1]));
				}
				
				promise.resolve(pak);
			});
		});
		
		return promise;
	}
}