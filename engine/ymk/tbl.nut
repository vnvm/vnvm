/*
struct TBL {
	uint count;
	char file_name[9]; // MSK file with masks for each button
	uint enable_flags[0x100 - 1]; // 01-FF
	//ubyte keymap[0x12][0x10];
	ubyte keymap[0x12][0x10];
}
*/
class TBL
{
	// Struct data.
	count    = 0;
	msk_name = 0;
	enable_flags = null;
	keymap   = null;

	// Object info.
	mask     = null;
	position = null;
	using_mouse = false;

	constructor()
	{
		this.position = {x=-1, y=-1, kind=0};
		this.enable_flags = array(0x100, 0);
		this.keymap = [];
		this.using_mouse = false;
		for (local n = 0; n < 0x12; n++) this.keymap.push(array(0x10, 0));
	}
	
	function keymap_get(x, y)
	{
		if (x < 0 || y < 0 || x >= 0x10 || y >= 0x12) return 0;
		return keymap[y][x];
	}
	
	function keymap_goto_kind(kind)
	{
		for (local y = 0; y < 0x12; y++) {
			for (local x = 0; x < 0x10; x++) {
				if (keymap[y][x] == kind) {
					this.position = {
						x = x,
						y = y,
						kind = kind
					};
					//printf("keymap_goto_kind(%d) : {x=%d, y=%d}\n", kind, x, y);
					return;
				}
			}
		}
	}
	
	function tbl_enable(kind)
	{
		if (kind < 0) return 0;
		if (kind >= this.enable_flags.len()) return 0;
		return this.enable_flags[kind];
	}
	
	function keymap_move(mx = 0, my = 0)
	{
		local new_x = 0, new_y = 0;
		local found = false;
		
		//printf("---------------- (%d, %d)-(%d, %d)\n", tbl_x, tbl_y, mx, my);
		
		for (local cy = 1; cy < 0x12; cy++) {
			for (local cx = 0; cx < 0x12; cx++) {
				if (mx != 0) {
					new_x = this.position.x + mx * cy;
					if (keymap_get(new_x, new_y = this.position.y + cx)) if (tbl_enable(keymap_get(new_x, new_y))) { found = true; break; }
					if (keymap_get(new_x, new_y = this.position.y - cx)) if (tbl_enable(keymap_get(new_x, new_y))) { found = true; break; }
				}
				if (my != 0) {
					new_y = this.position.y + my * cy;
					//printf("%d - %d + %d * %d\n", new_y, tbl_y, my, cy);
					if (keymap_get(new_x = this.position.x + cx, new_y)) if (tbl_enable(keymap_get(new_x, new_y))) { found = true; break; }
					if (keymap_get(new_x = this.position.x - cx, new_y)) if (tbl_enable(keymap_get(new_x, new_y))) { found = true; break; }
				}
			}
			if (found) break;
		}

		if (found) {
			this.position = {
				x = new_x,
				y = new_y,
				kind = keymap_get(new_x, new_y)
			};
		}
	}
	
	function load(name)
	{
		//printf("Reading... '%s.TBL'\n", name);
		this.read(::arc[name + ".TBL"]);
	}

	function read(stream)
	{
		// Struct
		this.count    = stream.readn('i');
		this.msk_name = stream.readstringz(9);
		//printf("aaaaaaaaaaaaaaaaaaa: %d\n", this.enable_flags.len());
		for (local n = 1; n < 0x100; n++) {
			this.enable_flags[n] = stream.readn('i');
		}
		for (local y = 0; y < 0x12; y++)
		{
			for (local x = 0; x < 0x10; x++)
			{
				this.keymap[y][x] = stream.readn('b');
			}
		}
		
		// Local
		this.mask = ::resman.get_mask(this.msk_name);
		this.position = {x=-1, y=-1, kind=0};
	}

	function print()
	{
		printf("TBL:\n");
		printf("  msk_name : '%s'\n", this.msk_name);
		printf("  enable_flags\n");
		for (local n = 0; n < 0x100; n++) {
			if (this.enable_flags[n] != 0) printf("    %03d:%d\n", n, this.enable_flags[n]);
		}
	}
}