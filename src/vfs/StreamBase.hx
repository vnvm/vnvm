package vfs;
import flash.utils.ByteArray;
import promhx.Promise.Promise;

/**
 * ...
 * @author soywiz
 */

class StreamBase 
{
	public var position:Int;
	public var length:Int;
	
	public function readBytesAsync(length:Int):Promise<ByteArray>
	{
		throw('Not implemented Stream.readBytesAsync : $this');
		return null;
	}
}