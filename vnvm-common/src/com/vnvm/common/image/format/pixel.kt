package com.vnvm.common.image.format

import com.vnvm.common.BitUtils

interface IPixelFormat {
	fun extractRed(value: Int): Int;
	fun extractGreen(value: Int): Int;
	fun extractBlue(value: Int): Int;
	fun extractAlpha(value: Int): Int;
}

class PixelFormat565 : IPixelFormat {
	override public fun extractRed(value: Int): Int {
		return BitUtils.extractScaled(value, 11, 5, 0xFF);
	}

	override public fun extractGreen(value: Int): Int {
		return BitUtils.extractScaled(value, 5, 6, 0xFF);
	}

	override public fun extractBlue(value: Int): Int {
		return BitUtils.extractScaled(value, 0, 5, 0xFF);
	}

	override public fun extractAlpha(value: Int): Int {
		return 0xFF;
	}
}
