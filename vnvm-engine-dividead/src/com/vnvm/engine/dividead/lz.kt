package com.vnvm.engine.dividead

import com.vnvm.common.collection.getu
import com.vnvm.common.collection.sub
import com.vnvm.common.error.InvalidOperationException
import com.vnvm.common.io.BinBytes
import com.vnvm.common.measure

object LZ {
	fun isCompressed(data: ByteArray): Boolean {
		return BinBytes(data).readUTFBytes(2) == "LZ"
	}

	fun decode(data: ByteArray): ByteArray {
		val data = BinBytes(data)
		var magic = data.readUTFBytes(2)
		var compressedSize = data.readInt()
		var uncompressedSize = data.readInt()

		if (magic != "LZ") throw InvalidOperationException("Invalid LZ stream")

		return _decode(data, uncompressedSize)
	}

	private fun _decode(input: BinBytes, uncompressedSize: Int): ByteArray {
		return measure("decoding image") { _decodeFast(input, uncompressedSize) }
	}

	/*
	private fun _decodeGeneric(input:BinBytes, uncompressedSize:Int):ByteArray {
		var options = LzOptions()

		options.ringBufferSize = 0x1000
		options.startRingBufferPos = 0xFEE
		//options.setCountPositionBits(4, 12)
		options.compressedBit = 0
		options.countPositionBytesHighFirst = false
		options.positionCountExtractor = new DivideadPositionCountExtractor()

		return LzDecoder.decode(input, options, uncompressedSize)
	}
	*/

	// @:noStack
	private fun _decodeFast(input: BinBytes, uncompressedSize: Int): ByteArray {
		val i = input.data
		var ip = input.position
		val il = input.length

		val o = ByteArray(uncompressedSize + 0x1000)
		var op = 0x1000
		val ringStart = 0xFEE

		while (ip < il) {
			var code = i.getu(ip++) or 0x100

			while (code != 1) {
				// Uncompressed
				if ((code and 1) != 0) {
					o[op++] = i[ip++]
				}
				// Compressed
				else {
					if (ip >= il) break
					val paramL = i.getu(ip++)
					val paramH = i.getu(ip++)
					val param = paramL or (paramH shl 8)
					val ringOffset = extractPosition(param)
					val ringLength = extractCount(param)
					val convertedP2 = ((ringStart + op) and 0xFFF) - ringOffset
					val convertedP = if (convertedP2 < 0) convertedP2 + 0x1000 else convertedP2 
					val outputReadOffset = op - convertedP
					for (n in 0 until ringLength) o[op + n] = o[outputReadOffset + n]
					op += ringLength
				}

				code = code ushr 1
			}
		}

		return o.sub(0x1000, uncompressedSize)
	}

	private fun extractPosition(param: Int): Int {
		return (param and 0xFF) or ((param ushr 4) and 0xF00)
	}

	private fun extractCount(param: Int): Int {
		return ((param ushr 8) and 0xF) + 3
	}
}

/*
class DivideadPositionCountExtractor : IPositionCountExtractor {
	//@:noStack
	override public fun extractPosition(param: Int): Int {
		return (param and 0xFF) or ((param ushr 4) and 0xF00)
	}

	//@:noStack
	override public fun extractCount(param: Int): Int {
		return ((param ushr 8) and 0xF) + 3
	}
}
*/
