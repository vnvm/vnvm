package common;
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
	static public function slice(source:BitmapData, rect:Rectangle):BitmapData {
		var destination:BitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height));
		destination.copyPixels(source, rect, new Point(0, 0));
		return destination;
	}
	
	static public function combineColorMask(color:BitmapData, mask:BitmapData):BitmapData {
		var newBitmap:BitmapData = new BitmapData(color.width, color.height, true, 0x00000000);
		//newBitmap.copyPixels(color, color.rect, new Point(0, 0), mask, new Point(0, 0), false);
		newBitmap.copyPixels(color, color.rect, new Point(0, 0));
		newBitmap.copyChannel(mask, mask.rect, new Point(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
		return newBitmap;
	}

}