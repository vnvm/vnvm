package common.imaging;
import common.ByteArrayUtils;
import common.LangUtils;
import common.MathEx;
import haxe.io.Bytes;
import haxe.Log;
import nme.display.BitmapData;
import nme.errors.Error;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.Memory;
import nme.utils.ByteArray;
import nme.utils.Endian;

/**
 * ...
 * @author soywiz
 */

class BitmapData8 {
	public var palette:Palette;
	public var data:ByteArray;
	public var width:Int;
	public var height:Int;
	public var rect(default, null) : Rectangle;

	static private var __randomData:Array<Float>;

	private function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
		this.rect = new Rectangle(0, 0, width, height);
	}
	
	static public function createNewWithSize(width:Int, height:Int):BitmapData8 {
		var bitmapData:BitmapData8 = new BitmapData8(width, height);
		bitmapData.palette = new Palette();
		bitmapData.data = ByteArrayUtils.newByteArrayWithLength(width * height, Endian.LITTLE_ENDIAN);
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
		drawToBitmapData(bmp, bmp.rect);
		return bmp;
	}

	@:noStack public function drawToBitmapData(bmp:BitmapData, rect:Rectangle):Void {
		var rectX:Int = Std.int(rect.x);
		var rectY:Int = Std.int(rect.y);
		var rectW:Int = Std.int(rect.width);
		var rectH:Int = Std.int(rect.height);
		var ba:ByteArray = ByteArrayUtils.newByteArrayWithLength(Std.int(rectW * rectH * 4), Endian.LITTLE_ENDIAN);
		ba.position = 0;
		data.position = 0;
		var colorsPalette:Array<Int> = [];
		
		for (n in 0 ... palette.colors.length) {
			var color:BmpColor = palette.colors[n];
			colorsPalette.push(
				(color.b << 24) |
				(color.g << 16) |
				(color.r <<  8) |
				(color.a <<  0)
			);
		}
		
		Memory.select(ba);
		
		var dstPos:Int;
		var srcPos:Int;
		for (y in 0 ... rectH) {
			dstPos = y * rectW * 4;
			srcPos = getIndex(rectX + 0, rectY + y);
			
			//Log.trace(Std.format("($srcPos, $dstPos) :: ($rectX, $rectY, $rectW, $rectH)"));
		
			for (x in 0 ... rectW) {
				Memory.setI32(dstPos, colorsPalette[data[srcPos]]);
				dstPos += 4;
				srcPos += 1;
			}
		}
		ba.position = 0;
		data.position = 0;
		bmp.setPixels(rect, ba);
		
		ByteArrayUtils.freeByteArray(ba);
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

		var color1:Int = color & 0xFF;
		var color2:Int = (color1 << 0) | (color1 << 8);
		var color4:Int = (color2 << 0) | (color2 << 16);
		var rectDiv4:Int = Std.int(rectW / 4);
		var rectMod4:Int = rectW % 4;

		Memory.select(data);
		for (y in 0 ... rectH) {
			var n:Int = getIndex(rectX + 0, rectY + y);
			for (x in 0 ... rectDiv4) { Memory.setI32(n, color4); n += 4; }
			for (x in 0 ... rectMod4) { Memory.setByte(n, color1); n++; }
		}
	}
	
	public function inBounds(x:Int, y:Int):Bool {
		return (x >= 0 && y >= 0 && x < width && y < height);
	}
	
	@:noStack static public function copyRect(src:BitmapData8, srcRect:Rectangle, dst:BitmapData8, dstPoint:Point):Void {
		copyRectTransition(src, srcRect, dst, dstPoint, 1.0, 0);
	}
	
	static private function getMask(x:Int, y:Int, n:Int, effect:Int, step:Float):Bool {
		return true;
	}

	@:noStack static private function getRandomData():Array<Float> {
		if (__randomData == null) {
			__randomData = [];
			for (n in 0 ... 1000) __randomData.push(Math.random());
		}
		return __randomData;
	}

	@:noStack static private function getMaskRandomPixels(mask:ByteArray, random:Array<Float>, w:Int, h:Int, step:Float):Void {
		var n = 0; for (x in 0 ... w) for (y in 0 ... h) { mask.writeByte((step >= random[n % random.length]) ? 1 : 0); n++; }
	}

	@:noStack static private function getMaskRandomRows(mask:ByteArray, random:Array<Float>, w:Int, h:Int, step:Float):Void {
		var n = 0; for (x in 0 ... w) for (y in 0 ... h) { mask.writeByte((step >= random[y % random.length]) ? 1 : 0); n++; }
	}

	@:noStack static private function getMaskRandomColumns(mask:ByteArray, random:Array<Float>, w:Int, h:Int, step:Float):Void {
		var n = 0; for (x in 0 ... w) for (y in 0 ... h) { mask.writeByte((step >= random[x % random.length]) ? 1 : 0); n++; }
	}

	@:noStack static public function copyRectTransition(src:BitmapData8, srcRect:Rectangle, dst:BitmapData8, dstPoint:Point, step:Float, effect:Int, transparentColor:Int = -1):Void {
		dst.palette = src.palette;
		
		var srcX:Int = Std.int(srcRect.x);
		var srcY:Int = Std.int(srcRect.y);
		var width:Int = Std.int(srcRect.width);
		var height:Int = Std.int(srcRect.height);
		
		var dstX:Int = Std.int(dstPoint.x);
		var dstY:Int = Std.int(dstPoint.y);
		
		var srcData:ByteArray = src.data;
		var dstData:ByteArray = dst.data;
		
		//Log.trace(Std.format("SRC($srcX, $srcY), DST($dstX, $dstY) | SIZE($width, $height)"));
		
		if (!src.inBounds(srcX, srcY)) Log.trace("BitmapData8.copyRect.Error [1]");
		if (!src.inBounds(srcX + width - 1, srcY + height - 1)) Log.trace("BitmapData8.copyRect.Error [2]");
		if (!dst.inBounds(dstX, dstY)) Log.trace("BitmapData8.copyRect.Error [3]");
		if (!dst.inBounds(dstX + width - 1, dstY + height - 1)) Log.trace("BitmapData8.copyRect.Error [4]");
		
		width = Std.int(MathEx.clamp(width, 0, dst.width - dstX));
		width = Std.int(MathEx.clamp(width, 0, src.width - srcX));

		height = Std.int(MathEx.clamp(height, 0, dst.height - dstY));
		height = Std.int(MathEx.clamp(height, 0, src.height - srcY));

		step = MathEx.clamp(step, 0, 1);
		
		if ((step >= 1) || (effect == 0)) {
			for (y in 0 ... height) {
				var srcN:Int = src.getIndex(srcX + 0, srcY + y);
				var dstN:Int = dst.getIndex(dstX + 0, dstY + y);
				
				for (x in 0 ... width) {
					var c:Int = srcData[srcN];
					if (c != transparentColor) {
						dstData[dstN] = c;
					}
					dstN++;
					srcN++;
				}
				//dstData.blit(dstN, srcData, srcN, width);
			}
		} else {
			var checker:Int -> Int -> Int -> Int -> Float -> Bool;
			var mask:ByteArray = new ByteArray();
			var random:Array<Float> = getRandomData();
			
			getMaskRandomPixels(mask, random, width, height, step);
			
			var n:Int = 0;
			for (y in 0 ... height) {
				var srcN:Int = src.getIndex(srcX + 0, srcY + y);
				var dstN:Int = dst.getIndex(dstX + 0, dstY + y);
				
				for (x in 0 ... width) {
					if (mask[n] != 0) {
						var c:Int = srcData[srcN];
						if (c != transparentColor) {
							dstData[dstN] = c;
						}
					}
					
					dstN++;
					srcN++;
					n++;
				}
			}
		}
	}
}