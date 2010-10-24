class MSD_OP
{
	</ id=1, description="Sets the line number" />
	function LINE_NUMBER(line)
	{
		
	}

	</ id=5, description="Sets a flag value" />
	function FLAG_SET(flag, value)
	{
		
	}

	</ id=6, description="Jump" />
	function JUMP(flag, unk1, unk2, unk3)
	{
		
	}
	
	</ id=100, description="Background" />
	function SET_BACKGROUND(unknown, file)
	{
		this.scene.background.mgd = ::MGD(::paks["MGD"].get(file + ".MGD"));
	}

	</ id=102, description="Set character image" />
	function CHARACTER_IMAGE(index, file)
	{
		if (file == 0 || file == "DAMMY") {
			this.scene.characters[index].mgd = null;
		} else {
			//printf("CHARACTER_IMAGE\n");
			this.scene.characters[index].mgd = ::MGD(::paks["MGD"].get(file + ".MGD"));
		}
	}

	</ id=103, description="Set character image" />
	function CHARACTER_POSITION(index, x, y, unk)
	{
		local character = this.scene.characters[index];
		//character.x = x;
		//character.y = y;
		//this.scene.updateLayerDraw();
		//this.scene.copyLayerShowToDraw();
	}

	/*</ id=104, description="Set character image" />
	function CHARACTER_POSITION(index, file)
	{
	}*/

	</ id=110, description="Performs a transition" />
	function TRANSITION(unk1, time_ms, unk2, file)
	{
		
		if (file != "" && file != 0) {
			this.scene.transitionMask = ::MGD(::paks["MGD"].get(file + ".MGD")).image;
		}

		local timer = Timer(time_ms);
		this.scene.stepf = 0.0;
		while (timer.elapsedf < 1.0) {
			::input.update();
			timer.update(1000 / 30);
			this.scene.drawTo(::screen);
			Screen.flip();
			Screen.frame(30);
			this.scene.stepf = timer.elapsedf;
		}
		this.scene.copyLayerShowToDraw();
	}

	</ id=201, description="Set background music" />
	function MUSIC(file, unk1, unk2, unk3)
	{
		
	}

	</ id=1005, description="Set title" />
	function SET_CHAPTER_TITLE(title)
	{
		
	}

	</ id=2001, description="Set text color" />
	function SET_TEXT_COLOR(type, r, g, b)
	{
		
	}
	
	</ id=2008, description="Set voice file" />
	function SET_VOICE_FILE(text_id, file)
	{
		
	}

	</ id=2010, description="Set text" />
	function SET_TEXT(text_id, unk1, unk2, file, unk3, unk4)
	{
		
	}

	</ id=2009, description="Do a frame" />
	function WAIT_TEXT()
	{
		MSD_OP.TRANSITION(0, 200, 0, "");
		/*while (true) {
			::input.update();
			this.scene.drawTo(::screen);
			Screen.flip();
			Screen.frame(30);
		}*/
	}
}

class SceneObject
{
	name = "<unknown>";
	mgd = null;
	x = 0;
	y = 0;
	
	constructor(name)
	{
		this.name = name;
	}
	
	function drawTo(screen, x = 0, y = 0)
	{
		//printf("Drawing: %s : %d\n", this.name, (this.mgd != null) ? 1 : 0);
		if (this.mgd != null) this.mgd.drawTo(screen, x, y);
	}
}

class Scene
{
	allObjects = null;
	background = null;
	characters = null;

	layerDraw = null;
	layerShow = null;
	transitionMask = null;
	stepf = 0.0;
	
	constructor()
	{
		this.layerDraw = Bitmap(800, 600, 32); this.layerDraw.clear([0, 0, 0, 1.0]);
		this.layerShow = Bitmap(800, 600, 32); this.layerShow.clear([0, 0, 0, 1.0]);
		this.stepf = 0.0;
		this.background = SceneObject(::format("background"));
		this.characters = []; for (local n = 0; n < 16; n++) this.characters.push(SceneObject(::format("character %d", n)));
		this.allObjects = [this.background];
		foreach (character in this.characters) this.allObjects.push(character);
	}

	function updateLayerDraw()
	{
		this.layerDraw.clear([0, 0, 0, 1.0]);
		background.drawTo(this.layerDraw);
		foreach (object in characters) object.drawTo(this.layerDraw);
		//foreach (object in allObjects) object.drawTo(this.layerDraw);
	}
	
	function copyLayerShowToDraw()
	{
		this.layerShow.clear([0, 0, 0, 1.0]);
		this.layerShow.drawBitmap(this.layerDraw, 0, 0);
	}
	
	function drawTo(screen, x = 0, y = 0)
	{
		this.updateLayerDraw();
		screen.drawBitmap(this.layerShow, x, y);
		
		local effect;
		if (transitionMask != null) {
			effect         = Effect("transition");
			effect.blend   = 1;
			effect.reverse = 0;
			effect.image   = this.layerDraw;
			effect.mask    = this.transitionMask;
		} else {
			effect         = Effect("normal");
		}
		effect.step = this.stepf;
		Screen.pushEffect(effect);
		{
			screen.drawBitmap(this.layerDraw, x, y, this.stepf);
		}
		Screen.popEffect();
	}
}

