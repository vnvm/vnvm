package engines.dividead;
import engines.dividead.AB;

class AB_OP
{
	static margin = { x = 108, y = 400, h = 12 };
	
	var ab:AB;
	
	public function new(ab:AB)
	{
		this.ab = ab;
	}

	@Opcode({ id:0x00, format:"T", description:"Prints a text on the screen", savepoint:1 })
	function TEXT(done:Void -> Void, text:String):Void
	{
		//printf("TEXT: '%s'\n", text);
		local temp = Bitmap(::screen.w, ::screen.h);
		::screen.draw(temp);
		::font.print(::screen, text, AB_OP.margin.x, AB_OP.margin.y);
		paint(2, 1);
		while (true) {
			//if (::mouse.)
			if (Screen.input().mouse.click_left) break;
			if (Screen.input().mouse.press_right) break;
			Screen.frame();
		}
		temp.draw(::screen);
		paint(1, 1);
	}

	@Opcode({ id:0x01, format:"PT", description:"Adds an option to the list of options" })
	function OPTION_ADD(pointer:Int, text:String)
	{
		this.options.push({pointer = pointer, text = text});
	}
	
	@Opcode({ id:0x02, format:"P", description:"Jumps unconditionally to a fixed adress" })
	function JUMP(pointer:Int)
	{
		this.jump(pointer);
	}

	@Opcode({ id:0x03, format:"FF2", description:"Sets a range of flags to a value" })
	function SET_RANGE(start:Int, end:Int, value:Int)
	{
		printf("FLAG[%d..%d] = %d\n", start, end, value);
		for (n in start ... end + 1) this.ab.flags[n] = value;
	}

	@Opcode({ id:0x04, format:"Fc2", description:"Sets a flag with a value" })
	function SET(flag:Int, op:Int, value:Int)
	{
		printf("FLAG[%d] %c %d\n", flag, op, value);
		switch (op.charCodeAt(0)) {
			case '=': this.ab.flags[flag]  = value; break;
			case '+': this.ab.flags[flag] += value; break;
			case '-': this.ab.flags[flag] -= value; break;
			default: throw(::format("Unknown SET operation '%c'", op));
		}
	}

	@Opcode({ id:0x06, format:"", description:"Empties the option list", savepoint:1 })
	function OPTION_RESET()
	{
		this.options = [];
	}

	@Opcode({ id:0x07, format:"", description:"Show the list of options" })
	function OPTION_SHOW()
	{
		//::font.print(::screen, text, 108, 400);
		local selected_option = 0;
		local color_white = [1, 1, 1, 1];
		local color_red   = [1, 0, 0, 1];
		local temp = Bitmap(::screen.w, ::screen.h);
		::screen.draw(temp);
		while (1) {
			local mouse = Screen.input().mouse;
			
			selected_option = floor((mouse.y - AB_OP.margin.y) / AB_OP.margin.h);
			
			temp.draw(::screen);
			
			for (local n = 0; n < options.len(); n++) {
				::font.print(::screen, options[n].text, AB_OP.margin.x, AB_OP.margin.y + AB_OP.margin.h * n, (selected_option == n) ? color_red : color_white);
			}
			
			if (mouse.press_left && between(selected_option, 0, options.len())) {
				break;
			}
			
			paint(1, 1);
			Screen.frame();
		}
		
		temp.draw(::screen);
		paint(1, 1);
		
		local option = options[selected_option];
		this.jump(option.pointer);
	}

	@Opcode({ id:0x0A, format:"", description:"Shows again a list of options" })
	function OPTION_RESHOW()
	{
		AB_OP.OPTION_SHOW();
	}

	@Opcode({ id:0x10, format:"Fc2P", description:"Jumps if the condition is not true" })
	function JUMP_IF_NOT(flag, op, value, pointer)
	{
		//printf("JUMP_IF_NOT (%08X) FLAG[%d] %c %d\n", pointer, flag, op, value);
		local result = 0;
		switch (op)
		{
			case '=': result = (this.flags[flag] == value); break;
			case '}': result = (this.flags[flag] >  value); break;
			case '{': result = (this.flags[flag] <  value); break;
			default:
				throw(::format("Unknown JUMP_IF_NOT operation '%c'", op));
			break;
		}
		if (!result) this.jump(pointer);
	}

	@Opcode({ id:0x11, format:"2", description:"Wait `time` milliseconds" })
	function WAIT(time)
	{
	}

	@Opcode({ id:0x14, format:"2", description:"Repaints the screen" })
	function REPAINT(type)
	{
		paint(0, type);
	}

	@Opcode({ id:0x16, format:"S", description:"Puts an image overlay on the screen" })
	function IMAGE_OVERLAY(name)
	{
	}

