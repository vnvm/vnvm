package engines.will.formats.arc;

import lang.promise.Promise;
import lang.promise.Deferred;
import lang.promise.IPromise;
import haxe.Log;
import vfs.SliceStream;
import vfs.VirtualFileSystem;
import common.ByteArrayUtils;
import flash.utils.ByteArray;
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

	private function normalizeName(name:String):String
	{
		return name.toUpperCase();
	}

	override public function openAsync(name:String):IPromise<Stream>
	{
		name = normalizeName(name);
		//for (name in files.keys()) Log.trace(name);
		if (!files.exists(name)) throw('Can\'t find file "$name"');
		return Promise.createResolved(cast SliceStream.fromAll(files[name]));
	}

	public function getFileNames():Iterator<String>
	{
		return files.keys();
	}

	public function contains(name:String):Bool
	{
		name = normalizeName(name);
		return files.exists(name.toUpperCase());
	}

	override public function existsAsync(name:String):IPromise<Bool>
	{
		return Promise.createResolved(contains(name));
	}

	private function readHeaderAsync():IPromise<Dynamic>
	{
		var deferred = new Deferred<Dynamic>();
		stream.readBytesAsync(4).then(function(data:ByteArray)
		{
			var typesCount = data.readUnsignedInt();

			var promises = [];
			for (n in 0 ... typesCount) {
				promises.push(readTypeAsync(n));
			}
			Promise.whenAll(promises).then(function(e) {
				deferred.resolve(null);
			});
		});
		return deferred.promise;
	}

	private function readTypeAsync(index:Int):IPromise<Dynamic>
	{
		var deferred = new Deferred<Dynamic>();
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

				deferred.resolve(null);
			});
		});
		return deferred.promise;
	}

	static public function fromStreamAsync(stream:Stream):IPromise<ARC>
	{
		var arc = new ARC();
		arc.stream = stream;

		return arc.readHeaderAsync().then(function(e) {
			return arc;
		});
	}
}