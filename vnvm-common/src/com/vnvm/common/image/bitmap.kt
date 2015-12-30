package com.vnvm.common.image

import com.vnvm.common.*
import com.vnvm.common.collection.foreach

enum class BitmapDataChannel {
	RED, GREEN, BLUE, ALPHA
}

class BitmapData(val width: Int, val height: Int, val transparent: Boolean = true, val color: Int = -1) {
	val data: ByteArray = ByteArray(width * height * 4)
	val rect = IRectangle(0, 0, width, height)
	var version = 0

	private fun getOffset(x: Int, y: Int) = (y * width + x) * 4

	private fun _transfer(r: IRectangle, data: ByteArray, dir: Boolean, flipY: Boolean): Unit {
		for (y in 0 until r.height) {
			val y2 = if (flipY) r.height - y - 1 else y
			val outOffset = getOffset(r.left, r.top + y)
			val inOffset = (r.width * y2) * 4
			val size = r.width * 4
			if (dir) {
				System.arraycopy(data, inOffset, this.data, outOffset, size)
			} else {
				System.arraycopy(this.data, outOffset, data, inOffset, size)
			}
		}
	}

	fun setPixels(rect: IRectangle, data: ByteArray, flipY: Boolean = false): Unit {
		lock {
			val r = rect.intersection(this.rect)
			_transfer(r, data, true, flipY)
		}
	}

	fun lock(): Unit {

	}

	fun unlock(): Unit {
		version++
	}

	fun copyPixels(from: BitmapData, rect: IRectangle, pos: IPoint): Unit {
		draw(from, rect, pos.x, pos.y)
	}

	fun getPixel32(x: Int, y: Int): Int {
		return Memory.getI32(data, getOffset(x, y))
	}

	fun setPixel32(x: Int, y: Int, value:Int): Unit {
		Memory.setI32(data, getOffset(x, y), value)
	}

	inline fun lock(callback: () -> Unit) {
		this.lock()
		callback()
		this.unlock()
	}

	//fun draw(bitmapData: BitmapData, matrix: Matrix): Unit = noImpl

	fun draw(bitmapData: BitmapData, rect:IRectangle, px: Int, py: Int): Unit {
		lock {
			for (y in 0 until rect.height) {
				for (x in 0 until rect.width) {
					val tx = px + x
					val ty = py + y
					if (tx < 0 || tx >= this.width) break
					if (ty < 0 || ty >= this.height) break
					this.setPixel32(tx, ty, bitmapData.getPixel32(x + rect.x, y + rect.y))
				}
			}
			//println("drawn!")
		}
	}

	fun draw(bitmapData: BitmapData, px: Int, py: Int): Unit {
		draw(bitmapData, bitmapData.rect, px, py)
	}

	fun getPixels(rect: IRectangle = this.rect, flipY: Boolean = false): ByteArray {
		val r = rect.intersection(this.rect)
		val data = ByteArray(r.area * 4)
		_transfer(r, data, false, flipY)
		return data
	}

	fun copyChannel(sourceBitmapData: BitmapData, sourceRect: IRectangle, destPoint: IPoint, sourceChannel: BitmapDataChannel, destChannel: BitmapDataChannel): Unit {
		println("BitmapData.copyChannel")
	}

	companion object {
		fun color(r:Int, g:Int, b:Int, a:Int):Int = BitUtils.pack32(r, g, b, a)
		fun r(color:Int):Byte = (color ushr 0).toByte()
		fun g(color:Int):Byte = (color ushr 8).toByte()
		fun b(color:Int):Byte = (color ushr 16).toByte()
		fun a(color:Int):Byte = (color ushr 24).toByte()
	}

	inline fun map(callback: (x:Int, y:Int, n:Int) -> Int) {
		lock {
			foreach(width, height) { x, y, n ->
				//println("$width, $height, $x, $y, $n")
				Memory.setI32(data, n * 4, callback(x, y, n))
			}
		}
	}

	fun foreach(callback: (x:Int, y:Int, n:Int, color:Int) -> Unit) {
		foreach(width, height) { x, y, n ->
			//println("$width, $height, $x, $y, $n")
			val color = Memory.getI32(data, n * 4)
			callback(x, y, n, color)
		}
	}

	fun flipY() {
		val temp = ByteArray(width * 4)
		for (y in 0 until height) {
			val row1 = getOffset(0, y)
			val row2 = getOffset(0, height - y - 1)
			val size = width * 4
			System.arraycopy(data, row1, temp, 0, size)
			System.arraycopy(data, row2, data, row1, size)
			System.arraycopy(temp, 0, data, row2, size)
		}
	}
}


object BitmapDataUtils {
	fun slice(source: BitmapData, rect: IRectangle): BitmapData {
		var destination: BitmapData = BitmapData(rect.width, rect.height);
		destination.copyPixels(source, rect, IPoint(0, 0))
		return destination;
	}

