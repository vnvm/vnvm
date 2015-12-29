package com.vnvm.common.image

import com.vnvm.common.IPoint
import com.vnvm.common.IRectangle
import com.vnvm.common.Matrix
import com.vnvm.common.Std
import com.vnvm.common.Std.int
import com.vnvm.common.error.OutOfBoundsException
import com.vnvm.common.error.noImpl

class BitmapData(val width: Int, val height: Int, val transparent: Boolean = true, val color: Int = -1) {
	private val data: ByteArray = ByteArray(width * height * 4)
	val rect = IRectangle(0, 0, width, height)
	fun setPixels(rect: IRectangle, data: ByteArray): Unit = noImpl
	fun lock(): Unit = noImpl
	fun unlock(): Unit = noImpl
	fun copyPixels(from: BitmapData, rect: IRectangle, pos: IPoint): Unit = noImpl
	inline fun lock(callback: () -> Unit) {
		this.lock()
		try {
			callback()
		} finally {
			this.unlock()
		}
	}

	fun draw(bitmapData: BitmapData, matrix: Matrix): Unit {
	}
}


object BitmapDataUtils {
	fun slice(source: BitmapData, rect: IRectangle): BitmapData {
		var destination: BitmapData = BitmapData(rect.width, rect.height);
		destination.copyPixels(source, rect, IPoint(0, 0))
		return destination;
	}

	fun combineColorMask(color: BitmapData, mask: BitmapData): BitmapData {
		var newBitmap: BitmapData = BitmapData(color.width, color.height, true, 0x00000000);
		//newBitmap.copyPixels(color, color.rect, new Point(0, 0), mask, new Point(0, 0), false);
		newBitmap.copyPixels(color, color.rect, IPoint(0, 0));
		newBitmap.copyChannel(mask, mask.rect, IPoint(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
		return newBitmap;
	}

	private fun _blend(colorDataData: BytesData, maskDataData: BytesData, totalPixels: Int, readOffset: Int, writeOffset: Int, ratio: Float, reverse: Bool) {
		var colorDataData2 = new Bytes3(Bytes.ofData(colorDataData));
		var offset: Int = int(MathEx.translateRange(ratio, 0, 1, -255, 255));
		if (reverse) offset = -offset;

		while (totalPixels-- > 0) {
			//Log.trace('$writeOffset, $readOffset');
			var value = MathEx.clampInt(cast(Bytes.fastGet(maskDataData, readOffset), Int) + offset, 0, 255);
			if (reverse) value = 255 - value;
			colorDataData2[writeOffset] = cast value;
			readOffset += 4;
			writeOffset += 4;
		}
	}

	private fun _mask(colorDataData: BytesData, maskDataData: BytesData, totalPixels: Int, readOffset: Int, writeOffset: Int, ratio: Float, reverse: Bool) {
		var colorDataData2 = new Bytes3(Bytes.ofData(colorDataData));
		var maskDataData2 = new Bytes3(Bytes.ofData(maskDataData));
		var thresold: Int = int(MathEx.translateRange(ratio, 0, 1, 0, 255));
		if (reverse) thresold = 255 - thresold;

		while (totalPixels-- > 0) {
			var value = (cast(maskDataData2[readOffset], Int) >= thresold) ? 0xFF : 0x00;
			if (reverse) value = 255 - value;
			colorDataData2[writeOffset] = cast value;
			readOffset += 4;
			writeOffset += 4;
		}
	}

	fun applyBlendMaskWithOffset(color: BitmapData, mask: BitmapData, ratio: Float, reverse: Bool): Void {
		applyAlphaFunction(color, mask, ratio, _blend, reverse);
	}

	fun applyNoBlendMaskWithOffset(color: BitmapData, mask: BitmapData, ratio: Float, reverse: Bool): Void {
		applyAlphaFunction(color, mask, ratio, _mask, reverse);
	}

	fun applyAlphaFunction(color: BitmapData, mask: BitmapData, ratio: Float, callback: Dynamic, reverse: Bool): Void {
		if (color.width != mask.width || color.height != mask.height) throw(new Error('Invalid arguments ${color.width}x${color.height} != ${mask.width}x${mask.height}}'));

		color.lock {
			var colorData = color.getPixels(color.rect);
			colorData.position = 0;
			var maskData = mask.getPixels(mask.rect);
			maskData.position = 0;

			var colorDataData = colorData.getData();
			var maskDataData = maskData.getData();

			var totalPixels = color.width * color.height;
			var readOffset: Int = BitmapDataSerializer.getChannelOffset('r');
			var writeOffset: Int = BitmapDataSerializer.getChannelOffset('a');

			callback(colorDataData, maskDataData, totalPixels, readOffset, writeOffset, ratio, reverse);

			color.setPixels(color.rect, colorData);
		}
	}

	fun chromaKey(image: BitmapData, chromaKey: Int): BitmapData {
		var colors = image.getPixels(image.rect);
		colors.position = 0;
		var output = new BitmapData(image.width, image.height, true, 0);
		trace('ColorsLength:', colors.length);
		Memory.select(colors);
		var m = 0;
		chromaKey = chromaKey and 0xFFFFFF;
		for (n in 0 until colors.length / 4) {
			var c = Memory.getI32(m);
			if (((c > > > 8) & 0xFFFFFF) == chromaKey) c = 0;
			Memory.setI32(m, c);
			m += 4;
		}
		colors.position = 0;
		output.setPixels(image.rect, colors);
		return output;
	}

	fun applyPalette(color: BitmapData, palette: Array<Int>): Void {
		if (palette.size != 0x100) throw OutOfBoundsException("Palette must have 256 elements")

		color.lock {
			var colorData = color.getPixels(color.rect);
			var colorDataData = Bytes.ofData(colorData.getData());

			var totalPixels = color.width * color.height;

			//var pixels = new Vector<Int>(totalPixels, true);
			//pixels.length = totalPixels;
			var pixels = new Vector<Int>();

			var redOffset: Int = BitmapDataSerializer.getChannelOffset('r');
			var offset: Int = 0;
			for (n in 0 until totalPixels) {
				var value = cast colorDataData.get(offset + redOffset);
				//pixels[n] = palette[value];
				pixels.push(palette[value]);
				offset += 4;
			}
			color.setVector(color.rect, pixels);
		}
	}
}