class DGP
{
	file = null;
	header = null;
	image = null;
	
	constructor(file)
	{
		this.file = file;
		parse_header();
		parse_data();
	}
	
	function parse_header()
	{
		this.header = {
			magic   = file.readstringz(4), // " DPG"
			version = file.readn('i'),
			_unk    = file.readn('i'),
			width   = file.readn('i'),
			height  = file.readn('i'),
			bpp     = file.readn('i'),
		};
		if (header.magic   != " DPG") throw("Not a GPD file");
		if (header.version != 1     ) throw("Unknown version of the GPD (" + header.version + ") and only supported 1.");
	}
	
	function _get(name)
	{
		switch (name)
		{
			case "w": return header.width;
			case "h": return header.height;
			default: throw("Can't find index '" + name + "'");
		}
	}
	
	function parse_data()
	{
		local palette;
		file.seek(0x40);
		if (header.bpp == 8) palette = file.readslice(0x400);
		//local data = file.readblob(file.len() - file.tell());
		local data = file.readslice(file.len() - file.tell());
		local image_data = ::LZ.decode(data);
		//::saveblob("test.unc", image);
		image = ::Bitmap.fromData(
			image_data,
			{
				width       = header.width,
				height      = header.height,
				bpp         = header.bpp,
				interleaved = 1,
				pal_data    = palette,
				pal_bpp     = 4,
				pal_bpp_use = 4,
				pal_swap    = [0, 1, 2, 3],
				flip_x      = 0,
				flip_y      = 0,
			}
		);
	}
	
	function draw(x = 0, y = 0, buf = null)
	{
		::draw(this.image, buf, x, y);
	}
}