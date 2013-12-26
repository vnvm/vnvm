package common.compression;

import haxe.Timer;
import flash.utils.Endian;
import common.compression.LzOptions;
import haxe.Log;
import flash.utils.ByteArray;
class LzDecoder
{
	private function new()
	{
	}

	@:noStack private function _decode(input:ByteArray, output:ByteArray, options:LzOptions):ByteArray
	{
		var buffer = new LzBuffer(input, output, new RingBuffer(options.ringBufferSize, options.startRingBufferPos));

		var compressedBit = options.compressedBit;
		var countPositionBytesHighFirst = options.countPositionBytesHighFirst;
		var extractor = options.positionCountExtractor;

		//var extractCount:Int -> Int = extractor.extractCount;
		//var extractPosition:Int -> Int = extractor.extractPosition;

		while (buffer.hasAtLeast(1))
		{
			var op:Int = (buffer.readByte() & 0xFF) | 0x100;

			while (op != 1)
			{
				//Log.trace('OPS: $op, ' + (op & 1));

				if ((op & 1) == compressedBit)
				{
					if (!buffer.hasAtLeast(2)) break;

					var param0 = buffer.readByte();
					var param1 = buffer.readByte();
					var param:Int;
					param = (countPositionBytesHighFirst)
						? ((param0 << 8) | (param1 << 0))
						: ((param0 << 0) | (param1 << 8))
					;

					var count = extractor.extractCount(param);
					var position = extractor.extractPosition(param);

					//Log.trace('Compressed: $param, $position, $count');

					buffer.copyBytesFromRingBuffer(position, count);
				}
				else
				{
					var value = buffer.readByte();
					//Log.trace('Uncompressed: $value');
					buffer.writeByte(value);
				}

				op >>= 1;
			}
		}

		//output.length = output.position;
		output.position = 0;

		return output;
	}

	static public function decode(input:ByteArray, options:LzOptions, maxUncompressedData:Int):ByteArray
	{
		var output:ByteArray = ByteArrayUtils.newByteArrayWithLength(maxUncompressedData, Endian.LITTLE_ENDIAN);
		output.position = 0;
		Log.trace('Decompressing ${input.length} ... ${maxUncompressedData}');
		Timer.measure(function() {
			new LzDecoder()._decode(input, output, options);
		});
		return output;
	}
}