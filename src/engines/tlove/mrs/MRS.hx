package engines.tlove.mrs;

import common.ByteArrayUtils;
import common.imaging.BitmapData8;
import common.imaging.BmpColor;
import common.imaging.Palette;
import nme.errors.Error;
import nme.utils.ByteArray;
import nme.utils.Endian;

class MRS
{
	var animations:Array<ANI>;
	var palette:Palette;
	var file:ByteArray;
	private var bitsPerPixel:Int;
	private var width:Int;
	private var height:Int;
	public var image:BitmapData8;
	
	public function new(file:ByteArray) {
		this.file = file;
		this.palette = new Palette();

		parseHeader();
		parsePalette();
		parseData();
	}
	
	private function parseHeader() {
		var magic = ByteArrayUtils.readStringz(file, 4);
		
		this.bitsPerPixel = switch (magic) {
			case "CD": 4;
			case "DO": 8;
			default: throw(new Error("Invalid MRS header."));
		}

		this.width = file.readUnsignedShort();
		this.height = file.readUnsignedShort();
		
		file.position += 4;
	}
	
	function parsePalette() {
		for (n in 0 ... 0x100) {
			var b:Int = file.readByte();
			var r:Int = file.readByte();
			var g:Int = file.readByte();
			
			this.palette.colors[n] = new BmpColor(r, g, b, 0xFF);
		}
	}
	
	function parseData() {
		var compressedDataPosition:Int = file.position;
		
		file.position = file.length - 1;
		var aniCount:Int = file.readUnsignedByte();
		
		// Not too many counts, possible animation.
		if ((aniCount > 0) && (aniCount < 10)) {
			file.position = file.length - 1 - (aniCount * 0x80);
			for (n in 0 ... aniCount) {
				animations.push(new ANI(this, ByteArrayUtils.readByteArray(file, 0x80)));
			}
		}

		file.position = compressedDataPosition;
		
		var decoded:ByteArray = LZ.decode(file, width * height);
		
		this.image = BitmapData8.createWithDataAndPalette(decoded, width, height, palette);
		
	}
}