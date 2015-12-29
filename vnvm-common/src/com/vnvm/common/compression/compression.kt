package com.vnvm.common.compression

import com.vnvm.common.BitUtils
import com.vnvm.common.async.Promise
import com.vnvm.common.collection.ByteArraySlice
import com.vnvm.common.error.NotImplementedException

interface IPositionCountExtractor {
	fun extractPosition(param: Int): Int;
	fun extractCount(param: Int): Int;
}

class LzBuffer(
	val input: ByteArraySlice,
	val output: ByteArraySlice,
	val ring: RingBuffer
) {
	val inputData = input.data
	var inputPos = input.pos
	val inputLength = input.length

	val outputData = output.data
	var outputPos = output.pos
	val outputLength = output.length

	//@:noStack
	public fun readByte(): Int = inputData[inputPos++].toInt()

	//@:noStack
	public fun hasAtLeast(bytes: Int): Boolean = (inputLength - inputPos) >= bytes;

	//@:noStack
	public fun copyBytesFromRingBuffer(position: Int, totalCount: Int) {
		var count = totalCount
		ring.setReadPosition(position);
		while (count-- > 0) this.writeByte(ring.readByte());
	}

	//@:noStack
	public fun writeByte(byte: Int) {
		ring.writeByte(byte);
		outputData[outputPos++] = byte.toByte()
	}
}

class LzDecoder {
	//@:noStack
	private fun _decode(input: ByteArraySlice, output: ByteArraySlice, options: LzOptions): ByteArraySlice {
		var buffer = LzBuffer(input, output, RingBuffer(options.ringBufferSize, options.startRingBufferPos));

		var compressedBit = options.compressedBit;
		var countPositionBytesHighFirst = options.countPositionBytesHighFirst;
		var extractor = options.positionCountExtractor;

		//var extractCount:Int -> Int = extractor.extractCount;
		//var extractPosition:Int -> Int = extractor.extractPosition;

		while (buffer.hasAtLeast(1)) {
			var op: Int = (buffer.readByte() and 0xFF) or 0x100;

			while (op != 1) {
				//Log.trace('OPS: $op, ' + (op & 1));

				if ((op and 1) == compressedBit) {
					if (!buffer.hasAtLeast(2)) break;

					var param0 = buffer.readByte();
					var param1 = buffer.readByte();
					var param: Int;
					param = if (countPositionBytesHighFirst) ((param0 shl 8) or (param1 shl 0)) else ((param0 shl 0) or (param1 shl 8))

					val count = extractor.extractCount(param);
					val position = extractor.extractPosition(param);

					//Log.trace('Compressed: $param, $position, $count');

					buffer.copyBytesFromRingBuffer(position, count);
				} else {
					var value = buffer.readByte();
					//Log.trace('Uncompressed: $value');
					buffer.writeByte(value);
				}

				op = op ushr 1;
			}
		}

		//output.length = output.position;

		return ByteArraySlice(output.data, 0, buffer.outputPos);
	}

	public fun decode(input: ByteArray, options: LzOptions, maxUncompressedData: Int): ByteArraySlice {
		return LzDecoder()._decode(ByteArraySlice(input), ByteArraySlice(ByteArray(maxUncompressedData)), options);
		//Log.trace('Decompressed: ${input.length} -> ${maxUncompressedData}: $elapsed');
	}
}

object LzDecoderAsync {
	public fun decodeAsync(input: ByteArray): Promise<ByteArray> {
		throw NotImplementedException()
		/*
		var thread = Thread.create(function() {
			var message = Thread.readMessage(true);
			LzDecoder.decode(input, );
		});

		thread.sendMessage(input);
		*/
	}
}

class LzOptions {
	public var ringBufferSize: Int = 0x1000;
	//public var opsize:Int = 1;
	public var startRingBufferPos: Int = 1;
	//public var init:Int = 0;
	public var compressedBit: Int = 0;

	public var countPositionBytesHighFirst: Boolean = true;

	public var positionCountExtractor: IPositionCountExtractor = LzGenericPositionCountExtractor();

	public fun setCountPositionBits(countBits: Int, positionBits: Int, countAdd: Int) {
		this.positionCountExtractor = LzGenericPositionCountExtractor().setCountPositionBits(countBits, positionBits, countAdd);
	}
}

class LzGenericPositionCountExtractor : IPositionCountExtractor {
	public var countAdd: Int = 2;
	private var countOffset: Int = 0;
	private var countMask: Int = BitUtils.mask(4);
	private var positionOffset: Int = 4;
	private var positionMask: Int = BitUtils.mask(12);

	public fun setCountPositionBits(countBits: Int, positionBits: Int, countAdd: Int): IPositionCountExtractor {
		if (countBits + positionBits != 16) throw Exception("Invalid bots $countBits, $positionBits")

		this.countOffset = 0;
		this.countMask = BitUtils.mask(countBits);

		this.positionOffset = countBits;
		this.positionMask = BitUtils.mask(positionBits);

		this.countAdd = countAdd;

		return this;
	}

	//@:noStack
	public override fun extractPosition(param: Int): Int {
		return BitUtils.extractWithMask(param, positionOffset, positionMask);
	}

	//@:noStack
	public override fun extractCount(param: Int): Int {
		return BitUtils.extractWithMask(param, countOffset, countMask) + countAdd;
	}
}

class RingBuffer(size: Int, position: Int = 0) {
	private var readPosition: Int = position
	private var writePosition: Int = position
	private var length: Int = size
	private var mask: Int = size - 1
	private var bytes = ByteArray(size);

	//@:noStack
	public fun setReadPosition(readPosition: Int) {
		this.readPosition = readPosition and mask;
	}

	//#if cpp @:functionCode("return this->bytesData->__unsafe_get(((int((this->readPosition)++) & int(this->mask))));") #end
	//@:noStack
	public fun readByte(): Int = bytes[readPosition++ and mask].toInt()

	//#if cpp @:functionCode("
	//this->bytesData->__unsafe_set((int((this->writePosition)++) & int(this->mask)), value);
	//return null();
	//") #end
	//@:noStack
	public fun writeByte(value: Int) {
		bytes[writePosition++ and mask] = value.toByte()
		//bytesData[writePosition++ & mask] = cast value;
	}
}