include("tlove/dat_op.nut");

class DAT
{
	static ops = {};
	mouse = null;

	script_name = "";
	script = null;
	mouse_last_b = 0;
	box_state = {
		label_l = 0,
		label_r = 0,
		label_miss = 0,
		count_start = 0,
		count = 0
	};
	vfs = null;
	labels = [];
	flags = [];
	layers = [];
	call_stack = [];
	stream = null;
	font = null;
	log_ins = 0;
	current_ani = null;
	current_ani_info = {x = 0, y = 0, z = 0};
	current_ani_time = 0;
	current_ani_last_idx = -1;
	
	function mouse_update()
	{
		mouse = Screen.input().mouse;
		if (mouse_last_b != mouse.b) {
			mouse_last_b = mouse.b;
		} else {	
			mouse.b = 0;
		}
		mouse.bl <- (mouse.b.tointeger() & 1) != 0;
		mouse.br <- (mouse.b.tointeger() & 4) != 0;
	}

	function flag_set(flag_type, flag, value)
	{
		if ((flag_type < 0x00) || (flag_type > 0x03)) throw("Unknown flag type");
		return flags[flag_type][flag] = value;
	}
	
	function flag_get(flag_type, flag)
	{
		if ((flag_type < 0x00) || (flag_type > 0x03)) throw("Unknown flag type");
		return flags[flag_type][flag];
	}
	
	function get_value(v)
	{
		if ((v & 0xC000) == 0xC000) return rand() % (v & 0x3FFF);
		if (v & 0x8000) return flag_get(2, v & 0x7FFF);
		return v;
	}
	
	function next_frame(time)
	{
		if (current_ani == null) return;
		local idx = current_ani.getIndexByTime(current_ani_time);
		current_ani_time += time;
		if (current_ani_last_idx != idx) {
			local i = current_ani.getImageFrame(idx);
			local x = current_ani_info.x + current_ani.x;
			local y = current_ani_info.y + current_ani.y;
			i.draw(::screen, x, y);
			Screen.flip([[x, y, i.w, i.h]]);
		}
	}

	constructor()
	{
		call_stack = [];
		flags = [];
		for (local m = 0; m < 4; m++) {
			flags.push([]);
			for (local n = 0; n < 0x100; n++) flags[m].push(0);
		}
		layers = [::screen]; for (local n = 0; n < 6; n++) {
			local layer = Bitmap(::screen.w, ::screen.h);
			//layer.clear([1, 1, 1, 1]);
			layers.push(layer);
		}
		font = Font("lucon.ttf", 14, 0);
	}

	function parse_params(params, format)
	{
		local l = [];
		foreach (type in format) {
			switch (type) {
				case '1': try { l.push(params.readn('b')); } catch (e) { } break;
				case '2': try { l.push(params.readn('b') << 8 | params.readn('b')); } catch (e) { } break;
				case 's': l.push(params.readstringz(-1)); break;
				case '?': l.push(params); break;
				default: throw(::format("Invalid format type '%c'", type)); break;
			}
		}
		return l;
	}
	
	function jump(to)
	{
		if (log_ins) printf("Jump to pos(%08X)\n", to);
		script.seek(to);
		return;
	}
	
	function jump_label(label)
	{
		script.seek(labels[label]);
		if (log_ins) printf("Jump to label(%d) pos(%08X)\n", label, script.tell());
	}

	function set_script(name)
	{
		printf("SCRIPT: '%s'\n", name);
		if (script_name != name) {
			stream = ::pak_dat[script_name = name];
			local script_start = (stream.readn('b') << 8 | stream.readn('b'));
			local stream_ptr = stream.readslice(script_start - 2);
			labels = [];
			//labels.push(0);
			while (!stream_ptr.eos()) labels.push(stream_ptr.readn('b') << 8 | stream_ptr.readn('b'));
			stream.seek(script_start);
			script = stream.readslice(stream.len() - stream.tell());
		}
		jump(0);
	}
	
	function execute_single()
	{
		local op  = script.readn('b');
		local len = script.readn('b');
		if (len & 0x80) len = script.readn('b') | ((len & 0x7F) << 8);
		local params = script.readslice(len);
	
		if ((op in DAT.ops)) {
			local cop = DAT.ops[op];
			//printf("OP:%08X: %02X (%d) - %s\n", script.tell(), op, len, cop.name);
			local vpar = parse_params(params, cop.format);
			if (cop.name in DATOP) {
				vpar.insert(0, this);
				try {
					DATOP[cop.name].acall(vpar);
				} catch (e) {
					printf("ERROR(%02X:%s):%d: %s\n", op, cop.name, script.tell(), e);
					throw(e);
				}
			} else {
				printf("Not implemented DATOP.'%s'\n", cop.name);
			}
		} else {
			printf("Not implemented OP(%02X) - %d\n", op, len);
		}
	}
	
	function execute(label = 0)
	{
		while (!script.eos())
		{
			execute_single();
		}
	}
}

foreach (name, v in DATOP) {
	local attr = DATOP.getattributes(name);
	if ("id" in attr) {
		attr.name <- name;
		DAT.ops[attr.id] <- attr;
	}
}
