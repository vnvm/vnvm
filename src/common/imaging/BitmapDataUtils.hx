package common.imaging;
import reflash.Bytes3;
import lang.MathEx;
import haxe.io.Bytes;
import lang.exceptions.OutOfBoundsException;
import flash.Vector;
import haxe.io.BytesData;
import flash.errors.Error;
import common.imaging.BitmapDataSerializer;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author soywiz
 */

class BitmapDataUtils
{
	static public function slice(source:BitmapData, rect:Rectangle):BitmapData
	{
		var destination:BitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height));
		destination.copyPixels(source, rect, new Point(0, 0));
		return destination;
	}

	static public function combineColorMask(color:BitmapData, mask:BitmapData):BitmapData
	{
		var newBitmap:BitmapData = new BitmapData(color.width, color.height, true, 0x00000000);
		//newBitmap.copyPixels(color, color.rect, new Point(0, 0), mask, new Point(0, 0), false);
		newBitmap.copyPixels(color, color.rect, new Point(0, 0));
		newBitmap.copyChannel(mask, mask.rect, new Point(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
		return newBitmap;
	}

	@:noStack static private function _blend(colorDataData:BytesData, maskDataData:BytesData, totalPixels:Int, readOffset:Int, writeOffset:Int, ratio:Float, reverse:Bool)
	{
		var colorDataData2 = new Bytes3(Bytes.ofData(colorDataData));
		var offset:Int = Std.int(MathEx.translateRange(ratio, 0, 1, -255, 255));
		if (reverse) offset = -offset;

		while (totalPixels-- > 0)
		{
			//Log.trace('$writeOffset, $readOffset');
			var value = MathEx.clampInt(cast(Bytes.fastGet(maskDataData, readOffset), Int) + offset, 0, 255);
			if (reverse) value = 255 - value;
			colorDataData2[writeOffset] = cast value;
			readOffset += 4;
			writeOffset += 4;
		}
	}

	@:noStack static private function _mask(colorDataData:BytesData, maskDataData:BytesData, totalPixels:Int, readOffset:Int, writeOffset:Int, ratio:Float, reverse:Bool)
	{
		var colorDataData2 = new Bytes3(Bytes.ofData(colorDataData));
		var maskDataData2 = new Bytes3(Bytes.ofData(maskDataData));
		var thresold:Int = Std.int(MathEx.translateRange(ratio, 0, 1, 0, 255));
		if (reverse) thresold = 255 - thresold;

		while (totalPixels-- > 0)
		{
			var value = (cast(maskDataData2[readOffset], Int) >= thresold) ? 0xFF : 0x00;
			if (reverse) value = 255 - value;
			colorDataData2[writeOffset] = cast value;
			readOffset += 4;
			writeOffset += 4;
		}
	}

	static public function applyBlendMaskWithOffset(color:BitmapData, mask:BitmapData, ratio:Float, reverse:Bool):Void
	{
		applyAlphaFunction(color, mask, ratio, _blend, reverse);
	}

	static public function applyNoBlendMaskWithOffset(color:BitmapData, mask:BitmapData, ratio:Float, reverse:Bool):Void
	{
		applyAlphaFunction(color, mask, ratio, _mask, reverse);
	}

	static public function applyAlphaFunction(color:BitmapData, mask:BitmapData, ratio:Float, callback:Dynamic, reverse:Bool):Void
	{
		if (color.width != mask.width || color.height != mask.height) throw(new Error('Invalid arguments ${color.width}x${color.height} != ${mask.width}x${mask.height}}'));

		color.lock();
		{
			var colorData = color.getPixels(color.rect);
			colorData.position = 0;
			var maskData = mask.getPixels(mask.rect);
			maskData.position = 0;

			var colorDataData = colorData.getData();
			var maskDataData = maskData.getData();

			var totalPixels = color.width * color.height;
			var readOffset:Int = BitmapDataSerializer.getChannelOffset('r');
			var writeOffset:Int = BitmapDataSerializer.getChannelOffset('a');

			callback(colorDataData, maskDataData, totalPixels, readOffset, writeOffset, ratio, reverse);

			color.setPixels(color.rect, colorData);
		}
		color.unlock();
	}

	static public function applyPalette(color:BitmapData, palette:Array<Int>):Void
	{
		if (palette.length != 0x100) throw(new OutOfBoundsException("Palette must have 256 elements"));

		color.lock();
		{
			var colorData = color.getPixels(color.rect);
			var colorDataData = Bytes.ofData(colorData.getData());

			var totalPixels = color.width * color.height;

			//var pixels = new Vector<Int>(totalPixels, true);
			//pixels.length = totalPixels;
			var pixels = new Vector<Int>();

			var redOffset:Int = BitmapDataSerializer.getChannelOffset('r');
			var offset:Int = 0;
			for (n in 0 ... totalPixels)
			{
				var value = cast colorDataData.get(offset + redOffset);
				//pixels[n] = palette[value];
				pixels.push(palette[value]);
				offset += 4;
			}
			color.setVector(color.rect, pixels);
		}
		color.unlock();
	}
}