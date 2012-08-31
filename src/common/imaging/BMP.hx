package common.imaging;
import haxe.Log;
import nme.display.BitmapData;
import nme.errors.Error;
import nme.geom.ColorTransform;
import nme.geom.Rectangle;
import nme.utils.ByteArray;
import nme.utils.Endian;

/**
 * ...
 * @author soywiz
 */

private typedef BmpColor = { r:Int, g:Int, b:Int, reserved:Int };

class BMP 
{
	static public function decode(bytes:ByteArray):BitmapData {
		bytes.endian = Endian.LITTLE_ENDIAN;
		
		// BITMAPFILEHEADER
		var magic:String = bytes.readUTFBytes(2);
		var bmpSize:Int = bytes.readUnsignedInt();
		var reserved1:Int = bytes.readUnsignedShort();
		var reserved2:Int = bytes.readUnsignedShort();
		var dataOffset:Int = bytes.readUnsignedInt();
		if (magic != "BM") throw(new Error(Std.format("Not a BMP")));
		
		// BITMAPINFOHEADER
		var biSize:Int = bytes.readUnsignedInt();
		if (biSize != 40) throw(new Error(Std.format("Invalid BITMAPINFOHEADER $biSize")));
		var biData:ByteArray = new ByteArray();
		bytes.readBytes(biData, 0, biSize - 4);
		biData.endian = Endian.LITTLE_ENDIAN;
		biData.position = 0;
		var width:Int = biData.readUnsignedInt();
		var height:Int = biData.readUnsignedInt();
		var planes:Int = biData.readUnsignedShort();
		var bitCount:Int = biData.readUnsignedShort();
		var compression:Int = biData.readUnsignedInt();
		if (compression != 0) throw(new Error(Std.format("Not supported compression $compression")));
		var sizeImage:Int = biData.readUnsignedInt();
		var pixelsPerMeterX:Int = biData.readUnsignedInt();
		var pixelsPerMeterY:Int = biData.readUnsignedInt();
		var colorsUsed:Int = biData.readUnsignedInt();
		var colorImportant:Int = biData.readUnsignedInt();
		
		var palette:Array<BmpColor> = new Array<BmpColor>();
		
		// RGBQUAD - Palette
		for (n in 0 ... colorsUsed) {
			var r:Int = bytes.readUnsignedByte();
			var g:Int = bytes.readUnsignedByte();
			var b:Int = bytes.readUnsignedByte();
			var reserved:Int = bytes.readUnsignedByte();
			palette.push({ r : r, g : g, b : b, reserved : reserved });
		}
		
		// LINES
		var calculatedSizeImage:Int = width * height * planes * Std.int(bitCount / 8);
		//if (calculatedSizeImage != sizeImage) throw(new Error("Invalid sizeImage"));
		//var pixelData:ByteArray = bytes.readBytes(pixelSize);
		
		bytes.position = dataOffset;
		var bitmapData:BitmapData = new BitmapData(width, height);
		
		switch (bitCount) {
			case 8: decodeRows8(bytes, bitmapData, palette);
			case 24: decodeRows24(bytes, bitmapData);
			default: throw(new Error(Std.format("Not implemented bitCount=$bitCount")));
		}
		
		return bitmapData;
	}

	@:nostack static private function decodeRows8(bytes:ByteArray, bitmapData:BitmapData, palette:Array<BmpColor>):Void {
		var width:Int = bitmapData.width, height:Int = bitmapData.height;
		
		for (y in 0 ... height) {
			var bmpData:ByteArray = new ByteArray();
			bmpData.position = 0;
			for (x in 0 ... width) {
				var index:Int = bytes.readByte();
				var color:BmpColor = palette[index];
				bmpData.writeByte(0xFF);
				bmpData.writeByte(color.b);
				bmpData.writeByte(color.g);
				bmpData.writeByte(color.r);
			}
			bitmapData.setPixels(new Rectangle(0, height - y - 1, width, 1), bmpData);
		}
	}
	
	@:nostack static private function decodeRows24(bytes:ByteArray, bitmapData:BitmapData):Void {
		var width:Int = bitmapData.width, height:Int = bitmapData.height;

		for (y in 0 ... height) {
			var bmpData:ByteArray = new ByteArray();
			bmpData.position = 0;
			for (x in 0 ... width) {
				var r:Int = bytes.readByte();
				var g:Int = bytes.readByte();
				var b:Int = bytes.readByte();
				var a:Int = 0xFF;
				bmpData.writeByte(a);
				bmpData.writeByte(b);
				bmpData.writeByte(g);
				bmpData.writeByte(r);
			}
			bitmapData.setPixels(new Rectangle(0, height - y - 1, width, 1), bmpData);
		}
	}
}