package engines.dividead;
import common.Event2;
import common.GameInput;
import common.Keys;
import cpp.Utf8;
import engines.brave.formats.Decrypt;
import engines.dividead.AB;
import haxe.Log;
import haxe.Timer;
import nme.display.BitmapData;
import nme.errors.Error;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Matrix;
import nme.media.Sound;
import nme.media.SoundTransform;
import nme.text.TextField;

class AB_OP
{
	//static var margin = { x = 108, y = 400, h = 12 };
	
	var ab:AB;
	
	public function new(ab:AB)
	{
		this.ab = ab;
	}

	@Opcode({ id:0x00, format:"<T", description:"Prints a text on the screen", savepoint:1 })
	public function TEXT(done:Void -> Void, text:String):Void
	{
		ab.game.textField.text = StringTools.replace(text, '@', '"');

		Event2.registerOnceAny([GameInput.onClick, GameInput.onKeyPress], function(e:Event):Void {
			ab.game.textField.text = '';
			if (ab.game.voiceChannel != null) {
				ab.game.voiceChannel.stop();
				ab.game.voiceChannel = null;
			}
			done();
		});
	}

	@Opcode({ id:0x01, format:"PT", description:"Adds an option to the list of options" })
	public function OPTION_ADD(pointer:Int, text:String)
	{
		ab.game.state.options.push({ pointer : pointer, text : text });
	}
	
	@Opcode({ id:0x02, format:"P", description:"Jumps unconditionally to a fixed adress" })
	public function JUMP(offset:Int)
	{
		ab.jump(offset);
	}

	@Opcode({ id:0x03, format:"FF2", description:"Sets a range of flags to a value" })
	public function SET_RANGE(start:Int, end:Int, value:Int)
	{
		Log.trace(Std.format("FLAG[$start..$end] = $value"));
		for (n in start ... end + 1) ab.game.state.flags[n] = value;
	}

	@Opcode({ id:0x04, format:"Fc2", description:"Sets a flag with a value" })
	public function SET(flag:Int, opId:Int, value:Int)
	{
		var op:String = String.fromCharCode(opId);
		Log.trace(Std.format("FLAG[$flag] $op $value"));
		switch (op) {
			case '=': ab.game.state.flags[flag]  = value;
			case '+': ab.game.state.flags[flag] += value;
			case '-': ab.game.state.flags[flag] -= value;
			default: throw(Std.format("Unknown SET operation '$op'"));
		}
	}

	@Opcode({ id:0x06, format:"", description:"Empties the option list", savepoint:1 })
	public function OPTION_RESET()
	{
		ab.game.state.options = [];
	}

	@Opcode({ id:0x07, format:"<", description:"Show the list of options" })
	public function OPTION_SHOW(done:Void -> Void)
	{
		throw(new Error("error"));
		//done();
		/*
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
		*/
	}

	@Opcode({ id:0x0A, format:"<", description:"Shows again a list of options" })
	public function OPTION_RESHOW(done:Void -> Void)
	{
		OPTION_SHOW(done);
	}

	@Opcode({ id:0x10, format:"Fc2P", description:"Jumps if the condition is not true" })
	public function JUMP_IF_NOT(flag:Int, opId:Int, value:Int, pointer:Int):Void
	{
		var op:String = String.fromCharCode(opId);
		//printf("JUMP_IF_NOT (%08X) FLAG[%d] %c %d\n", pointer, flag, op, value);
		var result:Bool = false;
		switch (op)
		{
			case '=': result = (ab.game.state.flags[flag] == value);
			case '}': result = (ab.game.state.flags[flag] >  value);
			case '{': result = (ab.game.state.flags[flag] <  value);
			default: throw(new Error(Std.format("Unknown JUMP_IF_NOT operation '$op'")));
		}
		if (!result) ab.jump(pointer);
	}

	@Opcode({ id:0x11, format:"<2", description:"Wait `time` milliseconds" })
	public function WAIT(done:Void -> Void, time:Int):Void
	{
		Timer.delay(done, time);
	}

	@Opcode({ id:0x14, format:"<2", description:"Repaints the screen" })
	public function REPAINT(done:Void -> Void, type:Int):Void
	{
		ab.paintAsync(0, type, done);
	}

	@Opcode({ id:0x16, format:"S", description:"Puts an image overlay on the screen" })
	public function IMAGE_OVERLAY(name:String)
	{
	}

	@Opcode({ id:0x18, format:"<S", description:"Loads and executes a script" })
	public function SCRIPT(done:Void -> Void, name:String):Void
	{
		Log.trace(Std.format("SCRIPT('$name')"));
		ab.loadScriptAsync(name, done);
	}

	@Opcode({ id:0x19, format:"", description:"Ends the game" })
	public function GAME_END()
	{
		Log.trace("GAME_END");
		ab.end();
	}

	@Opcode({ id:0x1E, format:"<", description:"Performs a fade out to color black" })
	public function FADE_OUT_BLACK(done:Void -> Void)
	{
		ab.paintToColorAsync([0x00, 0x00, 0x00], 1.0, done);
	}

	@Opcode({ id:0x1F, format:"<", description:"Performs a fade out to color white" })
	public function FADE_OUT_WHITE(done:Void -> Void)
	{
		ab.paintToColorAsync([0xFF, 0xFF, 0xFF], 1.0, done);
	}

	@Opcode({ id:0x26, format:"<S", description:"Starts a music" })
	public function MUSIC_PLAY(done:Void -> Void, name:String):Void
	{
		MUSIC_STOP();
		ab.game.getMusic(name, function(sound:Sound) {
			ab.game.musicChannel = sound.play(0, 0, new SoundTransform(1, 0));
			done();
		});
	}

