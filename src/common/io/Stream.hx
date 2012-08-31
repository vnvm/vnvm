package common.io;

import nme.utils.ByteArray;

/**
 * ...
 * @author 
 */

class Stream 
{
	public var position:Int;
	public var length:Int;
	
	public function readBytesAsync(length:Int, done:ByteArray -> Void):Void
	{
		throw(Std.format("Not implemented Stream.readBytesAsync : $this"));
	}
}