class WIP
{
	name = "";
	data = null;
	infos = null;
	count = 0;
	bpp = 0;
	images = null;
	memory_size = 0;
	
	constructor(data, name)
	{
		if (data == null) throw("Invalid WIP");
		this.name = name;
		this.data = data;
		this.infos = [];
		this.images = [];
		parse_header();
		foreach (info in infos) parse_image(info);
		this.memory_size = get_memory_size();
	}
	
	function export(folder)
	{
		foreach (n, image in images) {
			image.save(format("%s/%s.%d.png", folder, name, n), "png");
		}
	}
	
	function get_memory_size()
	{
		local memory_size = 0;
		foreach (image in images) memory_size += image.memory_size;
		return memory_size;
	}
	
	function parse_header()
	{
		if (data.readstringz(4) != "WIPF") throw("Not a WIP File.");
		count = data.readn('w');
		bpp   = data.readn('w');
		for (local n = 0; n < count; n++) infos.push(parse_entry());
	}

	function parse_entry()
	{
		return {
			w     = data.readn('i'),
			h     = data.readn('i'),
			x     = data.readn('i'),
			y     = data.readn('i'),
			unk   = data.readn('i'),
			csize = data.readn('i'),
		};
	}
	
	function parse_image(info)
	{
		local pal = null;
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
	
	function drawTo(destinationBitmap, index = 0, x = 0, y = 0, alpha = 1.0, size = 1.0, rotation = 0.0)
	{
		local info = infos[index];
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
}

function WIP_MSK(wip_s, msk_s, name) {
	local translation_path = info.game_data_path + "/translation/es/";
	// + name + ".png";
	local wip = WIP(wip_s, name);
	//info.game_data_path + "/translation/es/" + name.toupper() + ".nut"
	try {
		local msk = WIP(msk_s, name);
		for (local n = 0; n < wip.images.len(); n++) {
			local slice_image = format("%s/%s.%d.png", translation_path, name, n);
			if (file_exists(slice_image)) {
				wip.images[n] = Bitmap.fromFile(slice_image);
			} else {
				wip.images[n].copyChannel(msk.images[n], "red", "alpha", 1);
			}
		}
	} catch (e) {
	}
	return wip;
}
