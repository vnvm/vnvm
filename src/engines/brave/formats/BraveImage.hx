package engines.brave.formats;

import haxe.Log;
import common.Timer2;
import common.imaging.format.pixel.PixelFormat565;
import common.ByteUtils;
import haxe.io.Bytes;
import flash.display.BitmapData;
import flash.errors.Error;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Endian;

/**
 * ...
 * @author soywiz
 */

class BraveImage 
{
	/**
	 * 
	 */
	public var bitmapData:BitmapData;

	/**
	 * 
	 */
	public function new() 
	{
		
	}
	
	static private var decodeImageKey:Array<Int> = [
		0x84, 0x41, 0xDE, 0x48, 0x08, 0xCF, 0xCF, 0x6F, 0x62, 0x51, 0x64, 0xDF, 0x41, 0xDF, 0xE2, 0xE1
	];

	
	static private function decryptChunk(input:ByteArray, key:Bytes):ByteArray {
		var output:ByteArray = new ByteArray();
		output.endian = Endian.LITTLE_ENDIAN;
		
		for (n in 0 ... input.length) {
			output.writeByte(Decrypt.decryptPrimitive(input.readByte(), key.get(n % key.length)));
		}
		
		output.position = 0;
		return output;
	}

	@:noStack public function load(dataCompressed:ByteArray):Void
	{
		var elapsed = Timer2.measure(function() {
			_load(dataCompressed);
		});
		Log.trace('Decoded image ${dataCompressed.length} ... ${elapsed}s');
	}

	/**
	 * 
	 * @param	data
	 */
	@:noStack private function _load(dataCompressed:ByteArray):Void
	{
		var data:ByteArray = LZ.decode(dataCompressed);
		if (data.readUTFBytes(13) != "(C)CROWD ARPG") throw (new Error("Invalid file"));
		data.readByte();
		var key:ByteArray = new ByteArray();
		var header:ByteArray = new ByteArray();
		var dummy:ByteArray = new ByteArray();
		
		data.endian = Endian.LITTLE_ENDIAN;
		key.endian = Endian.LITTLE_ENDIAN;
		header.endian = Endian.LITTLE_ENDIAN;
		dummy.endian = Endian.LITTLE_ENDIAN;
		
		data.readBytes(key, 0, 8);
		data.readBytes(header, 0, 16);
		
		header = decryptChunk(header, ByteUtils.ArrayToBytes(decodeImageKey));
		header = decryptChunk(header, ByteUtils.ByteArrayToBytes(key));
		//for (n in 0 ... 0x10) header[n] = Decrypt.decryptPrimitive(header[n], decodeImageKey[n]);
		//for (n in 0 ... 0x10) header[n] = Decrypt.decryptPrimitive(header[n], key[n % 8]);
		
		var width:Int = header.readInt();
		var height:Int = header.readInt();
		var skip:Int = header.readInt();
		
		data.readBytes(dummy, 0, skip);
		
		this.bitmapData = new BitmapData(width, height);
		
		//data.position;
		
		var rgba:ByteArray = new ByteArray();
		//var n:Int = 0;
		//rgba.length = 4 * width * height;

		var pixelFormat = new PixelFormat565();
		
		for (y in 0 ... height) {
			for (x in 0 ... width) {
				var pixelData:Int = data.readUnsignedShort();
				var b:Int = pixelFormat.extractBlue(pixelData);
				var g:Int = pixelFormat.extractGreen(pixelData);
				var r:Int = pixelFormat.extractRed(pixelData);
				var a:Int = pixelFormat.extractAlpha(pixelData);
				if ((r == 0xFF) && (g == 0x00) && (b == 0xFF))
				{
					r = g = b = a = 0x00;
				}
				rgba.writeByte(a);
				rgba.writeByte(r);
				rgba.writeByte(g);
				rgba.writeByte(b);
			}
		}
		
		rgba.position = 0;
		
		this.bitmapData.setPixels(new Rectangle(0, 0, width, height), rgba);
	}
}