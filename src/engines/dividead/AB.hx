package engines.dividead;

/*
class AB
{
	static ops = { };

	var script = null;
	var flags:Array = [];
	var options:Array = [];
	var map_options:Array = [];
	var running:Bool = true;
	var vfs = null;
	var name:String = null;
	var title:String = "";
	var throttle:Bool = false;
	
	public function new()
	{
		this.flags = [];
		for (n in 0 ... 1000) flags.push(0);
		this.script = null;
	}
		
	function parse_params(format)
	{
		local l = [];
		foreach (type in format) {
			switch (type) {
				case 'F': case '2': l.push(script.readn('w')); break;
				case 'T': case 'S': case 's': l.push(script.readstringz(-1)); break;
				case 'P': l.push(script.readn('i')); break;
				case 'c': l.push(script.readn('c')); break;
				default: throw(::format("Invalid format type '%c'", type)); break;
			}
		}
		return l;
	}
	
	function parse_op()
	{
		local op = script.readn('w');
		if (!(op in AB.ops)) throw(::format("Unknown OP 0x%02X", op));
		local cop = AB.ops[op];
		local params = parse_params(cop.format);
		//printf("Executing... %s\n", cop.name);
		if (cop.name in AB_OP) {
			params.insert(0, this);
			AB_OP[cop.name].acall(params);
		} else {
			printf("Not implemented AB_OP.'%s'\n", cop.name);
		}
	}
	
	function execute()
	{
		while (running && !script.eos())
		{
			parse_op();
		}
	}
	
	function getNameExt(name, ext) {
		return (split(name, ".")[0] + "." + ext).toupper();
	}
	
	function set_script(name)
	{
		this.script = vfs[this.name = getNameExt(name, "AB")];
	}

	function jump(pointer)
	{
		this.script.seek(pointer);
	}
	
	function end()
	{
		running = false;
	}
	
	function paint_to_color(color, time)
	{
		if (throttle) return;

		local steps = 60.0;
		
		local screen2 = ::screen.dup();
		
		for (local n = 0; n < steps; n++) {
			::screen.clear(color);
			screen2.draw(screen, 0, 0, 1.0 - (n.tofloat() / steps));
			Screen.flip();
			Screen.frame(60);
		}
		
		::screen.clear(color);
		Screen.flip();
		Screen.frame(60);
	}
	
	function paint(pos, type)
	{
		if (throttle) type = 0;
		
		local clips = [];
		
		local draw_row = function(clips, y) { clips.push([0, y, 640, 1]); };
		local draw_col = function(clips, x) { clips.push([x, 0, 1, 480]); };
		local flip = function(clips, fps) {
			Screen.flip(clips);
			Screen.frame(fps);
			clips.clear();
		}
		switch (type) {
			case 0:
				flip(clips, 10000);
			break;
			case 0:
			case 2:
				local block_size = 16;
				for (local n = 0; n < block_size; n++) {
					for (local x = 0; x < 640; x += block_size) draw_col(clips, x + n);
					flip(clips, 60);
				}
			break;
			case 3:
				for (local y = 0; y < 240; y++) {
					draw_row(clips, y * 2);
					draw_row(clips, 480 - y * 2 - 1);
					if (y % 8 == 0) flip(clips, 60);
				}
			break;
			case 1:
				flip(clips, 10000);
			break;
			default:
				printf("Unknown paint type %d\n", type);
				flip(clips, 10000);
			break;
		}
	}
	
	cache = {};
	
	function get_image(name)
	{
		name = getNameExt(name, "BMP");
		if (!(name in cache)) {
			cache[name] <- vfs.get_image(name);
		} else {
			//printf("cached!\n");
		}
		return cache[name];
	}
}

foreach (name, v in AB_OP) {
	local attr = AB_OP.getattributes(name);
	if ("id" in attr) {
		attr.name <- name;
		AB.ops[attr.id] <- attr;
	}
}
*/
