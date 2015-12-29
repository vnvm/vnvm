package common.compression;
import haxe.io.BytesData;
import haxe.io.Bytes;

/**
 * ...
 * @author soywiz
 */

class RingBuffer 
{
	private var readPosition:Int;
	private var writePosition:Int;
	private var length:Int;
	private var mask:Int;
	private var bytes:Bytes;
	private var bytesData:BytesData;

	public function new(size:Int, position:Int = 0) 
	{
		this.bytes = Bytes.alloc(size);
		this.bytesData = bytes.getData();
		this.readPosition = position;
		this.writePosition = position;
		this.length = size;
		this.mask = size - 1;
		for (n in 0 ... this.bytes.length) this.bytes.set(n, 0);
	}

	@:noStack public function setReadPosition(readPosition:Int):Void
	{
		this.readPosition = readPosition & mask;
	}

	#if cpp @:functionCode("return this->bytesData->__unsafe_get(((int((this->readPosition)++) & int(this->mask))));") #end
	@:noStack public function readByte():Int
	{
		return cast Bytes.fastGet(bytesData, readPosition++ & mask);
	}

	#if cpp @:functionCode("
		this->bytesData->__unsafe_set((int((this->writePosition)++) & int(this->mask)), value);
		return null();
	") #end
	@:noStack public function writeByte(value:Int):Void
	{
		bytes.set(writePosition++ & mask, cast value);
		//bytesData[writePosition++ & mask] = cast value;
	}
}