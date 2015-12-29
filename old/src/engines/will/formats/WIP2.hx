package engines.will.formats;

import engines.will.formats.wip.WipEntry;
import flash.geom.Rectangle;
import common.ByteArrayUtils;
import flash.utils.ByteArray;

class WIP2
{
	private var name:String;
	private var data:ByteArray;
	private var infos:Array<Int>;
	private var count = 0;
	private var bpp = 0;
	private var images = [];
	private var memory_size = 0;
	
	public function new(data: ByteArray, name: String)
	{
		if (data == null) throw("Invalid WIP");
		this.name = name;
		this.data = data;
		this.infos = [];
		this.images = [];
		readHeader(data);
		for (info in infos) readImage(info);
		this.memory_size = getMemorySize();
	}
	
	function export(folder)
	{
		foreach (n, image in images) {
			image.save(format("%s/%s.%d.png", folder, name, n), "png");
		}
	}
	
	function getMemorySize()
	{
		var memory_size = 0;
		for (image in images) memory_size += image.memory_size;
		return memory_size;
	}
	
	private function readHeader(data:ByteArray)
	{
		if (ByteArrayUtils.readStringz(data, 4) != "WIPF") throw("Not a WIP File.");
		count = data.readUnsignedShort();
		bpp   = data.readUnsignedShort();
		for (n in 0 ... count) infos.push(readHeaderImageEntry(data));
	}

	private function readHeaderImageEntry(data:ByteArray)
	{
		return new WipEntry().read(data);
	}
	
	function readImage(info:WipEntry)
	{
		var pal = null;
		// has palette
		if (bpp == 8) pal = data.readslice(4 * 0x100);
		
		//printf("SIZE: %d\n", info.w * info.h * bpp / 8);
		
		local decoded = ::lz_decode(
			data.readslice(info.csize), // Slice with the compressed data.
			(info.w * info.h * bpp / 8).tointeger(), // Max/exact size of the uncompressed data.
			{ // Decompression information.
				bufsize  = 0x1000, // Ringbuffer size.
				opsize   = 1,      // Size of the operation in bytes (1 byte)
				writepos = 1,      // Initial position for writting. (Position 1)
				init     = 0,      // Initial status of the buffer.
				comp_bit = 0,      // Bit 0/1 used for compressed.
				bit_count_add = 2,
				bits     = ["count", 4, "position", 12] // Disposition of the bits in a compressed block.
				//debug    = 1,
				debug    = 0,
			}
		);

		images.push(Bitmap.fromData(
			decoded,
			{
				width       = info.w,
				height      = info.h,
				bpp         = bpp,
				interleaved = 0,
				color_order = "argb",
				pal_data    = pal,
			}
		));
	}
	
	private function getRect(index = 0, x = 0, y = 0)
	{
		var info = infos[index];
		return new Rectangle(info.x + x, info.x + y, info.w, info.h)
	}
	
	function drawTo(destinationBitmap, index = 0, x = 0, y = 0, alpha = 1.0, size = 1.0, rotation = 0.0)
	{
		var info = infos[index];
		destinationBitmap.drawBitmap(images[index], info.x + x, info.y + y, alpha, size, rotation);
	}
	
	function len()
	{
		return images.len();
	}
	
	function pointInImage(index, point)
	{
		return pointInRect(point, this.infos[index]);
	}

	static public function WIP_MSK(wip_s, msk_s, name) {
		local translation_path = info.game_data_path + "/translation/" + ::info.game_lang + "/";
		local wip = WIP(wip_s, name);
		local msk = null;
		try {
		msk = WIP(msk_s, name);
		} catch (e) {
		}
		for (local n = 0; n < wip.images.len(); n++) {
		local slice_image_file = format("%s/%s.%d.png", translation_path, name, n);
//printf("FILE: '%s'\n", slice_image_file);
		if (file_exists(slice_image_file)) {
		wip.images[n] = Bitmap.fromFile(slice_image_file);
		} else {
		if (msk) wip.images[n].copyChannel(msk.images[n], "red", "alpha", 1);
		}
		}
		return wip;
	}

}