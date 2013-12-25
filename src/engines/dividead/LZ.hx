package engines.dividead;
import common.ByteUtils;
import common.ByteArrayUtils;
import common.compression.RingBuffer;
import haxe.io.Bytes;
import haxe.Log;
import flash.utils.ByteArray;

class LZ
{
	static public function decode(data:ByteArray):ByteArray
	{
		var magic:String = data.readUTFBytes(2);
		var compressedSize:Int = data.readInt();
		var uncompressedSize:Int = data.readInt();

		if (magic != "LZ") throw("Invalid LZ stream");
		
		return _decode(data, uncompressedSize);
	}
	
	@:noStack static private function _decode(input:ByteArray, uncompressedSize:Int):ByteArray
	{
		var inputBytes = ByteUtils.ByteArrayToBytes(input);
		var inputData = inputBytes.getData();
		var inputPosition = input.position;
		var inputLength:Int = input.length;

		var outputBytes = Bytes.alloc(uncompressedSize);
		var outputData = outputBytes.getData();
		var outputPosition = 0;
		var ringStart = 0xFEE;

		//Log.trace("[1]");
		while (inputPosition < inputLength)
		{
			var code:Int = (Bytes.fastGet(inputData, inputPosition++) & 0xFF) | 0x100;
			//Log.trace('[2] $code');
			
			while (code != 1)
			{
				//Log.trace("[3]");
				
				// Uncompressed
				if ((code & 1) != 0)
				{
					var byte:Int = Bytes.fastGet(inputData, inputPosition++);
					outputBytes.set(outputPosition++, byte);
				}
				// Compressed
				else
				{
					if (inputPosition >= inputLength) break;

					var paramL:Int = Bytes.fastGet(inputData, inputPosition++);
					var paramH:Int = Bytes.fastGet(inputData, inputPosition++);
					
					var param:Int = paramL | (paramH << 8);

					var ringOffset:Int = (param & 0xFF) | ((param >> 4) & 0xF00);
					var ringLength:Int = ((param >> 8) & 0xF) + 3;

					var convertedP:Int = ((ringStart + outputPosition) & 0xFFF) - ringOffset;
					if (convertedP < 0) convertedP += 0x1000;

					var outputReadOffset:Int = outputPosition - convertedP;

					while (outputReadOffset < 0)
					{
						outputBytes.set(outputPosition++, 0);
						outputReadOffset++;
						ringLength--;
					}

					while (ringLength-- > 0)
					{
						outputBytes.set(outputPosition++, Bytes.fastGet(outputData, outputReadOffset++));
					}
				}

				code >>= 1;
			}
		}

		return ByteUtils.BytesToByteArray(outputBytes);
	}
}
