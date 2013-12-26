package common;

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
}