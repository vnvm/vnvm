package common.io;

import common.io.Stream;
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
	
	public function openAndReadAllAsync(name:String, done:ByteArray -> Void):Void {
		var stream:Stream;
		
		openAsync(name, function(stream:Stream):Void {
			stream.readBytesAsync(stream.length, done);
		});
	}
}