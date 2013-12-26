package engines.will.formats.arc;

import haxe.Log;
import vfs.SliceStream;
import vfs.VirtualFileSystem;
import common.ByteArrayUtils;
import flash.utils.ByteArray;
import promhx.Promise;
import vfs.Stream;

class ARC extends VirtualFileSystem
{
	private var stream:Stream;
	private var files:Map<String, SliceStream>;

	private function new()
	{
		this.stream = null;
		this.files = new Map<String, SliceStream>();
	}

	override public function openAsync(name:String):Promise<Stream>
	{
		//for (name in files.keys()) Log.trace(name);
		if (!files.exists(name)) throw('Can\'t find file "$name"');
		return Promise.promise(cast SliceStream.fromAll(files[name]));
	}

	override public function existsAsync(name:String):Promise<Bool>
	{
		return Promise.promise(files.exists(name.toUpperCase()));
	}

	private function readHeaderAsync():Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		stream.readBytesAsync(4).then(function(data:ByteArray)
		{
			var typesCount = data.readUnsignedInt();

			var promises = [];
			for (n in 0 ... typesCount) {
				promises.push(readTypeAsync(n));
			}
			Promise.whenAll(promises).then(function(e) {
				promise.resolve(null);
			});
		});
		return promise;
	}

	private function readTypeAsync(index:Int):Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		stream.position = 4 + index * (4 + 4 + 4);
		stream.readBytesAsync(12).then(function(data:ByteArray)
		{
			var typeName = ByteArrayUtils.readStringz(data, 4);
			var typeCount = data.readUnsignedInt();
			var typeStart = data.readUnsignedInt();

			stream.position = typeStart;
			stream.readBytesAsync(typeCount * (9 + 4 + 4)).then(function(data:ByteArray)
			{
				for (n in 0 ... typeCount)
				{
					var fileName  = ByteArrayUtils.readStringz(data, 9);
					var fileSize  = data.readUnsignedInt();
					var fileStart = data.readUnsignedInt();
					var fullFileName = '$fileName.$typeName'.toUpperCase();

					//Log.trace(fullFileName);
					files[fullFileName] = SliceStream.fromLength(stream, fileStart, fileSize);
				}

				promise.resolve(null);
			});
		});
		return promise;
	}

	static public function fromStreamAsync(stream:Stream):Promise<ARC>
	{
		var promise = new Promise<ARC>();
		var arc = new ARC();
		arc.stream = stream;

		return arc.readHeaderAsync().then(function(e) {
			return arc;
		});
	}
}