	fun combineColorMask(color: BitmapData, mask: BitmapData): BitmapData {
		var newBitmap = BitmapData(color.width, color.height, true, 0x00000000);
		newBitmap.copyPixels(color, color.rect, IPoint(0, 0));
		newBitmap.copyChannel(mask, mask.rect, IPoint(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
		return newBitmap;
	}

	fun chromaKey(image: BitmapData, chromaKey: Int): BitmapData {
		var colors = image.getPixels(image.rect);
		var output = BitmapData(image.width, image.height, true, 0);
		Memory.select(colors) {
			var m = 0;
			val chromaKey2 = chromaKey and 0xFFFFFF;
			for (n in 0 until colors.size / 4) {
				var c = Memory.getI32(m);
				if (((c ushr 8) and 0xFFFFFF) == chromaKey2) c = 0;
				Memory.setI32(m, c);
				m += 4;
			}
		}
		output.setPixels(image.rect, colors);
		return output;
	}

	/*
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
	*/
}

/*
class BitmapDataBuilder
{
	public var bitmapData(default, null):BitmapData;

	private function new(width:Int, height:Int)
	{
		this.bitmapData = new BitmapData(width, height, true, 0x00000000);
	}

	static public function create(width:Int, height:Int):BitmapDataBuilder
	{
		return new BitmapDataBuilder(width, height);
	}

	public function noise():BitmapDataBuilder
	{
		this.bitmapData.noise(0);
		return this;
	}
}

class BitmapDataSerializer
{
	static private inline var outputPixelSize = 4;

	@:noStack static public function decode(input:ByteArray, width:Int, height:Int, channels:String = "argb", interleaved:Bool = true):BitmapData
	{
		var inputStart = input.position;
		var output = ByteArrayUtils.newByteArrayWithLength(width * height * 4, Endian.LITTLE_ENDIAN);
		var totalPixels = width * height;
		var inputPixelSize = interleaved ? channels.length : 1;
		var displacementNextChannel = interleaved ? 1 : totalPixels;
		var channelStartOffset = 0;

		for (channelChar in channels.split(''))
		{
			var readOffset = inputStart + channelStartOffset;
			var writeOffset = getChannelOffset(channelChar);
			for (n in 0 ... totalPixels)
			{
				output[writeOffset] = input[readOffset];
				readOffset += inputPixelSize;
				writeOffset += outputPixelSize;
			}
			channelStartOffset += displacementNextChannel;
		}

		if (channels.indexOf('a') < 0)
		{
			var writeOffset = getChannelOffset('a');
			for (n in 0 ... totalPixels)
			{
				output[writeOffset] = 0xFF;
				writeOffset += outputPixelSize;
			}
		}

		return BitmapDataSerializer.fromByteArray(width, height, output);
	}

	static public function getChannelOffset(channelChar:String):Int
	{
		#if flash9
		return switch (channelChar) { case 'a': 3; case 'r': 2; case 'g': 1; case 'b': 0; default: throw('Invalid channel char $channelChar'); }
		#else
		return switch (channelChar) { case 'a': 0; case 'r': 1; case 'g': 2; case 'b': 3; default: throw('Invalid channel char $channelChar'); }
		#end
	}

	static public function fromByteArray(width:Int, height:Int, data:ByteArray):BitmapData
	{
		var bitmapData = new BitmapData(width, height, true, 0x00000000);

		bitmapData.setPixels(bitmapData.rect, data);

		return bitmapData;
	}
}

class GraphicUtils
{
	static private var matrix:Matrix = new Matrix();

	static public function drawBitmapSlice(graphics:Graphics, bitmapData:BitmapData, dstX:Int, dstY:Int, srcX:Int, srcY:Int, dstW:Int, dstH:Int, ?srcW:Int, ?srcH:Int):Void {
	if (srcW == null) srcW = dstW;
	if (srcH == null) srcH = dstH;

	var pointTL:Point = new Point(dstX       , dstY       );
	var pointBR:Point = new Point(dstX + dstW, dstY + dstH);

	var uvPointTL:Point = new Point((srcX) / bitmapData.width, (srcY) / bitmapData.height);
	var uvPointBR:Point = new Point((srcX + srcW) / bitmapData.width, (srcY + srcH) / bitmapData.height);

	var verticies:Array<Float> = [pointTL.x, pointTL.y, pointBR.x, pointTL.y, pointTL.x, pointBR.y, pointBR.x, pointBR.y];
	var uvtData:Array<Float> = [uvPointTL.x, uvPointTL.y, uvPointBR.x, uvPointTL.y, uvPointTL.x, uvPointBR.y, uvPointBR.x, uvPointBR.y];
	var indices:Array<Int> = [0, 1, 2, 1, 3, 2];

	graphics.beginBitmapFill(bitmapData, null, false, true);
	#if flash
	graphics.drawTriangles(Vector.ofArray(verticies), Vector.ofArray(indices), Vector.ofArray(uvtData));
	#else
	graphics.drawTriangles(cast verticies, cast indices, cast uvtData);
	#end
	graphics.endFill();
}

	static public function drawSolidFilledRectWithBounds(graphics:Graphics, x0:Float, y0:Float, x1:Float, y1:Float, rgb:Int = 0x000000, alpha:Float = 1.0):Void {
	var x = x0;
	var y = y0;
	var w = x1 - x0;
	var h = y1 - y0;
	graphics.beginFill(rgb, alpha);
	graphics.drawRect(x, y, w, h);
	graphics.endFill();
}
}
*/
