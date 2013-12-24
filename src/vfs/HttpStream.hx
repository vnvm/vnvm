package vfs;
import flash.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class HttpStream extends Stream
{
	public function readBytesAsync(length:Int, done:ByteArray -> Void):Void
	{
		throw('Not implemented Stream.readBytesAsync : $this');
	}
}