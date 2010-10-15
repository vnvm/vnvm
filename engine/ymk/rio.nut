class RIO extends Component
{
	static opcodes = {};
	name    = null;
	data    = null;
	state   = null;
	fps     = 40;
	sound   = null;
	todo    = 0;
	running = true;
	music   = null;
	music_stream = null;
	voice_channel = 6;
	draw_interface = 0;
	last_title = "";
	last_text = "";

	scene   = null;
	interface = null;
	
	constructor()
	{
		this.running = true;

		this.state = State();
		this.addChildComponent(this.scene     = Scene(this.state));
		this.addChildComponent(this.interface = Interface());
	}
	
	function gameStep(can_skip = false, updateCallback = null)
	{
		local ended = false;
		::input.update();
		if (can_skip && skipping()) ended = ended || true;
		this.update((1000 / this.fps).tointeger());
		ended = ended || this.ended();
		if (updateCallback != null) updateCallback.call(this);
		this.drawTo(screen);
		Screen.flip();
		Screen.frame(this.fps);
		return ended;
	}
	
	function loopUntilAnimationEnds(can_skip = false, updateCallback = null)
	{
		local ended = false;
		do {
			ended = gameStep(can_skip, updateCallback);
		} while (!ended);
		this.scene.copyDrawLayerToShowLayer();
	}

	function exit()
	{
		running = false;
	}
	
	function load(name, call = 1, position = 0)
	{
		translation.reset();
		local translation_script = "../game_data/ymk/translation/" + name.toupper() + ".nut";
		if (file_exists(translation_script)) {
			printf("Loaded translation: '%s'\n", translation_script);
			include(translation_script);
		}

		//printf("-----------------------------------------------\n");
		printf("@@@ RIO.load('%s', %d, %d)\n", name, call, position);
		//printf("-----------------------------------------------\n");
		if (name != this.name) {
			this.name = name;
			local stream = arc[name + ".WSC"];
			this.data = stream.readblob(stream.len());
			data.rot1(2);
		}
		data.seek(position);
		if (call) {
			this.state.script_push(ScriptReference(name, data.tell()));
		} else {
			this.state.script_set(ScriptReference(name, data.tell()));
		}
		
		return this;
	}
	
	function script_return()
	{
		this.state.script_pop();
		local script_reference = this.state.script_get();
		this.load(script_reference.name, 0, script_reference.pc);
	}

	/**
	 * Jumps to a relative position using the possition
	 * just after the current instruction as base.
	 *
	 * @param  int  relative_position  - Relative position to jump to.
	 */
	function jump_relative(relative_position)
	{
		jump_absolute(data.tell() + relative_position);
	}
	
	/**
	 * Jumps to an absolute position in the current script.
	 *
	 * @param  int  absolute_position  - Position to jump to.
	 */
	function jump_absolute(absolute_position)
	{
		data.seek(absolute_position);
		this.state.script_set_pc(data.tell());
	}
	
	function pressedNext()
	{
		return ::input.mouse.clicked(0) || ::input.pad_pressed("accept");
	}
	
	function skipping()
	{
		return ::input.pad_pressing("skip");
	}
	
	/**
	 * Performs a frame tick.
	 *   -------------- Updates timer.
	 *   - Swaps the frame buffer. 
	 *   - Waits 1000/fps ms (since last frame)
	 */
	function frame_tick()
	{
		//if (this.state.timer >= 0) this.state.timer--;
		Screen.flip();
		Screen.frame(this.fps);
	}

	/**
	 * Displays a message for an opcode/function currently not implemented.
	 */
	function TODO()
	{
		todo = 1;
	}
	
	function save(name)
	{
		printf("Saving '%s' (%d)...\n", name, this.data.len());
		this.data.seek(0);
		local file = ::file(name, "wb");
		file.writeblob(this.data.readblob(this.data.len()));
		//file.close();
		this.data.seek(0);
	}
	
	function process_text(text)
	{
		//return text.replace("\\n", "\n");
		return replace(text, "\\n", "\n");
		//return text;
	}
	
	function process_params(sparams)
	{
		local last_kind = 0;
		local l = [];
		local loop_to = 0;
		local loop = 0;
		local variadic = false;
		/*
			'l' processor dependent, 32bits on 32bits processors, 64bits on 64bits prcessors returns an integer 
			'i' 32bits number returns an integer 
			's' 16bits signed integer returns an integer 
			'w' 16bits unsigned integer returns an integer 
			'c' 8bits signed integer returns an integer 
			'b' 8bits unsigned integer returns an integer 
			'f' 32bits float returns an float 
			'd' 64bits float returns an float 
		*/
		for (local n = 0; n < sparams.len(); n++) {
			local c = sparams[n];
			switch (c) {
				case '*': return [];
				case '.':
					local value = data.readn('b');
					if (value != 0) {
						printf("WARNING: ignored parameter has a value different than zero!\n");
					}
				break;
				case '1': l.push(data.readn('b')); break;
				case '2': l.push(data.readn('s')); break;
				case '4': l.push(data.readn('i')); break;
				case 't': l.push(process_text(data.readstringz(-1)));  break;
				case 's': l.push(data.readstringz(-1));  break;
				case 'l': l.push(data.readn('i')); break;
				case 'L': l.push(data.readn('i')); break;
				case 'o': l.push(data.readn('b')); break; // SET_OP
				case 'O': l.push(data.readn('b')); last_kind = (l[l.len() - 1] >> 4); break; // JUMP_IF_OP
				case 'f': l.push(data.readn('w')); break;
				case 'k': l.push(data.readn('b')); last_kind = l[l.len() - 1]; break;
				case 'C':
					loop = data.readn('w');
					l.push(loop);
				break;
				case '[':
					loop_to = n;
					variadic = true;
				break;
				case ']':
					if (--loop > 0) n = loop_to;
				break;
				case 'F':
					if (last_kind) {
						l.push(data.readn('w'));
					} else {
						l.push(data.readn('w'));
					}
				break;
				default:
					printf("Unprocessed format: '%c'\n", c);
					return;
				break;
			}
		}
		return l;
	}
	
	function execute()
	{
		while (!data.eos() && this.running) {
			execute1();
		}
	}
	
	function execute1()
	{
		local start_pos = data.tell();
		local op = data.readn('b');
		local name = "?", params_format = "", vparams = [], variadic = false;
		try {
			local cop = RIO.opcodes[op];
			name = cop.name;
			params_format = cop.params_format;
			vparams = process_params(params_format);
			if (name.len() == 0) name = ::format("OP_%02X", op);
			
			this.state.script_set_pc(data.tell());
			
			if (name in cop.__class) {
				vparams.insert(0, this);
				todo = 0;
				//printf("---%s\n" name);
				
				//printf("%s@%04X: OP(0x%02X) : %s : %s\n", this.name, start_pos, op, name, ::object_to_string(vparams.slice(1)));
				
				local retval;
				//printf("Variadic: %d\n", cop.variadic);
				if (cop.variadic) {
					retval = cop.__class[name].call(this, vparams);
				} else {
					retval = cop.__class[name].acall(vparams);
				}
				if (todo) {
					printf("%s@%04X: OP(0x%02X) : %s : %s...", this.name, start_pos, op, name, ::object_to_string(vparams.slice(1)));
					printf("  @TODO\n");
					//print(retval);
					//printf("\n");
				}
			} else {
				printf("Unprocessed OP(0x%02X) : %s\n", op, name);
			}
		} catch (e) {
			printf("%s@%04X: Error with OP(0x%02X):'%s':'%s':'%s' : '%s'\n", this.name, start_pos, op, name, params_format, ::object_to_string(vparams), e);
			throw(e);
		}
	}
	
	static function opcode_clean()
	{
		RIO.opcodes <- {};
	}

	static function opcode_info(__class, id, name, params_format, variadic)
	{
		RIO.opcodes[id] <- {
			__class = __class,
			name = name,
			params_format = params_format,
			variadic = variadic,
		};
	}

	static function opcode_init()
	{
		RIO.opcode_clean();
		foreach (__class in [::RIO_OP, ::RIO_OP_AUDIO, ::RIO_OP_ANIM, ::RIO_OP_FLOW, ::RIO_OP_TEXT, ::RIO_OP_TIMER, ::RIO_OP_SCENE, ::RIO_OP_MENUS, ::RIO_OP_EFFECTS]) {
			foreach (name, v in __class) {
				local attr = __class.getattributes(name);
				if ("id" in attr) {
					RIO.opcode_info(__class, attr.id, name, attr.format, ("variadic" in attr) ? attr.variadic : 0);
				}
			}
		}
	}
}

RIO.opcode_init();