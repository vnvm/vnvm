package com.vnvm.common.image.format

import com.vnvm.common.error.InvalidOperationException
import com.vnvm.common.image.BitmapData

object Imaging {
	interface Provider {
		fun isValid(data: ByteArray): Boolean
		fun decode(data: ByteArray): BitmapData
		fun encode(data: BitmapData): ByteArray
	}

	val providers: List<Provider> = listOf(
		BMP, TGA, PNG
	)

	fun load(data: ByteArray): BitmapData {
		for (provider in providers) {
			if (provider.isValid(data)) return provider.decode(data)
		}
		throw InvalidOperationException("Don't know how to decode image")
	}

}