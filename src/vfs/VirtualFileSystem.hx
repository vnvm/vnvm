package vfs;

import promhx.Promise.Promise;
import vfs.Stream;
import haxe.Timer;
import flash.errors.Error;
import flash.utils.ByteArray;

/**
 * ...
 * @author 
 */

class VirtualFileSystem extends VirtualFileSystemBase
{
	/*
	public function openBatchAsync(_names:Array<String>):Promise<Stream>
	{
		var count:Int = _names.length;
		var names:Array<String> = _names.copy();
		var streams:Array<Stream> = [];
		var partialDone:Void -> Void = null;
		
		partialDone = function() {
			if (names.length == 0) {
				Reflect.callMethod(null, done, streams);
			} else {
				var name = names.shift();
				openAsync(name, function(stream:Stream) {
					streams.push(stream);
					Timer.delay(partialDone, 0);
				});
			}
		};
		
		partialDone();
	}
	*/

	public function openAndReadAllAsync(name:String):Promise<ByteArray> {
		var stream:Stream;	
		var promise:Promise<ByteArray> = new Promise<ByteArray>();
		
		openAsync(name).then(function(stream:Stream):Void {
			stream.readBytesAsync(stream.length).then(promise.resolve);
		});
		
		return promise;
	}

	public function tryOpenAndReadAllAsync(name:String):Promise<ByteArray> {
		var promise = new Promise<ByteArray>();
		existsAsync(name).then(function(exists:Bool) {
			if (!exists) {
				promise.reject('Not exists');
			} else {
				openAndReadAllAsync(name);
			}
		});
		return promise;
	}
}