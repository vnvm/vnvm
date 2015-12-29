package com.vnvm.engine.dividead

import com.vnvm.common.image.BitmapData

object SG {
	fun getImage(data:ByteArray): BitmapData {
		//return new BitmapData(640, 480);
		return BMP.decode(LZ.decode(data));
	}
}
