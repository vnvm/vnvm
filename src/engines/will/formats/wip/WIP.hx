package engines.will.formats.wip;

import lang.promise.IPromise;
import sys.io.File;
import lang.MathEx;
import flash.display.BitmapDataChannel;
import flash.geom.Point;
import common.imaging.BitmapDataUtils;
import common.compression.LzOptions;
import common.imaging.BitmapDataSerializer;
import common.compression.LzDecoder;
import haxe.Log;
import common.ByteArrayUtils;
import flash.utils.ByteArray;
import vfs.Stream;

class WIP
{
	private var count:Int;
	private var bpp:Int;
	private var entries:Array<WipEntry>;
	public var length(get, null):Int;
	public var width(default, null):Int;
	public var height(default, null):Int;

	private function new()
	{
		count = 0;
		bpp = 0;
		entries = [];
	}

	private function readHeader(data:ByteArray)
	{
		if (ByteArrayUtils.readStringz(data, 4) != "WIPF") throw("Not a WIP File.");
		count = data.readUnsignedShort();
		bpp   = data.readUnsignedShort();
		width = 0;
		height = 0;
		for (n in 0 ... count)
		{
			var entry = new WipEntry().read(n, data);
			entries.push(entry);
			width = Std.int(Math.max(width, entry.x + entry.width));
			height = Std.int(Math.max(height, entry.y + entry.height));
		}
	}

	private function readImages(data:ByteArray)
	{
		for (entry in entries)
		{
			var palette:Array<Int> = new Array<Int>();
			if (bpp == 8) {
				for (n in 0 ... 0x100) {
					palette.push(data.readInt());
				}
			}
			var compressedData = ByteArrayUtils.readByteArray(data, entry.compressedSize);
			var uncompressedData = LzDecoder.decode(compressedData, new LzOptions(), Std.int(entry.width * entry.height * bpp / 8));
			switch (bpp) {
				case 24:
					entry.bitmapData = BitmapDataSerializer.decode(uncompressedData, entry.width, entry.height, "bgr", false);
				case 8:
					entry.bitmapData = BitmapDataSerializer.decode(uncompressedData, entry.width, entry.height, "r", false);
					BitmapDataUtils.applyPalette(entry.bitmapData, palette);
					//entry.bitmapData.paletteMap(entry.bitmapData, entry.bitmapData.rect, new Point(0, 0), palette, empty, empty, empty);
				default:
					throw('Not implemented bpp=$bpp');
			}
			//Log.trace(bpp);
		}
	}

	private function get_length():Int
	{
		return entries.length;
	}

	public function get(index:Int):WipEntry
	{
		return entries[index];
	}

	public function iterator():Iterator<WipEntry>
	{
		return entries.iterator();
	}

	public function mergeAlpha(alphaWip:WIP):Void
	{
		var colorWip = this;

		if (alphaWip != null)
		{
			for (n in 0 ... colorWip.length)
			{
				var colorEntry = colorWip.get(n);
				var alphaEntry = alphaWip.get(n);

				colorEntry.bitmapData.copyChannel(alphaEntry.bitmapData, alphaEntry.bitmapData.rect, new Point(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			}
		}
	}

	static public function fromByteArray(data:ByteArray):WIP
	{
		var wip = new WIP();
		wip.readHeader(data);
		wip.readImages(data);
		return wip;
	}

	static public function fromByteArrayWithMask(color:ByteArray, alpha:ByteArray = null):WIP
	{
		var colorWip = fromByteArray(color);
		if (alpha != null)
		{
			colorWip.mergeAlpha(fromByteArray(alpha));
		}

		return colorWip;
	}

	static public function fromStreamAsync(stream:Stream):IPromise<WIP>
	{
		return stream.readAllBytesAsync().then(function(data:ByteArray)
		{
			return fromByteArray(data);
		});
	}

	public function save(folder:String):Void
	{
		for (entry in entries)
		{
			File.saveBytes('$folder/${entry.index}.png', entry.bitmapData.encode('png'));
		}
	}
}