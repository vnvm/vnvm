package common;
import nme.display.BitmapData;
import nme.display.BitmapDataChannel;
import nme.geom.Point;

/**
 * ...
 * @author soywiz
 */

class BitmapDataUtils 
{
	static public function combineColorMask(color:BitmapData, mask:BitmapData):BitmapData {
		var newBitmap:BitmapData = new BitmapData(color.width, color.height, true, 0x00000000);
		//newBitmap.copyPixels(color, color.rect, new Point(0, 0), mask, new Point(0, 0), false);
		newBitmap.copyPixels(color, color.rect, new Point(0, 0));
		newBitmap.copyChannel(mask, mask.rect, new Point(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
		return newBitmap;
	}

}