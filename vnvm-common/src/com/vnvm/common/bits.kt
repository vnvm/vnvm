package com.vnvm.common

object BitUtils {
	@JvmStatic public fun pack16(b1:Int, b2:Int):Int {
		return ((b1 and 0xFF) shl 0) or ((b2 and 0xFF) shl 8)
	}

	@JvmStatic public fun pack32(b1:Int, b2:Int, b3:Int, b4:Int):Int {
		return ((b1 and 0xFF) shl 0) or ((b2 and 0xFF) shl 8) or ((b3 and 0xFF) shl 16) or ((b4 and 0xFF) shl 24)
	}

	@JvmStatic public fun mask(bits:Int):Int {
		return ((1 shl bits) - 1);
	}

	@JvmStatic public fun extract(value:Int, offset:Int, bits:Int):Int {
		return (value ushr offset) and mask(bits);
	}

	@JvmStatic public fun extractScaled(value:Int, offset:Int, bits:Int, destination:Int):Int {
		return extractWithMask(value, offset, mask(bits)) * destination / mask(bits)
	}

	@JvmStatic public fun extractWithMask(value:Int, offset:Int, mask:Int):Int {
		return (value ushr offset) and mask;
	}

	@JvmStatic fun rotateRight8(value:Int, offset:Int):Int {
		return _rotateRightBits((value and 0xFF), offset, 8);
	}

	@JvmStatic private fun _rotateRightBits(value:Int, offset:Int, bits:Int):Int {
		return (value ushr offset) or (value shl (bits - offset));
	}
}

fun Int.clamp(min:Int, max:Int) = if (this < min) min else if (this > max) max else this
fun Double.clamp(min:Double, max:Double) = if (this < min) min else if (this > max) max else this
fun Double.clamp01() = this.clamp(0.0, 1.0)

object MathEx {
	@Deprecated("", ReplaceWith("v.clamp(a, b)", "com.vnvm.common.clamp"))
	@JvmStatic fun clamp(v:Int, a:Int, b:Int) = if (v < a) a else if (v > b) b else v

	@Deprecated("", ReplaceWith("v.clamp(a, b)", "com.vnvm.common.clamp"))
	@JvmStatic fun clamp(v:Float, a:Float, b:Float) = if (v < a) a else if (v > b) b else v

	@Deprecated("", ReplaceWith("v.clamp(a, b)", "com.vnvm.common.clamp"))
	@JvmStatic fun clamp(v:Double, a:Double, b:Double) = if (v < a) a else if (v > b) b else v

	@Deprecated("", ReplaceWith("v.clamp(a, b)", "com.vnvm.common.clamp"))
	@JvmStatic fun clampInt(v: Int, a: Int, b: Int): Int = clamp(v, a, b)
}

object Std {
	@Deprecated("", ReplaceWith("v.toInt()"))
	@JvmStatic fun int(v:Double):Int = v.toInt()
	@Deprecated("", ReplaceWith("v"))
	@JvmStatic fun int(v:Int):Int = v
}