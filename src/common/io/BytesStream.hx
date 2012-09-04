package common.io;
import common.ByteArrayUtils;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class BytesStream extends Stream
{
	var byteArray:ByteArray;
	
	public function new(byteArray:ByteArray) {
		this.byteArray = byteArray;
	}
	
	public function readBytesAsync(length:Int, done:ByteArray -> Void):Void
	{
		var data:ByteArray;
		byteArray.position = this.position;
		data = ByteArrayUtils.readByteArray(byteArray, length);
		this.position += length;
		return data;
	}
}