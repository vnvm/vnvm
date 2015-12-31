package com.vnvm.common.image.format

import com.vnvm.common.IRectangle
import com.vnvm.common.error.InvalidArgumentException
import com.vnvm.common.error.InvalidOperationException
import com.vnvm.common.image.BitmapData
import com.vnvm.common.image.BitmapData8
import com.vnvm.common.image.Color
import com.vnvm.common.image.Palette
import com.vnvm.common.io.BinBytes

object BMP {
	fun decode(bytesData: ByteArray): BitmapData {
		val bytes = BinBytes(bytesData)
		// BITMAPFILEHEADER
		val magic = bytes.readUTFBytes(2);
		val bmpSize = bytes.readUnsignedInt();
		val reserved1 = bytes.readUnsignedShort();
		val reserved2 = bytes.readUnsignedShort();
		val dataOffset = bytes.readUnsignedInt();
		if (magic != "BM") throw InvalidArgumentException("Not a BMP")

		// BITMAPINFOHEADER
		val biSize = bytes.readUnsignedInt();
		if (biSize != 40) throw InvalidArgumentException("Invalid BITMAPINFOHEADER $biSize")
		val biData = bytes.readStream(biSize - 4)
		val width = biData.readUnsignedInt();
		val height = biData.readUnsignedInt();
		val planes = biData.readUnsignedShort();
		val bitCount = biData.readUnsignedShort();
		val compression = biData.readUnsignedInt();
		if (compression != 0) throw InvalidArgumentException("Not supported compression $compression");
		val sizeImage = biData.readUnsignedInt();
		val pixelsPerMeterX = biData.readUnsignedInt();
		val pixelsPerMeterY = biData.readUnsignedInt();
		var colorsUsed0 = biData.readUnsignedInt();
		val colorImportant = biData.readUnsignedInt();
		val colorsUsed = if (colorsUsed0 == 0) 0x100 else colorsUsed0
		val palette = if (bitCount == 8) {
			(0 until colorsUsed).map {
				val r = bytes.readUnsignedByte();
				val g = bytes.readUnsignedByte();
				val b = bytes.readUnsignedByte();
				val reserved = bytes.readUnsignedByte();
				Color(r, g, b, 0xFF)
			}
		} else {
			listOf()
		}

		// LINES
		val calculatedSizeImage = width * height * planes * (bitCount / 8);
		//if (calculatedSizeImage != sizeImage) throw(new Error("Invalid sizeImage"));
		//var pixelData:ByteArray = bytes.readBytes(pixelSize);

		bytes.position = dataOffset;
		var bitmapData = BitmapData(width, height);

		when (bitCount) {
			8 -> decodeRows8(bytes, bitmapData, palette);
			24 -> decodeRows24(bytes, bitmapData);
			else -> throw InvalidOperationException("Not implemented bitCount=$bitCount")
		}

		return bitmapData;
	}

	private fun decodeRows8(bytes: BinBytes, bitmapData: BitmapData, palette: List<Color>): Unit {
		val bmp8 = BitmapData8(bitmapData.width, bitmapData.height)
		//println(bmp8[0, 0])
		bmp8.setPixels(bmp8.rect, bytes.readBytes(bitmapData.width * bitmapData.height))
		bmp8.drawToBitmapDataWithPalette(bitmapData, Palette(palette.map { it.toMutable() }))
		bitmapData.flipY()
	}

	private fun decodeRows24(bytes: BinBytes, bitmapData: BitmapData): Unit {
		var width = bitmapData.width
		var height = bitmapData.height

		var row = ByteArray(width * 4)
		for (y in 0 until height) {
			var opos = 0
			for (x in 0 until width) {
				val r = bytes.readUnsignedByte().toByte()
				val g = bytes.readUnsignedByte().toByte()
				val b = bytes.readUnsignedByte().toByte()
				val a = 0xFF.toByte()
				row[opos++] = b
				row[opos++] = g
				row[opos++] = r
				row[opos++] = a
			}
			bitmapData.setPixels(IRectangle(0, height - y - 1, width, 1), row);
			//bitmapData.setPixels(IRectangle(0, y, width, 1), row);
		}
	}
}