	@Opcode({ id:0x28, format:"", description:"Stops the currently playing music" })
	public function MUSIC_STOP():Void
	{
		if (ab.game.musicChannel != null) {
			ab.game.musicChannel.stop();
			ab.game.musicChannel = null;
		}
	}

	@Opcode({ id:0x2B, format:"<S", description:"Plays a sound in the voice channel" })
	public function VOICE_PLAY(done:Void -> Void, name:String):Void
	{
		var sound:Sound;
		ab.game.getSound(name, function(sound:Sound):Void {
			ab.game.voiceChannel = sound.play(0, 0, new SoundTransform(1, 0));
			done();
		});
	}

	@Opcode({ id:0x30, format:"2222", description:"Sets a clipping for the screen" })
	public function CLIP(x1, y1, x2, y2)
	{
	}

	@Opcode({ id:0x35, format:"<S", description:"Plays a sound in the effect channel" })
	public function EFFECT_PLAY(done:Void -> Void, name:String):Void
	{
		var sound:Sound;
		EFFECT_STOP();
		ab.game.getSound(name, function(sound:Sound):Void {
			ab.game.effectChannel = sound.play(0, 0, new SoundTransform(1, 0));
			done();
		});
	}

	@Opcode({ id:0x36, format:"", description:"Stops the sound playing in the effect channgel" })
	public function EFFECT_STOP():Void
	{
		if (ab.game.effectChannel != null) {
			ab.game.effectChannel.stop();
			ab.game.effectChannel = null;
		}
	}

	@Opcode({ id:0x37, format:"SS", description:"Sets the images that will be used in the map overlay" })
	public function MAP_IMAGES(name1, name2)
	{
	}

	@Opcode({ id:0x38, format:"", description:"Empties the map_option list", savepoint:1 })
	public function MAP_OPTION_RESET():Void
	{
		ab.game.state.optionsMap = [];
	}

	@Opcode({ id:0x40, format:"P2222", description:"Adds an option to the map_option list" })
	public function MAP_OPTION_ADD(pointer:Int, x1:Int, y1:Int, x2:Int, y2:Int):Void
	{
		ab.game.state.optionsMap.push({pointer: pointer, x1: x1, y1: y1, x2: x2, y2: y2});
	}

	@Opcode({ id:0x41, format:"<", description:"Shows the map and waits for selecting an option" })
	public function MAP_OPTION_SHOW(done:Void -> Void):Void
	{
		throw(new Error());
		/*
		printf("MAP_OPTIONS:\n");
		for (local n = 0; n < map_options.len(); n++) {
			local option = map_options[n];
			printf("  %08X: (%d,%d)-(%d,%d)\n", option.pointer, option.x1, option.y1, option.x2, option.y2);
		}
		local option = map_options[BotPlayer.select(map_options)];
		printf("* %08X\n", option.pointer);

		jump(option.pointer);
		*/
		done();
	}

	@Opcode({ id:0x46, format:"<S", description:"Sets an image as the foreground" })
	public function FOREGROUND(done:Void -> Void, name:String):Void
	{
		ab.game.getImageCachedAsync(name, function(bitmapData:BitmapData):Void {
			var matrix:Matrix = new Matrix();
			matrix.translate(0, 0);
			ab.game.back.draw(bitmapData, matrix);
			done();
		});
	}

	@Opcode({ id:0x47, format:"<s", description:"Sets an image as the background" })
	public function BACKGROUND(done:Void -> Void, name:String):Void
	{
		ab.game.getImageCachedAsync(name, function(bitmapData:BitmapData):Void {
			var matrix:Matrix = new Matrix();
			matrix.translate(32, 8);
			ab.game.back.draw(bitmapData, matrix);
			done();
		});
	}
	
	@Opcode({ id:0x4A, format:"<2", description:"Repaints the inner part of the screen" })
	public function REPAINT_IN(done:Void -> Void, type:Int):Void
	{
		ab.paintAsync(1, type, done);
	}

	@Opcode({ id:0x4B, format:"<S", description:"Puts a character in the middle of the screen" })
	public function CHARA1(done:Void -> Void, name:String):Void
	{
		/*
		// b09_2a
		local image1 = get_image(name);
		local image1_mask = get_image(split(name, "_")[0] + "_0");
		//image1 = image1_mask;
		image1.copyChannel(image1_mask, "red", "alpha", 1);
		image1.draw(::screen, 640 * 1 / 2 - image1.w / 2, 385 - image1.h);
		*/
		done();
	}

	@Opcode({ id:0x4C, format:"<SS", description:"Puts two characters in the screen" })
	public function CHARA2(done:Void -> Void, name1:String, name2:String):Void
	{
		/*
		local image1 = get_image(name1), image2 = get_image(name2);
		image1.draw(::screen, 640 * 1 / 3 - image1.w / 2, 385 - image1.h);
		image2.draw(::screen, 640 * 2 / 3 - image2.w / 2, 385 - image2.h);
		*/
		done();
	}

	@Opcode({ id:0x4D, format:"", description:"Performs an animation with the current background (ABCDEF)" })
	public function ANIMATION()
	{
	}

	@Opcode({ id:0x4E, format:"", description:"Makes an scroll to the bottom with the current image" })
	public function SCROLL_DOWN()
	{
	}

	@Opcode({ id:0x4F, format:"", description:"Makes an scroll to the top with the current image" })
	public function SCROLL_UP()
	{
	}

	@Opcode({ id:0x50, format:"T", description:"Sets the title for the save" })
	public function TITLE(title:String):Void
	{
		ab.game.state.title = title;
	}
}