	@Opcode({ id:0x18, format:"S", description:"Loads and executes a script" })
	function SCRIPT(name)
	{
		printf("SCRIPT('%s')\n", name);
		this.set_script(name);
	}

	@Opcode({ id:0x19, format:"", description:"Ends the game" })
	function GAME_END()
	{
		printf("GAME_END\n");
		this.end();
	}

	@Opcode({ id:0x1E, format:"", description:"Performs a fade out to color black" })
	function FADE_OUT_BLACK()
	{
		paint_to_color([0, 0, 0], 1000);
	}

	@Opcode({ id:0x1F, format:"", description:"Performs a fade out to color white" })
	function FADE_OUT_WHITE()
	{
	}

	@Opcode({ id:0x26, format:"S", description:"Starts a music" })
	function MUSIC_PLAY(name)
	{
	}

	@Opcode({ id:0x28, format:"", description:"Stops the currently playing music" })
	function MUSIC_STOP()
	{
	}

	@Opcode({ id:0x2B, format:"S", description:"Plays a sound in the voice channel" })
	function VOICE_PLAY(name)
	{
	}

	@Opcode({ id:0x30, format:"2222", description:"Sets a clipping for the screen" })
	function CLIP(x1, y1, x2, y2)
	{
	}

	@Opcode({ id:0x35, format:"S", description:"Plays a sound in the effect channel" })
	function EFFECT_PLAY(name)
	{
	}

	@Opcode({ id:0x36, format:"", description:"Stops the sound playing in the effect channgel" })
	function EFFECT_STOP()
	{
	}

	@Opcode({ id:0x37, format:"SS", description:"Sets the images that will be used in the map overlay" })
	function MAP_IMAGES(name1, name2)
	{
	}

	@Opcode({ id:0x38, format:"", description:"Empties the map_option list", savepoint:1 })
	function MAP_OPTION_RESET()
	{
		this.map_options = [];
	}

	@Opcode({ id:0x40, format:"P2222", description:"Adds an option to the map_option list" })
	function MAP_OPTION_ADD(pointer, x1, y1, x2, y2)
	{
		this.map_options.push({pointer=pointer, x1=x1, y1=y1, x2=x2, y2=y2});
	}

	@Opcode({ id:0x41, format:"", description:"Shows the map and waits for selecting an option" })
	function MAP_OPTION_SHOW()
	{
		printf("MAP_OPTIONS:\n");
		for (local n = 0; n < map_options.len(); n++) {
			local option = map_options[n];
			printf("  %08X: (%d,%d)-(%d,%d)\n", option.pointer, option.x1, option.y1, option.x2, option.y2);
		}
		local option = map_options[BotPlayer.select(map_options)];
		printf("* %08X\n", option.pointer);

		jump(option.pointer);
	}

	@Opcode({ id:0x46, format:"S", description:"Sets an image as the foreground" })
	function FOREGROUND(name)
	{
		//name = getNameExt(name, "BMP");
		get_image(name).draw(::screen);
	}

	@Opcode({ id:0x47, format:"s", description:"Sets an image as the background" })
	function BACKGROUND(name)
	{
		//name = getNameExt(name, "BMP");
		get_image(name).draw(::screen, 32, 8);
	}
	
	@Opcode({ id:0x4A, format:"2", description:"Repaints the inner part of the screen" })
	function REPAINT_IN(type)
	{
		paint(1, type);
	}

	@Opcode({ id:0x4B, format:"S", description:"Puts a character in the middle of the screen" })
	function CHARA1(name)
	{
		// b09_2a
		local image1 = get_image(name);
		local image1_mask = get_image(split(name, "_")[0] + "_0");
		//image1 = image1_mask;
		image1.copyChannel(image1_mask, "red", "alpha", 1);
		image1.draw(::screen, 640 * 1 / 2 - image1.w / 2, 385 - image1.h);
	}

	@Opcode({ id:0x4C, format:"SS", description:"Puts two characters in the screen" })
	function CHARA2(name1, name2)
	{
		local image1 = get_image(name1), image2 = get_image(name2);
		image1.draw(::screen, 640 * 1 / 3 - image1.w / 2, 385 - image1.h);
		image2.draw(::screen, 640 * 2 / 3 - image2.w / 2, 385 - image2.h);
	}

	@Opcode({ id:0x4D, format:"", description:"Performs an animation with the current background (ABCDEF)" })
	function ANIMATION()
	{
	}

	@Opcode({ id:0x4E, format:"", description:"Makes an scroll to the bottom with the current image" })
	function SCROLL_DOWN()
	{
	}

	@Opcode({ id:0x4F, format:"", description:"Makes an scroll to the top with the current image" })
	function SCROLL_UP()
	{
	}

	@Opcode({ id:0x50, format:"T", description:"Sets the title for the save" })
	function TITLE(text)
	{
		this.title = text;
	}
}
