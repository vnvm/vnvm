package common.imaging;
import common.LangUtils;
import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class BitmapData8 {
	public var palette:Palette;
	public var data:ByteArray;
	public var width:Int;
	public var height:Int;
	
	private function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
	}
	
	static public function createNewWithSize(width:Int, height:Int):BitmapData8 {
		var bitmapData:BitmapData8 = new BitmapData8(width, height);
		bitmapData.palette = new Palette();
		bitmapData.data = new ByteArray();
		for (n in 0 ... width * height) bitmapData.data.writeByte(0);
		return bitmapData;
	}

	static public function createWithDataAndPalette(data:ByteArray, width:Int, height:Int, palette:Palette):BitmapData8 {
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
			var color:BmpColor = palette.colors[data.readByte()];
			ba.writeByte(color.a);
			ba.writeByte(color.r);
			ba.writeByte(color.g);
			ba.writeByte(color.b);
		}
		ba.position = 0;
		data.position = 0;
		bmp.setPixels(bmp.rect, ba);
	}
	
	public function getPixel(x:Int, y:Int):Int {
		return data[y * width + x];
	}

	public function setPixel(x:Int, y:Int, colorIndex:Int):Void {
		data[y * width + x] = colorIndex;
	}

	public function drawToBitmapData8(dst:BitmapData8, px:Int, py:Int):Void {
		copyRect(this, new Rectangle(0, 0, width, width), dst, new Point(px, py));
	}
	
	public function fillRect(color:Int, rect:Rectangle):Void {
		var rectX:Int = Std.int(rect.x);
		var rectY:Int = Std.int(rect.y);
		var rectW:Int = Std.int(rect.width);
		var rectH:Int = Std.int(rect.height);

		for (y in 0 ... rectH) {
			for (x in 0 ... rectW) {
				this.setPixel(rectX + x, rectY + y, color);
			}
		}
	}
	
	static public function copyRect(src:BitmapData8, srcRect:Rectangle, dst:BitmapData8, dstPoint:Point):Void {
		dst.palette = src.palette;
		
		var srcX:Int = Std.int(srcRect.x);
		var srcY:Int = Std.int(srcRect.y);
		var srcWidth:Int = Std.int(srcRect.width);
		var srcHeight:Int = Std.int(srcRect.height);
		
		var dstX:Int = Std.int(dstPoint.x);
		var dstY:Int = Std.int(dstPoint.y);

		for (y in 0 ... srcHeight) {
			for (x in 0 ... srcWidth) {
				dst.setPixel(dstX + x, dstY + y, src.getPixel(srcX + x, srcY + y));
			}
		}
	}
}