package com.vnvm.common.image.format

import com.vnvm.common.IRectangle
import com.vnvm.common.Memory
import com.vnvm.common.Std
import com.vnvm.common.error.InvalidArgumentException
import com.vnvm.common.error.InvalidOperationException
import com.vnvm.common.image.BitmapData
import com.vnvm.common.image.BmpColor
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
				val b = bytes.readUnsignedByte();
				val g = bytes.readUnsignedByte();
				val r = bytes.readUnsignedByte();
				val reserved = bytes.readUnsignedByte();
				BmpColor(r, g, b, 0xFF)
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

	private fun decodeRows8(bytes: BinBytes, bitmapData: BitmapData, palette: List<BmpColor>): Unit {
		val width: Int = bitmapData.width
		val height: Int = bitmapData.height;

		var bmpData: ByteArray = ByteArray(width * height * 4)
		var paletteInt: IntArray = palette.map { it.getPixel32() }.toIntArray()
		var stride: Int = width * 4;

		Memory.select(bmpData);
		for (y in 0 until height) {
			var n: Int = (height - y - 1) * stride;
			for (x in 0 until width) {
				var index: Int = bytes.readUnsignedByte();
				//Log.trace(Std.format("INDEX: $index, ${palette.length}"));
				Memory.setI32(n, paletteInt[index]);
				n += 4;
			}
		}
		bitmapData.setPixels(IRectangle(0, 0, width, height), bmpData);
		Memory.select(null);

		// Free memory
		ByteArrayUtils.freeByteArray(bmpData);
	}

	private fun decodeRows24(bytes: BinBytes, bitmapData: BitmapData): Unit {
		var width = bitmapData.width
		var height = bitmapData.height

		var bmpData = ByteArray(width * height * 4)
		var opos = 0
		var ipos = 0
		for (y in 0 until height) {
			for (x in 0 until width) {
				val r = bytes[ipos++]
				val g = bytes[ipos++]
				val b = bytes[ipos++]
				val a = 0xFF.toByte()
				bmpData[opos++] = a
				bmpData[opos++] = b
				bmpData[opos++] = g
				bmpData[opos++] = r
			}
			bitmapData.setPixels(IRectangle(0, height - y - 1, width, 1), bmpData);
		}
	}
}
