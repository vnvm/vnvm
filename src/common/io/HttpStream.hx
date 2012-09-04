package common.io;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class HttpStream extends Stream
{
	public function readBytesAsync(length:Int, done:ByteArray -> Void):Void
	{
		throw(Std.format("Not implemented Stream.readBytesAsync : $this"));
	}
}