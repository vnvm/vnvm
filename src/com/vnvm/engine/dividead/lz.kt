package com.vnvm.engine.dividead

object LZ {
	fun isCompressed(data:ByteArray):Boolean {
		data.position = 0;
		var magic:String = data.readUTFBytes(2);
		return magic == "LZ";
	}

	fun decode(data:ByteArray):ByteArray {
		data.position = 0;
		var magic:String = data.readUTFBytes(2);
		var compressedSize:Int = data.readInt();
		var uncompressedSize:Int = data.readInt();

		if (magic != "LZ") throw("Invalid LZ stream");

		return _decode(data, uncompressedSize);
	}

	private fun _decode(input:ByteArray, uncompressedSize:Int):ByteArray {
		//return _decodeFast(input, uncompressedSize);

		var uncompressed:ByteArray;
		Timer.measure(function() {
			//uncompressed = _decodeGeneric(input, uncompressedSize);
			uncompressed = _decodeFast(input, uncompressedSize);
		});
		return uncompressed;
	}

	private fun _decodeGeneric(input:ByteArray, uncompressedSize:Int):ByteArray {
		var options = new LzOptions();

		options.ringBufferSize = 0x1000;
		options.startRingBufferPos = 0xFEE;
		//options.setCountPositionBits(4, 12);
		options.compressedBit = 0;
		options.countPositionBytesHighFirst = false;
		options.positionCountExtractor = new DivideadPositionCountExtractor();

		return LzDecoder.decode(input, options, uncompressedSize);
	}

	// @:noStack
	private fun _decodeFast(input:ByteArray, uncompressedSize:Int):ByteArray {
		var inputData = ByteArrayUtils.ByteArrayToBytes(input);
		var i = inputData.getData();
		var inputPosition = input.position;
		var inputLength:Int = input.length;

		var outputData = Bytes.alloc(uncompressedSize + 0x1000);
		var o = outputData.getData();
		var outputPosition = 0x1000;
		var ringStart = 0xFEE;
		//var extractor = new DivideadPositionCountExtractor();

		//var bd = Bytes.alloc(1000).getData();
		//var ptr = Pointer.fromArray(bd, 0);

		//var ptr:cpp.Pointer<cpp.UInt8> = null;
		//var ptr:cpp.Pointer<haxe.io.Unsigned_char__> = null;
		//trace(ptr); // some pointer address

		//Memory.select(input);

		//Log.trace("[1]");
		while (inputPosition < inputLength) {
			var code:Int = fastGet(i, inputPosition++) | 0x100;

			while (code != 1) {
				//Log.trace("[3]");

				// Uncompressed
				if ((code & 1) != 0) {
					fastSet(o, outputPosition++, fastGet(i, inputPosition++));
				}
				// Compressed
				else {
					if (inputPosition >= inputLength) break;

					var paramL:Int = fastGet(i, inputPosition++);
					var paramH:Int = fastGet(i, inputPosition++);

					var param:Int = paramL | (paramH << 8);

					var ringOffset:Int = extractPosition(param);
					var ringLength:Int = extractCount(param);

					//Log.trace('Compressed: $param, $ringOffset, $ringLength');

					var convertedP:Int = ((ringStart + outputPosition) & 0xFFF) - ringOffset;
					if (convertedP < 0) convertedP = convertedP + 0x1000;

					var outputReadOffset:Int = outputPosition - convertedP;

					while (ringLength-- > 0) {
						fastSet(o, outputPosition++, fastGet(o, outputReadOffset++));
					}
				}

				code >>= 1;
			}
		}

		return ByteArrayUtils.BytesToByteArray(outputData.sub(0x1000, uncompressedSize));
	}

	private fun extractPosition(param:Int):Int {
		return (param and 0xFF) or ((param ushr 4) and 0xF00)
	}

	private fun extractCount(param:Int):Int {
		return ((param ushr 8) and 0xF) + 3;
	}
}

class DivideadPositionCountExtractor : IPositionCountExtractor {
	//@:noStack
	public inline fun extractPosition(param:Int):Int {
		return (param and 0xFF) or ((param ushr 4) and 0xF00);
	}

	//@:noStack
	public inline fun extractCount(param:Int):Int {
		return ((param ushr 8) and 0xF) + 3;
	}
}
