/*struct ANI
{
	struct FRAME
	{
		ubyte x8;
		ubyte y;
		ubyte time;
	}
	ubyte magic; // 01
	ubyte ani_count;
	ubyte[10] pad;
	ushort x;
	ushort y;
	ushort w8;
	ushort h;
	FRAME[36] frames;
}*/

class ANI_FRAME
{
	x = 0; y = 0;
	t = 0;

	constructor(s)
	{
		this.y = s.readn('b');
		this.x = s.readn('b') * 8;
		this.t = s.readn('b') * 16;
		printf("  FRAME(%d,%d)(%d)\n", this.x, this.y, t);
	}
}

class ANI
{
	magic = 1;
	x = 0; y = 0; w = 0; h = 0;
	frames = [];
	mrs = null;
	total_time = 0;
	
	function getImageFrame(n)
	{
		return this.mrs.image.slice(frames[n].x, frames[n].y, w, w);
	}

	function getIndexByTime(time)
	{
		local time = (time % total_time);
		local ctime = 0;
		foreach (n, frame in frames) {
			ctime += frame.t;
			if (time < ctime) {
				//printf("%d|%d\n", ctime, time);
				//printf("%d\n", n);
				return n;
			}
		}
		return 0;
	}

	constructor(mrs, s)
	{
		this.mrs = mrs;
		this.magic = s.readn('b');
		if (magic != 1) throw("Invalid frame");

		local count = s.readn('b');
		s.seek(0xC);
		this.x = ((s.readn('b') << 8) | s.readn('b'));
		this.y = ((s.readn('b') << 8) | s.readn('b'));
		this.w = ((s.readn('b') << 8) | s.readn('b')) * 8;
		this.h = ((s.readn('b') << 8) | s.readn('b'));
		this.frames = [];
		this.total_time = 0;
		printf("ANIMATION(%d,%d)-(%d,%d)\n", x, y, w, h);
		for (local n = 0; n < count; n++)
		{
			local frame = ANI_FRAME(s);
			frames.push(frame);
			this.total_time += frame.t;
		}
	}
}

class MRS
{
	file = null;
	file_size = 0;
	palette = null;
	image = null;
	header = null;
	anims = [];
	anim_info = [];
	
	constructor(file)
	{
		this.file = file;
		parse_header();
		parse_palette();
		parse_data();
	}
	
	function parse_header()
	{
		local magic = file.readstringz(4);
		switch (magic) {
			case "CD": // 16 colores
			case "DO": // 256 colores
			break;
			default: throw("Invalid MRS header.");
		}

		header = {
			width  = file.readn('w'),
			height = file.readn('w'),
		};
		
		file.seek(4, 'c');
	}
	
	function parse_palette()
	{
		palette = file.readslice(0x300);
	}
	
	function parse_data()
	{
		local cdata = file.readslice(file.len() - file.tell());
		//saveblob("out.bin", cdata);
		
		local clen = cdata.len();
		cdata.seek(-1, 'e');
		local ani_count = cdata.readn('c');
		
		// Not too many counts, possible animation.
		if ((ani_count > 0) && (ani_count < 10)) {
			cdata.seek(-1 - (ani_count * 0x80), 'e');
			for (local n = 0; n < ani_count; n++) {
				anims.push(ANI(this, cdata.readslice(0x80)));
			}
		}

		cdata.seek(0, 'b');
		local image_data = ::lz_decode(cdata, header.width * header.height, { special = "tlove" });
		image = ::Bitmap.fromData(
			image_data,
			{
				width       = header.width,
				height      = header.height,
				bpp         = 8,
				interleaved = 1,
				pal_data    = palette,
				pal_bpp     = 3,
				pal_bpp_use = 3,
				pal_swap    = [1, 2, 0], // GBR
				flip_x      = 0,
				flip_y      = 0,
			}
		);
	}
	
	function _get(name)
	{
		switch (name)
		{
			case "w": return header.width;
			case "h": return header.height;
		}
		throw("Can't find index '" + name + "'");
	}
	
	function draw(dst, x = 0, y = 0)
	{
		image.draw(dst, x, y);
	}
}