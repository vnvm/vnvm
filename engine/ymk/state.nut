class FLAGS
{

}

class ScriptReference
{
	name = "";
	pc   = 0;
	
	constructor(name, pc)
	{
		this.name = name;
		this.pc   = pc;
	}
}

class State
{
	// First 1000 (0-999) are temporal flags.
	// Next  2000 (1000-2999) are persistent flags.
	static MAX_FLAGS = 3000;
	rio = null;
	timer = 0;
	timer_max = 0;
	script_stack = null;
	background = null;
	background_color = null;
	music_name = null;
	mask = null;
	flags = null;

	constructor(rio)
	{
		this.rio = rio;
		script_stack = [];
		background = "";
		background_color = null;
		flags = array(MAX_FLAGS, 0);
	}
	
	function saveStream(stream)
	{
		// Store temporal flags.
		for (local n = 0; n < 1000; n++) {
			stream.writen(flags[n], 's');
		}

		// Store script stack.
		stream.writen(script_stack.len(), 's');
		foreach (script in script_stack) {
			stream.writen(script.pc, 'i');
			_writestringz(stream, script.name);
		}
		
		// Store texts.
		_writestringz(stream, rio.interface.text_title);
		_writestringz(stream, rio.interface.text_body);
		
		// Store music name.
		_writestringz(stream, music_name);

		// Store scene.
		this.rio.scene.saveStream(stream);
	}
	
	function loadStream(stream)
	{
		// Restore temporal flags.
		for (local n = 0; n < 1000; n++) flags[n] = stream.readn('s');
		
		// Restore script stack.
		script_stack = [];
		local script_stack_len = stream.readn('s');
		for (local n = 0; n < script_stack_len; n++) {
			local pc = stream.readn('i');
			local name = stream.readstringz(-1);
			script_stack.push(ScriptReference(name, pc));
		}
		
		// Restore texts.
		rio.interface.text_title = stream.readstringz(-1);
		rio.interface.text_body  = stream.readstringz(-1);

		// Store music name.
		music_name = stream.readstringz(-1);

		// Restore scene.
		this.rio.scene.loadStream(stream);
	}
	
	function save(index = 0)
	{
		printf("Saving...");
		{
			this.saveStream(file(format("save%03d", index), "wb"));
		}
		printf("Ok\n");
	}

	function load(index = 0)
	{
		printf("Loading...");
		{
			this.loadStream(file(format("save%03d", index), "rb"));
		}
		printf("Ok\n");

		// Jump to the lastest script position.
		this.rio.load(script_get().name, 0, script_get().pc);
	}

	function save_system()
	{
		printf("Saving system...");
		{
			local f = file("savesystem", "wb");
			for (local n = 1000; n < MAX_FLAGS; n++) {
				f.writen(flags[n], 's');
			}
		}
		printf("Ok\n");
	}
	
	function load_system()
	{
		printf("Loading system...");
		try {
			local f = file("savesystem", "rb");
			for (local n = 1000; n < MAX_FLAGS; n++) {
				flags[n] = f.readn('s');
			}
			printf("Ok\n");
		} catch (e) {
			printf("Didn't exist\n");
		}
	}
	
	function flag_set(index, value)
	{
		if (this.flags[index] != value) {
			this.flags[index] = value;
			if (index >= 1000) {
				save_system();
			}
		}
	}
	
	function flag_get(index)
	{
		return this.flags[index];
	}
	
	function flags_set_range(start, end, value = 0)
	{
		for (local n = start; n <= end; n++) flag_set(n, value);
	}

	function flags_set_range_count(start, count, value = 0)
	{
		flags_set_range(start, start + count - 1, value);
	}

	function script_push(script_reference)
	{
		script_stack.push(script_reference);
	}

	function script_set(script_reference)
	{
		script_stack[script_stack.len() - 1] = script_reference;
	}
	
	function script_get()
	{
		return script_stack[script_stack.len() - 1];
	}
	
	function script_pop()
	{
		script_stack.pop();
	}

	function script_set_pc(pc)
	{
		script_stack[script_stack.len() - 1].pc = pc;
	}
}
