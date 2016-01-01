package com.vnvm.common.image.format

import com.vnvm.common.image.BitmapData
import java.io.ByteArrayInputStream
import javax.imageio.ImageIO

object PNG : Imaging.Provider {
	override fun isValid(data: ByteArray): Boolean {
		return data.slice(0 until 4) == listOf<Byte>(0x89.toByte(), 0x50, 0x4E, 0x47)
	}

	override fun decode(data: ByteArray): BitmapData {
		// @TODO: Implement this whout javax
		val image = ImageIO.read(ByteArrayInputStream(data))
		val width = image.width
		val height = image.height
		//val data = image.getData(Rectangle(0, 0, width, height))
		//val pixels = data.getPixels(0, 0, width, height, IntArray(width * height))
		val out = BitmapData(width, height)
		var n = 0
		for (y in 0 until height) {
			for (x in 0 until width) {
				out.setPixel32(x, y, image.getRGB(x, y))
				n++
			}
		}
		return out
	}

	override fun encode(data: BitmapData): ByteArray {
		throw UnsupportedOperationException()
	}
}