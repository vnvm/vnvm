package engines.will.formats.wip;

import common.compression.LzOptions;
import common.imaging.BitmapDataSerializer;
import common.compression.LzDecoder;
import haxe.Log;
import common.ByteArrayUtils;
import flash.utils.ByteArray;
import vfs.Stream;
import promhx.Promise;

class WIP
{
	private var count:Int;
	private var bpp:Int;
	private var entries:Array<WipEntry>;

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
		for (n in 0 ... count)
		{
			entries.push(new WipEntry().read(data));
		}
	}

	private function readImages(data:ByteArray)
	{
		for (entry in entries)
		{
			var compressedData = ByteArrayUtils.readByteArray(data, entry.compressedSize);
			var uncompressedData = LzDecoder.decode(compressedData, new LzOptions(), Std.int(entry.width * entry.height * bpp / 8));
			switch (bpp) {
				case 24:
					entry.bitmapData = BitmapDataSerializer.decode(uncompressedData, entry.width, entry.height, "bgr", false);
				default:
					throw('Not implemented $bpp');
			}
			//Log.trace(bpp);
		}
	}

	public function get(index:Int):WipEntry
	{
		return entries[index];
	}

	static public function fromStreamAsync(stream:Stream):Promise<WIP>
	{
		return stream.readAllBytesAsync().then(function(data:ByteArray)
		{
			var wip = new WIP();
			wip.readHeader(data);
			wip.readImages(data);
			return wip;
		});
	}
}