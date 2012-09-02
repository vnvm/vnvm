package common.io;

import common.io.Stream;
import haxe.Timer;
import nme.errors.Error;
import nme.utils.ByteArray;

/**
 * ...
 * @author 
 */

class VirtualFileSystem 
{
	public function openAsync(name:String, done:Stream -> Void):Void
	{
		throw(new Error("Not implemented VirtualFileSystem.openAsync"));
	}

	public function openBatchAsync(_names:Array<String>, done:Dynamic):Void
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

	public function openAndReadAllAsync(name:String, done:ByteArray -> Void):Void {
		var stream:Stream;
		
		openAsync(name, function(stream:Stream):Void {
			stream.readBytesAsync(stream.length, done);
		});
	}

	public function tryOpenAndReadAllAsync(name:String, done:ByteArray -> Void):Void {
		existsAsync(name, function(exists:Bool) {
			if (!exists) {
				done(null);
			} else {
				openAndReadAllAsync(name, done);
			}
		});
	}

	public function existsAsync(name:String, done:Bool -> Void):Void {
		throw(new Error("Not implemented"));
	}
}