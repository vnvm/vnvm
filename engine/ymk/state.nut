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
	sprites_l1 = null;
	sprites_l2 = null;
	sprites_object = null;
	timer = 0;
	timer_max = 0;
	script_stack = null;
	background = null;
	background_color = null;
	music_name = null;
	mask = null;
	flags = null;

	constructor()
	{
		sprites_l1 = [null, null, null];
		sprites_l2 = [null, null, null];
		sprites_object = null;
		script_stack = [];
		background = "";
		background_color = null;
		flags = array(MAX_FLAGS, 0);
	}
	
	function flags_set_range(start, end, value = 0)
	{
		for (local n = start; n <= end; n++) flags[n] = value;
	}

	function flags_set_range_count(start, count, value = 0)
	{
		for (local n = start; n < start + count; n++) flags[n] = value;
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
	
	function save(stream)
	{
		//stream.write('i', 10);
	}
}
