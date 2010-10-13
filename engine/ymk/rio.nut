class RIO
{
	static opcodes = {};
	name = null;
	data = null;
	state = null;
	maskWip = null;
	table = null;
	anim = null;
	fps = 40;
	music = null;
	music_stream = null;
	sound = null;
	todo = 0;
	running = true;
	wip_clkwait = null;
	wip_clkwait_frames = null;
	font = null;
	voice_channel = 6;
	draw_interface = 0;
	last_title = "";
	last_text = "";
	
	constructor()
	{
		this.state = State();
		this.table = TBL(); this.table.state = this.state;
		this.anim  = ANM();
		this.running = true;
		this.wip_clkwait = resman.get_image("CLKWAIT", 0);
		//this.wip_clkwait_frames = wip_clkwait.images[0].split(wip_clkwait.images[0].h, wip_clkwait.images[0].h);
		//wip_clkwait.images[0].save("CLKWAIT.bmp");
		
		local iwait = wip_clkwait.images[0];
		
		switch (engine_version) {
			case "pw":
				this.wip_clkwait_frames = iwait.slice(1, 0, iwait.w, iwait.h).split(55, iwait.h);
			break;
			default:
				this.wip_clkwait_frames = iwait.split(iwait.h, iwait.h);
			break;
		}
		this.font = Font("lucon.ttf", 19);
	}

	/**
	 * Draws the scene in 'sceneLayerDraw':
	 *   - Background/UI
	 *   - Sprites
	 */
	function updateSceneLayer()
	{
		if (this.state.background != "") {
			// Background
			resman.get_image(this.state.background.name).drawTo(sceneLayerDraw, 0, -this.state.background.x, -this.state.background.y);
		} else if (this.state.background_color != null) {
			// Background color
			sceneLayerDraw.clear(this.state.background_color);
		} else {
			// UI
			anim.drawTo(sceneLayerDraw);
		}

		// Draw sprites
		foreach (sprite in [this.state.sprites_l1[0], this.state.sprites_l1[1], this.state.sprites_l1[2], this.state.sprites_object]) {
			if (sprite == null) continue;
			resman.get_image(sprite.name).drawTo(sceneLayerDraw, 0, sprite.x, sprite.y);
		}
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
		data.seek(data.tell() + relative_position);
		this.state.script_set_pc(data.tell());
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
	
	function print_text(text, x, y)
	{
		this.font.setColor([0x3C / 255.0, 0x5f / 255.0, 0xaf / 255.0, 1]);
		// 3c5faf
		for (local cy = -1; cy <= 1; cy++) {
			for (local cx = -1; cx <= 1; cx++) {
				if (cx != 0 && cy != 0) {
					this.font.print(screen, text, x + cx, y + cy);
				}
			}
		}
		this.font.setColor([1, 1, 1, 1]);
		this.font.print(screen, text, x, y);
	}
	
	function frame_draw_tick()
	{
		this.frame_draw();
		this.frame_tick();
	}
	
	function frame_draw()
	{
		screen.drawBitmap(sceneLayerShow);
		//frame_draw_interface();
	}
	
	function frame_draw_interface(show_header_text = 0)
	{
		local wip = resman.get_image("WINBASE0", 0);
		local x = 800 / 2 - wip.infos[0].w / 2;
		local y = 600 - wip.infos[0].h;
		
		local num_buttons;
		
		switch (engine_version) {
			case "pw":
				num_buttons = 10;
			break;
			default:
				num_buttons = 8;
			break;
		}
		
		for (local n = 0; n < num_buttons; n++) {
			wip.drawTo(screen, n, x, y);
		}
		
		if (show_header_text) wip.drawTo(screen, num_buttons * 3 + 1, x, y);
	}
	
	function skipping()
	{
		return ::keyboard.pressing("lctrl");
	}
	
	function input_update()
	{
		::mouse.update();
		::keyboard.update();
	}

	/**
	 * Performs a frame tick.
	 *   -------------- Updates timer.
	 *   - Swaps the frame buffer. 
	 *   - Waits 1000/25 ms (since last frame)
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
				case '.': data.readn('b'); break;
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
		local name = "?", params_format = "", vparams = [];
		try {
			local cop = RIO.opcodes[op];
			name = cop.name;
			params_format = cop.params_format;
			vparams = process_params(params_format);
			if (name.len() == 0) name = ::format("OP_%02X", op);
			
			this.state.script_set_pc(data.tell());
			
			//printf("OP:%02X\n", op);
			
			if (name in cop.__class) {
				vparams.insert(0, this);
				todo = 0;
				//printf("---%s\n" name);
				local retval = cop.__class[name].acall(vparams);
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

	static function opcode_info(__class, id, name, params_format)
	{
		RIO.opcodes[id] <- {
			__class = __class,
			name = name,
			params_format = params_format
		};
	}

	static function opcode_init()
	{
		RIO.opcode_clean();
		foreach (__class in [::RIO_OP, ::RIO_OP_AUDIO, ::RIO_OP_ANIM, ::RIO_OP_FLOW, ::RIO_OP_TEXT, ::RIO_OP_TIMER, ::RIO_OP_SCENE, ::RIO_OP_MENUS, ::RIO_OP_EFFECTS]) {
			foreach (name, v in __class) {
				local attr = __class.getattributes(name);
				if ("id" in attr) {
					RIO.opcode_info(__class, attr.id, name, attr.format);
				}
			}
		}
	}
}

RIO.opcode_init();