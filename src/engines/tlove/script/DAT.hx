package engines.tlove.script;

class DAT
{
	public function new()
	{
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
