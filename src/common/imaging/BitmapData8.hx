package common.imaging;
import common.LangUtils;
import nme.display.BitmapData;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class BitmapData8 {
	public var palette:Array<BmpColor>;
	public var data:ByteArray;
	public var width:Int;
	public var height:Int;
	
	private function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
	}
	
	static public function createNewWithSize(width:Int, height:Int):BitmapData8 {
		var bitmapData:BitmapData8 = new BitmapData8(width, height);
		bitmapData.palette = LangUtils.createArray(function():BmpColor { return { r : 0, g : 0, b : 0, a : 0 }; }, 256);
		bitmapData.data = new ByteArray();
		for (n in 0 ... width * height) bitmapData.data.writeByte(0);
		return bitmapData;
	}

	static public function createWithDataAndPalette(data:ByteArray, width:Int, height:Int, palette:Array<BmpColor>):BitmapData8 {
		var bitmapData:BitmapData8 = new BitmapData8(width, height);
		bitmapData.data = data;
		bitmapData.palette = palette;
		return bitmapData;
	}
	
	public function getBimapData32():BitmapData {
		var bmp:BitmapData = new BitmapData(width, height);
		drawToBitmapData(bmp);
		return bmp;
	}

	public function drawToBitmapData(bmp:BitmapData):Void {
		var ba:ByteArray = new ByteArray();
		ba.position = 0;
		data.position = 0;
		for (n in 0 ... width * height) {
			var color:BmpColor = palette[data.readByte()];
			ba.writeByte(color.a);
			ba.writeByte(color.r);
			ba.writeByte(color.g);
			ba.writeByte(color.b);
		}
		ba.position = 0;
		data.position = 0;
		bmp.setPixels(bmp.rect, ba);
	}
}