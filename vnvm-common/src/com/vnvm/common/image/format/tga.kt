package com.vnvm.common.image.format

import com.vnvm.common.error.noImpl
import com.vnvm.common.image.BitmapData

object TGA : Imaging.Provider {
	override fun isValid(data: ByteArray): Boolean {
		//noImpl
		return false
	}

	override fun decode(data: ByteArray): BitmapData {
		noImpl
	}

	override fun encode(data: BitmapData): ByteArray {
		/*
		typedef struct {
		char  idlength;
		char  colourmaptype;
		char  datatypecode;
		short int colourmaporigin;
		short int colourmaplength;
		char  colourmapdepth;
		short int x_origin;
		short int y_origin;
		short width;
		short height;
		char  bitsperpixel;
		char  imagedescriptor;
		} HEADER;
		 */
		val width = data.width
		val height = data.height
		val out = ByteArray(18 + data.width * data.height * 4)
		out[0] = 0
		out[1] = 0
		out[2] = 2                         /* uncompressed RGB */
		out[3] = 0
		out[4] = 0
		out[5] = 0
		out[6] = 0
		out[7] = 0
		// x-orig
		out[8] = 0
		out[9] = 0
		// y-orig
		out[10] = 0
		out[11] = 0
		out[12] = (width and 0x00FF).toByte()
		out[13] = ((width and 0xFF00) / 256).toByte()
		out[14] = (height and 0x00FF).toByte()
		out[15] = ((height and 0xFF00) / 256).toByte()
		// 32 bit bitmap
		out[16] = 32
		out[17] = 0
		data.foreach { x, y, n, color ->
			out[18 + n * 4 + 0] = BitmapData.b(color)
			out[18 + n * 4 + 1] = BitmapData.g(color)
			out[18 + n * 4 + 2] = BitmapData.r(color)
			out[18 + n * 4 + 3] = BitmapData.a(color)
		}
		return out
	}
}