package com.vnvm.common.image

import com.vnvm.common.BitUtils
import com.vnvm.common.clamp01
import com.vnvm.common.clamp255

interface BColor {
	val r: Int
	val g: Int
	val b: Int
	val a: Int
}

fun BColor.toInt() = Color.packRGBA(r, g, b, a)

class MutableColor(
	override var r: Int,
	override var g: Int,
	override var b: Int,
	override var a: Int
) : BColor {
	init {
		r = r and 0xFF
		g = g and 0xFF
		b = b and 0xFF
		a = a and 0xFF
	}

	constructor() : this(0, 0, 0, 255)

	constructor(value: Int) : this(Color.getR(value), Color.getG(value), Color.getB(value), Color.getA(value))

	constructor(color: MutableColor) : this(color.r, color.g, color.b, color.a)

	constructor(color: Color) : this(color.r, color.g, color.b, color.a)

	fun mix(old: BColor, new: BColor, ratio: Double): MutableColor {
		return this.set(
			Color.mixComp(old.r, new.r, ratio),
			Color.mixComp(old.g, new.g, ratio),
			Color.mixComp(old.b, new.b, ratio),
			Color.mixComp(old.a, new.a, ratio)
		)
	}

	fun set(r: Int, g: Int, b: Int, a: Int): MutableColor {
		this.r = r and 0xFF
		this.g = g and 0xFF
		this.b = b and 0xFF
		this.a = a and 0xFF
		return this
	}

	fun setAdd(left: BColor, right: BColor): MutableColor {
		return this.set(
			(left.r + right.r) and 0xFF,
			(left.g + right.g) and 0xFF,
			(left.b + right.b) and 0xFF,
			(left.a + right.a) and 0xFF
		)
	}

	fun setInterpolate(left: BColor, right: BColor, step: Double): MutableColor {
		var step_l = step.clamp01();
		var step_r = 1.0 - step_l;
		return this.set(
			((left.r * step_l + right.r * step_r).toInt()) and 0xFF,
			((left.g * step_l + right.g * step_r).toInt()) and 0xFF,
			((left.b * step_l + right.b * step_r).toInt()) and 0xFF,
			((left.a * step_l + right.a * step_r).toInt()) and 0xFF
		);
	}

	fun setAvg(left: BColor, right: BColor): MutableColor {
		return this.set(
			((left.r + right.r) ushr 1) and 0xFF,
			((left.g + right.g) ushr 1) and 0xFF,
			((left.b + right.b) ushr 1) and 0xFF,
			((left.a + right.a) ushr 1) and 0xFF
		);
	}


	fun set(color: Color) = this.set(color.r, color.g, color.b, color.a)
	fun set(color: MutableColor) = this.set(color.r, color.g, color.b, color.a)
	fun set(value: Int) = this.set(Color.getR(value), Color.getG(value), Color.getB(value), Color.getA(value))
	fun toColor(): Color = Color(r, g, b, a)
	fun toInt() = Color.packRGBA(r, g, b, a)
}

class Color(r: Int, g: Int, b: Int, a: Int) : BColor {
	override val r: Int = r and 0xff
	override val g: Int = g and 0xff
	override val b: Int = b and 0xff
	override val a: Int = a and 0xff

	val rf: Float get() = r.toFloat() / 255f
	val gf: Float get() = g.toFloat() / 255f
	val bf: Float get() = b.toFloat() / 255f
	val af: Float get() = a.toFloat() / 255f

	companion object {
		const val BShift = 0
		const val GShift = 8
		const val RShift = 16
		const val AShift = 24

		fun getB(value: Int): Int = (value ushr BShift) and 0xFF
		fun getG(value: Int): Int = (value ushr GShift) and 0xFF
		fun getR(value: Int): Int = (value ushr RShift) and 0xFF
		fun getA(value: Int): Int = (value ushr AShift) and 0xFF

		fun getBf(value: Int): Double = getB(value).toDouble() / 255.0
		fun getGf(value: Int): Double = getG(value).toDouble() / 255.0
		fun getRf(value: Int): Double = getR(value).toDouble() / 255.0
		fun getAf(value: Int): Double = getA(value).toDouble() / 255.0

		fun packRGBA(r: Int, g: Int, b: Int, a: Int): Int = BitUtils.pack32(b, g, r, a)
		fun mixComp(x: Int, y: Int, ratio: Double) = ((x * (1.0 - ratio)) + y * ratio).toInt().clamp255()
		fun mixRGBA(x: Int, y: Int, ratio: Double): Int {
			return packRGBA(
				mixComp(getR(x), getR(y), ratio),
				mixComp(getG(x), getG(y), ratio),
				mixComp(getB(x), getB(y), ratio),
				mixComp(getA(x), getA(y), ratio)
			)
		}

		fun mixRGBAv2(x: Int, y: Int, ratio: Double): Int {
			return mixRGBA(x, y, getAf(y) * ratio)
		}

		fun add(left: Color, right: Color) = MutableColor().setAdd(left, right).toColor()
		fun interpolate(left: Color, right: Color, step: Double) = MutableColor().setInterpolate(left, right, step).toColor()
		fun avg(left: Color, right: Color) = MutableColor().setAvg(left, right).toColor()
	}

	fun toMutable() = MutableColor(r, g, b, a)
	fun toInt() = Color.packRGBA(r, g, b, a)
}

object Colors {
	val BLACK = Color(0, 0, 0, 255)
	val WHITE = Color(255, 255, 255, 255)
	val RED = Color(255, 0, 0, 255)
	val GREEN = Color(0, 255, 0, 255)
	val BLUE = Color(0, 0, 255, 255)
}