class MSD
{
	data = null;
	dataScript = null;
	jumps = null;
	lines = null;
	scene = null;
	flags = null;
	
	constructor()
	{
		this.scene = Scene();
		this.flags = array(10000, 0);
	}

	static function getCryptKey(blockIndex)
	{
		return ::md5(::format("%s%d", "\x82\xBB\x82\xCC\x89\xD4\x82\xD1\x82\xE7\x82\xC9\x82\xAD\x82\xBF\x82\xC3\x82\xAF\x82\xF0", blockIndex));
	}
	
	function load(name)
	{
		this._load_decrypt(::paks["MSD" ].get(name + ".MSD"));
		this._load_parse();
		
		return this;
	}
	
	function _load_decrypt(dataStream)
	{
		this.data = blob(dataStream.len());
		local n = 0;
		while (!dataStream.eos()) {
			local str = xor_string(dataStream.readstring(0x20), MSD.getCryptKey(n++));
			this.data.writestring(str);
		}
		this.data.seek(0);
	}
	
	function _load_parse()
	{
		this.jumps = [];
		this.lines = [];

		this.data.seek(0);
		local magic      = this.data.readstringz(0x10); if (magic != "MSCENARIO FILE  ") throw("Not a MSCENARIO file");
		local version    = this.data.readn('i');        if (version != 0x10000) throw("Unknown MSCENARIO version");
		local count_jump = this.data.readn('i');
		local count_line = this.data.readn('i');
		this.data.seek(0x458);
		for (local n = 0; n < count_jump; n++) this.jumps.push(this.data.readn('i'));
		for (local n = 0; n < count_line; n++) this.lines.push(this.data.readn('i'));
		this.dataScript = this.data.readslice(this.data.len() - this.data.tell());
		this.dataScript.seek(0);
	}
	
	function execute()
	{
		while (!this.dataScript.eos()) {
			//printf("%s\n", object_to_string(executeInstructionSingle()));
			executeInstructionSingle();
		}

		return this;		
	}
	
	function readInstruction()
	{
		local type = this.dataScript.readn('w'); // 16 bits. Instruction type.
		local len  = this.dataScript.readn('w'); // 16 bits. Inscrution length.
		local parameters = [];
		if (len > 0) {
			local instructionParamsStream = this.dataScript.readblob(len);
			instructionParamsStream.seek(0);
			while (!instructionParamsStream.eos()) {
				local parameterType = instructionParamsStream.readn('b');
				switch (parameterType) {
					case 1: // LITERAL
						parameters.push(instructionParamsStream.readn('i'));
					break;
					case 2: // VARIABLE
						//parameters.push(::format("$%d", instructionParamsStream.readn('i')));
						parameters.push(this.flags[instructionParamsStream.readn('i')]);
						
					break;
					case 3: // STRING 
						parameters.push(instructionParamsStream.readstringz(-1));
					break;
					case 4: // ARRAY
						local items = [];
						do {
							local l = instructionParamsStream.readn('i');
							local r = instructionParamsStream.readn('i');
							if (l != -1) items.push([l, r]);
						} while (l != -1);
					break;
					default: throw("Unknown MSD.instruction.parameter type");
				}
			}
		}
		return {
			type       = type,
			parameters = parameters,
		};
	}
	
	function executeInstructionSingle()
	{
		local instruction = this.readInstruction();
		local retval = null;
		printf("%s\n", object_to_string(instruction));
		if (instruction.type in MSD.opcodes) {
			local cop = MSD.opcodes[instruction.type];

			if (cop.name in cop.__class) {
				instruction.parameters.insert(0, this);
				if (cop.variadic) {
					retval = cop.__class[cop.name].call(this, instruction.parameters);
				} else {
					retval = cop.__class[cop.name].acall(instruction.parameters);
				}
			}
		} else {
			//printf("Unknown opcode: %s\n", object_to_string(instruction));
		}
	}
	
	function dump(name) 
	{
		file(name, "wb").writeblob(this.data);
		
		return this;
	}

	static opcodes = {};
	static opcodesByName = {};

	static function opcode_clean()
	{
		MSD.opcodes <- {};
		MSD.opcodesByName <- {};
	}

	static function opcode_info(__class, id, name, params_format, variadic)
	{
		//printf("Added opcode(%d)\n", id);
		
		MSD.opcodes[id] <- {
			__class = __class,
			id = id,
			name = name,
			params_format = params_format,
			variadic = variadic,
		};
		MSD.opcodesByName[name] <- {
			__class = __class,
			id = id,
			name = name,
			params_format = params_format,
			variadic = variadic,
		};
	}

	static function opcode_init()
	{
		MSD.opcode_clean();
		foreach (__class in [::MSD_OP]) {
			foreach (name, v in __class) {
				local attr = __class.getattributes(name);
				if ("id" in attr) {
					MSD.opcode_info(__class, attr.id, name, "", ("variadic" in attr) ? attr.variadic : 0);
				}
			}
		}
	}
}

MSD.opcode_init();
