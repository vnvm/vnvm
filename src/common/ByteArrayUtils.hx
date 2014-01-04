package common;

import haxe.io.Bytes;
import flash.utils.ByteArray;
import flash.utils.Endian;

/**
 * ...
 * @author 
 */

#if flash
typedef EndianType = flash.utils.Endian;
#else
typedef EndianType = String;
#end

class ByteArrayUtils
{
	static public function clone(input:ByteArray):ByteArray
	{
		var output:ByteArray = new ByteArray();
		output.endian = input.endian;
		output.writeBytes(input);
		output.position = 0;
		return output;
	}

	static public function newByteArray(endian:EndianType):ByteArray
	{
		var byteArray:ByteArray = new ByteArray();
		byteArray.endian = endian;
		return byteArray;
	}

	static public function newByteArrayWithLength(length:Int, endian:EndianType):ByteArray
	{
		#if (cpp || neko)
			var byteArray:ByteArray = new ByteArray(length);
		#else
			var byteArray:ByteArray = new ByteArray();
			byteArray.length = length;
		#end
		byteArray.endian = Endian.LITTLE_ENDIAN;
		return byteArray;
	}

	static public function freeByteArray(byteArray:ByteArray):Void
	{
		byteArray.clear();
	}

	static public function readByteArray(src:ByteArray, count:Int):ByteArray
	{
		var dst:ByteArray = newByteArray(src.endian);
		if (count > 0)
		{
			src.readBytes(dst, 0, count);
		}
		dst.position = 0;
		return dst;
	}

	static public function readStringz(data:ByteArray, ?count:Int):String
	{
		if (count == null)
		{
			var v:Int;
			var str:String = "";
			while ((v = data.readByte()) != 0)
			{
				str += String.fromCharCode(v);
			}
			return str;
		} else
		{
			var string:String = data.readUTFBytes(count);
			var zeroIndex:Int = string.indexOf(String.fromCharCode(0));

			return (zeroIndex == -1) ? string : string.substr(0, zeroIndex);
		}
	}

	static public function rotateBytesRight(input:ByteArray, rotate:Int):ByteArray
	{
		var output:ByteArray = ByteArrayUtils.clone(input);
		rotateBytesInplaceRight(output, rotate);
		return output;
	}

	static public function rotateBytesInplaceRight(data:ByteArray, rotate:Int):Void
	{
		for (n in 0 ... data.length) data[n] = BitUtils.rotateRight8(data[n], rotate);
	}

	@:noStack static public function BytesToByteArray(bytes:Bytes):ByteArray {
		if (bytes == null) return null;
//return bytes.getData();
		var byteArray:ByteArray = new ByteArray();
		byteArray.endian = Endian.LITTLE_ENDIAN;
		for (n in 0 ... bytes.length) byteArray.writeByte(bytes.get(n));
		byteArray.position = 0;
		return byteArray;
	}

//@:noStack static public function ToByteArray(array:Array<Int>):ByteArray { return ArrayToByteArray(array); }
//@:noStack static public function ToByteArray(array:Bytes):ByteArray { return BytesToByteArray(array); }

	@:noStack static public function ArrayToByteArray(array:Array<Int>):ByteArray {
		if (array == null) return null;
		var byteArray:ByteArray = new ByteArray();
		byteArray.position = 0;
		for (n in 0 ... array.length) byteArray.writeByte(array[n]);
		return byteArray;
	}

	@:noStack static public function ArrayToBytes(array:Array<Int>):Bytes {
		if (array == null) return null;
		var bytes:Bytes = Bytes.alloc(array.length);
		for (n in 0 ... bytes.length) bytes.set(n, array[n]);
		return bytes;
	}

	@:noStack static public function ByteArrayToBytes(byteArray:ByteArray):Bytes {
#if flash9
			return Bytes.ofData(byteArray);
		#elseif (cpp || neko)
			return byteArray;
		#end
		if (byteArray == null) return null;
		var bytes:Bytes = Bytes.alloc(byteArray.length);
		var initialByteArrayPosition:Int = byteArray.position;
		byteArray.position = 0;
//for (n in 0 ... bytes.length) bytes.set(n, byteArray.readUnsignedByte());
		byteArray.position = initialByteArrayPosition;
		return bytes;
	}

	@:noStack static public function memset(bytes:Bytes, offset:Int, length:Int, value:Int):Void
	{
		for (n in offset ... offset + length)
		{
			bytes.set(n, value);
		}
	}

}