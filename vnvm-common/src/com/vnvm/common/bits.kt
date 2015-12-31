package com.vnvm.common

object BitUtils {
	@JvmStatic public fun readShortBE(data: ByteArray, offset: Int): Short {
		return pack16(data[offset + 1], data[offset + 0]).toShort()
	}

	@JvmStatic public fun readIntBE(data: ByteArray, offset: Int): Int {
		return pack32(data[offset + 3], data[offset + 2], data[offset + 1], data[offset + 0])
	}

	@JvmStatic public fun readShortLE(data: ByteArray, offset: Int): Short {
		return pack16(data[offset + 0], data[offset + 1]).toShort()
	}

	@JvmStatic public fun readIntLE(data: ByteArray, offset: Int): Int {
		return pack32(data[offset + 0], data[offset + 1], data[offset + 2], data[offset + 3])
	}

	@JvmStatic public fun readLongLE(data: ByteArray, offset: Int): Long {
		return pack64(
			data[offset + 0].toInt(), data[offset + 1].toInt(), data[offset + 2].toInt(), data[offset + 3].toInt(),
			data[offset + 4].toInt(), data[offset + 5].toInt(), data[offset + 6].toInt(), data[offset + 7].toInt()
		)
	}

	@JvmStatic public fun writeIntLE(data: ByteArray, offset: Int, value: Int): Unit {
		data[offset + 0] = (value ushr 0).toByte()
		data[offset + 1] = (value ushr 8).toByte()
		data[offset + 2] = (value ushr 16).toByte()
		data[offset + 3] = (value ushr 24).toByte()
	}

	@JvmStatic public fun pack16(b1: Int, b2: Int): Int {
		return ((b1 and 0xFF) shl 0) or ((b2 and 0xFF) shl 8)
	}

	@JvmStatic public fun pack16(b1: Byte, b2: Byte): Int {
		return pack16(b1.toInt(), b2.toInt())
	}

	@JvmStatic public fun pack32(b1: Int, b2: Int, b3: Int, b4: Int): Int {
		return ((b1 and 0xFF) shl 0) or ((b2 and 0xFF) shl 8) or ((b3 and 0xFF) shl 16) or ((b4 and 0xFF) shl 24)
	}

	@JvmStatic public fun pack64(b1: Int, b2: Int, b3: Int, b4: Int, b5: Int, b6: Int, b7: Int, b8: Int): Long {
		return (
			((b1 and 0xFF) shl 0).toLong() or ((b2 and 0xFF) shl 8).toLong() or ((b3 and 0xFF) shl 16).toLong() or ((b4 and 0xFF) shl 24).toLong() or
				((b5 and 0xFF) shl 32).toLong() or ((b6 and 0xFF) shl 40).toLong() or ((b7 and 0xFF) shl 48).toLong() or ((b8 and 0xFF) shl 56).toLong()
			)
	}

	@JvmStatic public fun pack32(b1: Byte, b2: Byte, b3: Byte, b4: Byte): Int {
		return pack32(b1.toInt(), b2.toInt(), b3.toInt(), b4.toInt())
	}

	@JvmStatic public fun mask(bits: Int): Int {
		return ((1 shl bits) - 1);
	}

	@JvmStatic public fun extract(value: Int, offset: Int, bits: Int): Int {
		return (value ushr offset) and mask(bits);
	}

	@JvmStatic public fun extractScaled(value: Int, offset: Int, bits: Int, destination: Int): Int {
		return extractWithMask(value, offset, mask(bits)) * destination / mask(bits)
	}

	@JvmStatic public fun extractWithMask(value: Int, offset: Int, mask: Int): Int {
		return (value ushr offset) and mask;
	}

	@JvmStatic fun rotateRight8(value: Int, offset: Int): Int {
		return _rotateRightBits((value and 0xFF), offset, 8);
	}

	@JvmStatic private fun _rotateRightBits(value: Int, offset: Int, bits: Int): Int {
		return (value ushr offset) or (value shl (bits - offset));
	}
}

fun Int.clamp(min: Int, max: Int) = if (this < min) min else if (this > max) max else this
fun Long.clamp(min: Long, max: Long) = if (this < min) min else if (this > max) max else this
fun Double.clamp(min: Double, max: Double) = if (this < min) min else if (this > max) max else this
fun Double.clamp01() = this.clamp(0.0, 1.0)

object MathEx {
	@Deprecated("", ReplaceWith("v.clamp(a, b)", "com.vnvm.common.clamp"))
	@JvmStatic fun clamp(v: Int, a: Int, b: Int) = if (v < a) a else if (v > b) b else v

	@Deprecated("", ReplaceWith("v.clamp(a, b)", "com.vnvm.common.clamp"))
	@JvmStatic fun clamp(v: Float, a: Float, b: Float) = if (v < a) a else if (v > b) b else v

	@Deprecated("", ReplaceWith("v.clamp(a, b)", "com.vnvm.common.clamp"))
	@JvmStatic fun clamp(v: Double, a: Double, b: Double) = if (v < a) a else if (v > b) b else v

	@Deprecated("", ReplaceWith("v.clamp(a, b)", "com.vnvm.common.clamp"))
	@JvmStatic fun clampInt(v: Int, a: Int, b: Int): Int = clamp(v, a, b)

	@JvmStatic fun min(a: Int, b: Int, c: Int, d: Int) = Math.min(Math.min(Math.min(a, b), c), d)
	@JvmStatic fun max(a: Int, b: Int, c: Int, d: Int) = Math.max(Math.max(Math.max(a, b), c), d)
}

object Std {
	@Deprecated("", ReplaceWith("v.toInt()"))
	@JvmStatic fun int(v: Double): Int = v.toInt()

	@Deprecated("", ReplaceWith("v"))
	@JvmStatic fun int(v: Int): Int = v
}