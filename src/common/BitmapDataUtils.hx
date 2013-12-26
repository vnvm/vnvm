package common;
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

	@:noStack static private function _blend(colorDataData:BytesData, maskDataData:BytesData, totalPixels:Int, readOffset:Int, writeOffset:Int, ratio:Float)
	{
		var offset:Int = Std.int(MathEx.interpolate(ratio, 0, 1, -255, 255));

		while (totalPixels-- > 0)
		{
			//Log.trace('$writeOffset, $readOffset');
			colorDataData[writeOffset] = cast MathEx.clampInt(cast(maskDataData[readOffset], Int) + offset, 0, 255);
			readOffset += 4;
			writeOffset += 4;
		}
	}

	@:noStack static private function _mask(colorDataData:BytesData, maskDataData:BytesData, totalPixels:Int, readOffset:Int, writeOffset:Int, ratio:Float)
	{
		var thresold:Int = Std.int(MathEx.interpolate(ratio, 0, 1, 0, 255));

		while (totalPixels-- > 0)
		{
			colorDataData[writeOffset] = cast((cast(maskDataData[readOffset], Int) >= thresold) ? 0xFF : 0x00);
			readOffset += 4;
			writeOffset += 4;
		}
	}

	static public function applyBlendMaskWithOffset(color:BitmapData, mask:BitmapData, ratio:Float, reverse:Bool):Void
	{
		applyAlphaFunction(color, mask, ratio, _blend);
	}

	static public function applyNoBlendMaskWithOffset(color:BitmapData, mask:BitmapData, ratio:Float, reverse:Bool):Void
	{
		applyAlphaFunction(color, mask, ratio, _mask);
	}

	static public function applyAlphaFunction(color:BitmapData, mask:BitmapData, ratio:Float, callback:Dynamic):Void
	{
		if (color.width != mask.width || color.height != mask.height) throw(new Error("Invalid arguments"));

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

			callback(colorDataData, maskDataData, totalPixels, readOffset, writeOffset, ratio);

			color.setPixels(color.rect, colorData);
		}
		color.unlock();
	}
}