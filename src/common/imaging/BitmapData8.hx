package common.imaging;
import common.LangUtils;
import common.MathEx;
import haxe.io.Bytes;
import haxe.Log;
import nme.display.BitmapData;
import nme.errors.Error;
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

	@:noStack public function drawToBitmapData(bmp:BitmapData):Void {
		var ba:ByteArray = new ByteArray();
		ba.position = 0;
		data.position = 0;
		var colorsPalette:Array<Int> = [];
		for (n in 0 ... palette.colors.length) {
			var color:BmpColor = palette.colors[n];
			colorsPalette.push(
				(color.b <<  0) |
				(color.g <<  8) |
				(color.r << 16) |
				(color.a << 24)
			);
			
		}
		for (n in 0 ... width * height) ba.writeInt(colorsPalette[data.readUnsignedByte()]);
		ba.position = 0;
		data.position = 0;
		bmp.setPixels(bmp.rect, ba);
	}

	@:noStack public inline function getIndex(x:Int, y:Int):Int {
		return y * width + x;
	}

	@:noStack public function getPixel(x:Int, y:Int):Int {
		return data[getIndex(x, y)];
	}

	@:noStack public function setPixel(x:Int, y:Int, colorIndex:Int):Void {
		data[getIndex(x, y)] = colorIndex;
	}

	public function drawToBitmapData8(dst:BitmapData8, px:Int, py:Int):Void {
		copyRect(this, new Rectangle(0, 0, width, height), dst, new Point(px, py));
	}
	
	@:noStack public function fillRect(color:Int, rect:Rectangle):Void {
		var rectX:Int = Std.int(rect.x);
		var rectY:Int = Std.int(rect.y);
		var rectW:Int = Std.int(rect.width);
		var rectH:Int = Std.int(rect.height);

		for (y in 0 ... rectH) {
			var n:Int = getIndex(rectX + 0, rectY + y);
			for (x in 0 ... rectW) {
				data[n] = color;
				n++;
				//this.setPixel(, color);
			}
		}
	}
	
	public function inBounds(x:Int, y:Int):Bool {
		return (x >= 0 && y >= 0 && x < width && y < height);
	}
	
	@:noStack static public function copyRect(src:BitmapData8, srcRect:Rectangle, dst:BitmapData8, dstPoint:Point):Void {
		dst.palette = src.palette;
		
		var srcX:Int = Std.int(srcRect.x);
		var srcY:Int = Std.int(srcRect.y);
		var width:Int = Std.int(srcRect.width);
		var height:Int = Std.int(srcRect.height);
		
		var dstX:Int = Std.int(dstPoint.x);
		var dstY:Int = Std.int(dstPoint.y);
		
		var srcData:ByteArray = src.data;
		var dstData:ByteArray = dst.data;
		
		Log.trace(Std.format("SRC($srcX, $srcY), DST($dstX, $dstY) | SIZE($width, $height)"));
		
		if (!src.inBounds(srcX, srcY)) Log.trace("BitmapData8.copyRect.Error [1]");
		if (!src.inBounds(srcX + width - 1, srcY + height - 1)) Log.trace("BitmapData8.copyRect.Error [2]");
		if (!dst.inBounds(dstX, dstY)) Log.trace("BitmapData8.copyRect.Error [3]");
		if (!dst.inBounds(dstX + width - 1, dstY + height - 1)) Log.trace("BitmapData8.copyRect.Error [4]");
		
		width = Std.int(MathEx.clamp(width, 0, dst.width - dstX));
		width = Std.int(MathEx.clamp(width, 0, src.width - srcX));

		height = Std.int(MathEx.clamp(height, 0, dst.height - dstY));
		height = Std.int(MathEx.clamp(height, 0, src.height - srcY));

		//if (dstY + height >= dst.height) 

		for (y in 0 ... height) {
			/*
			src.data.position = src.getIndex(srcX + 0, srcY + y);
			dst.data.position = dst.getIndex(dstX + 0, dstY + y);
			dst.data.writeBytes(src.data, dst.data.position, srcWidth);
			*/
			
			var srcN:Int = src.getIndex(srcX + 0, srcY + y);
			var dstN:Int = dst.getIndex(dstX + 0, dstY + y);
			
			dstData.blit(dstN, srcData, srcN, width);
			//for (x in 0 ... srcWidth) dstData[dstN + x] = srcData[srcN + x];
		}
	}
}