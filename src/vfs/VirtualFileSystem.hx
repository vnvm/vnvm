package vfs;

import lang.promise.IPromise;
import lang.promise.Deferred;
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
	public function openBatchAsync(_names:Array<String>):IPromise<Stream>
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

	public function openAndReadAllAsync(name:String):IPromise<ByteArray> {
		var stream:Stream;	
		var deferred = new Deferred<ByteArray>();
		
		openAsync(name).then(function(stream:Stream):Void {
			stream.readBytesAsync(stream.length).then(deferred.resolve);
		});
		
		return deferred.promise;
	}

	public function tryOpenAndReadAllAsync(name:String):IPromise<ByteArray> {
		var deferred = new Deferred<ByteArray>();
		existsAsync(name).then(function(exists:Bool) {
			if (!exists) {
				deferred.reject('Not exists');
			} else {
				openAndReadAllAsync(name);
			}
		});
		return deferred.promise;
	}
}