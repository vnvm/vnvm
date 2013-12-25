package common.compression;
import haxe.io.Bytes;

/**
 * ...
 * @author soywiz
 */

class RingBuffer 
{
	public var readPosition:Int; 
	public var writePosition:Int; 
	private var bytes:Bytes;

	public function new(size:Int, position:Int = 0) 
	{
		this.bytes = Bytes.alloc(size);
		this.readPosition = position;
		this.writePosition = position;
		for (n in 0 ... this.bytes.length) this.bytes.set(n, 0);
	}

	inline public function read():Int
	{
		var result:Int = bytes.get(readPosition);
		readPosition = (readPosition + 1) % bytes.length;
		return result;
	}
	
	inline public function write(value:Int):Void
	{
		bytes.set(writePosition, value);
		writePosition = (writePosition + 1) % bytes.length;
	}
}