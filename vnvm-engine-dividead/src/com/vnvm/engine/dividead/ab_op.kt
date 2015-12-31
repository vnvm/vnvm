package com.vnvm.engine.dividead

import com.vnvm.common.IRectangle
import com.vnvm.common.Sound
import com.vnvm.common.async.Promise
import com.vnvm.common.async.unit
import com.vnvm.common.async.waitOneAsync
import com.vnvm.common.error.noImpl
import com.vnvm.common.image.BitmapDataUtils
import com.vnvm.common.image.Colors
import com.vnvm.common.log.Log
import com.vnvm.common.milliseconds
import com.vnvm.common.script.Opcode
import com.vnvm.common.seconds
import com.vnvm.common.view.Bitmap
import com.vnvm.common.view.Sprite

class AB_OP(val ab: AB) {
	//static var margin = { x = 108, y = 400, h = 12 };

	val game = ab.game
	val state = ab.game.state

	// ---------------
	//  FLOW RELATED
	// ---------------

	@Opcode(id = 0x02, format = "P", description = "Jumps unconditionally to a fixed address")
	public fun JUMP(offset: Int) {
		ab.jump(offset)
	};

	@Opcode(id = 0x10, format = "Fc2P", description = "Jumps if the condition is not true")
	public fun JUMP_IF_NOT(flag: Int, op: Char, value: Int, pointer: Int) {
		//printf("JUMP_IF_NOT (%08X) FLAG[%d] %c %d\n", pointer, flag, op, value);
		val result = when (op) {
			'=' -> (state.flags[flag] == value);
			'}' -> (state.flags[flag] > value);
			'{' -> (state.flags[flag] < value);
			else -> throw Exception("Unknown JUMP_IF_NOT operation '$op'")
		}
		if (!result) ab.jump(pointer);
	}

	@Opcode(id = 0x03, format = "FF2", description = "Sets a range of flags to a value")
	public fun SET_RANGE_FLAG(start: Int, end: Int, value: Int) {
		Log.trace("FLAG[$start..$end] = $value");
		Log.trace("CHECK: Is \'end\' flag included?");
		for (n in start until end) state.flags[n] = value;
	}

	@Opcode(id = 0x04, format = "Fc2", description = "Sets a flag with a value")
	public fun SET(flag: Int, op: Char, value: Int) {
		Log.trace("FLAG[$flag] $op $value");
		when (op) {
			'=' -> state.flags[flag] = value;
			'+' -> state.flags[flag] += value;
			'-' -> state.flags[flag] -= value;
			else -> throw Exception("Unknown SET operation '$op'")
		}
	}

	@Opcode(id = 0x18, format = "S", description = "Loads and executes a script")
	public fun SCRIPT(name: String): Promise<Boolean> {
		Log.trace("SCRIPT('$name')");
		return ab.loadScriptAsync(name, 0);
	}

	@Opcode(id = 0x19, format = "", description = "Ends the game")
	//@Unimplemented
	public fun GAME_END() {
		Log.trace("GAME_END");
		ab.end();
		throw Exception("GAME_END")
	}

	// ---------------
	//  INPUT
	// ---------------

	@Opcode(id = 0x00, format = "T", description = "Prints a text on the screen", savepoint = true)
	//@Unimplemented
	public fun TEXT(text: String): Promise<Unit> {
		//println("TEXT: $text")
		game.textField.text = text.replace('@', '"')

		return game.getImageCachedAsync("waku_p").pipe { wakuB ->
			var slices = (0 until 9).map { Bitmap(BitmapDataUtils.slice(wakuB, IRectangle(18 * it, 144, 18, 18))) }
			var animated = Sprite();
			var totalTime = 0
			animated.addUpdatable { dt ->
				totalTime += dt
				animated.removeChildren();
				animated.addChild(slices[(totalTime / 100) % slices.size]);
			}
			game.overlaySprite.removeChildren();
			game.overlaySprite.addChild(animated);
			var promise = if (game.isSkipping()) {
				game.gameSprite.timers.waitAsync(50.milliseconds);
			} else {
				//game.gameSprite.timers.waitAsync(5000.milliseconds);
				Promise.waitOneAsync(animated.keys.onKeyDown, animated.keys.onKeyPress, animated.mice.onMouseClick)
			}
			animated.x = 520.0;
			animated.y = 448.0;

			promise.then { e ->
				game.textField.text = "";
				game.overlaySprite.removeChildren();
				game.voiceChannel.stop();
			}
		}
	}

	@Opcode(id = 0x50, format = "T", description = "Sets the title for the save")
	public fun TITLE(title: String) {
		state.title = title
		println("Set title: '$title'")
	}

	@Opcode(id = 0x06, format = "", description = "Empties the option list", savepoint = true)
	public fun OPTION_RESET() {
		//game.optionList.clear();
		state.options = arrayListOf();
		noImpl
	}

	@Opcode(id = 0x01, format = "PT", description = "Adds an option to the list of options")
	//@Unimplemented
	public fun OPTION_ADD(pointer: Int, text: String) {
		val option = GameState.Option(pointer, text)
		state.options.add(option)
		//game.optionList.addOption(text, option);
		noImpl
	}

	@Opcode(id = 0x07, format = "", description = "Show the list of options")
	//@Unimplemented
	public fun OPTION_SHOW() {
		/*
		game.optionList.visible = true;
		return game.optionList.onSelected.waitOneAsync().then { e ->
			game.optionList.visible = false;
			ab.jump(e.selectedOption.data.pointer);
		}
		*/
		noImpl
	}

	@Opcode(id = 0x0A, format = "", description = "Shows again a list of options")
	public fun OPTION_RESHOW() = OPTION_SHOW();

	@Opcode(id = 0x37, format = "SS", description = "Sets the images that will be used in the map overlay")
	public fun MAP_IMAGES(name1: String, name2: String) {
		game.state.mapImage1 = name1;
		game.state.mapImage2 = name2;
	}

	@Opcode(id = 0x38, format = "", description = "Empties the map_option list", savepoint = true)
	public fun MAP_OPTION_RESET() {
		game.state.optionsMap.clear();
	}

	@Opcode(id = 0x40, format = "P2222", description = "Adds an option to the map_option list")
	public fun MAP_OPTION_ADD(pointer: Int, x1: Int, y1: Int, x2: Int, y2: Int) {
		game.state.optionsMap.add(GameState.MapOption(pointer, IRectangle(x1, y1, x2 - x1, y2 - y1)));
	}

	@Opcode(id = 0x41, format = "", description = "Shows the map and waits for selecting an option")
	public fun MAP_OPTION_SHOW(): Promise<Unit> {
		/*
		return Promise.whenAll(
			game.getImageCachedAsync(game.state.mapImage1),
			game.getImageCachedAsync(game.state.mapImage2)
		).pipe { bitmaps ->
			val bg = bitmaps[0];
			val fg = bitmaps[1];
			var matrix = Matrix();
			matrix.translate(32.0, 8.0);
			game.front.draw(bg, matrix);

			var events = EventListenerListGroup();
			var deferred = Promise.Deferred<Unit>();

			game.state.optionsMap.forEach { option ->
				var pointer = option.pointer;
				var rect: Rectangle = option.rect;
				var slice = Sprite();
				slice.addChild(Bitmap(BitmapDataUtils.slice(fg, rect), PixelSnapping.AUTO, true));
				slice.x = rect.x + 32;
				slice.y = rect.y + 8;
				slice.alpha = 0.0
				events.addEventListener(slice, MouseEvent.MOUSE_OVER, function(e) {
					println("over");
					slice.alpha = 1.0
				});
				events.addEventListener(slice, MouseEvent.MOUSE_OUT, function(e) {
					println("out");
					slice.alpha = 0.0
				});
				events.addEventListener(slice, MouseEvent.CLICK, function(e) {
					deferred.resolve(option);
				});
				game.overlaySprite.addChild(slice);
			}

			deferred.promise.then { option ->
				events.dispose();
				game.overlaySprite.removeChildren();
				ab.jump(option.pointer);
			}
		}
		*/
		noImpl
	}

	@Opcode(id = 0x11, format = "2", description = "Wait `time` milliseconds")
	public fun WAIT(time: Int): Promise<Unit> {
		if (game.isSkipping()) return Promise.unit

		return game.gameSprite.timers.waitAsync(time.milliseconds)
	}

	// ---------------
	//  SOUND RELATED
	// ---------------

	@Opcode(id = 0x26, format = "S", description = "Starts a music")
	public fun MUSIC_PLAY(name: String): Promise<Unit> {
		var sound: Sound;

		MUSIC_STOP();
		return ab.game.getMusicAsync(name).then { sound ->
			ab.game.musicChannel.play(sound)
		}
	}

	@Opcode(id = 0x28, format = "", description = "Stops the currently playing music")
	public fun MUSIC_STOP() {
		ab.game.musicChannel.stop();
	}

	@Opcode(id = 0x2B, format = "S", description = "Plays a sound in the voice channel")
	public fun VOICE_PLAY(name: String): Promise<Unit> {
		return ab.game.getSoundAsync(name).then { sound ->
			ab.game.voiceChannel.play(sound)
		}
	}

	@Opcode(id = 0x35, format = "S", description = "Plays a sound in the effect channel")
	public fun EFFECT_PLAY(name: String): Promise<Unit> {
		EFFECT_STOP();
		return ab.game.getSoundAsync(name).then { sound ->
			ab.game.effectChannel.play(sound)
		}
	}

	@Opcode(id = 0x36, format = "", description = "Stops the sound playing in the effect channgel")
	public fun EFFECT_STOP() {
		ab.game.effectChannel.stop();
	}

	// ---------------
	//  IMAGE RELATED
	// ---------------

	@Opcode(id = 0x46, format = "S", description = "Sets an image as the foreground")
	public fun FOREGROUND(name: String): Promise<Unit> {
		return game.getImageCachedAsync(name).then { bitmapData ->
			game.back.draw(bitmapData, 0, 0);
		}
	}

	@Opcode(id = 0x47, format = "s", description = "Sets an image as the background")
	public fun BACKGROUND(name: String): Promise<Unit> {
		state.background = name;
		return game.getImageCachedAsync(name).then { bitmapData ->
			game.back.draw(bitmapData, 32, 8);
		}
	}

	@Opcode(id = 0x16, format = "S", description = "Puts an image overlay on the screen")
	public fun IMAGE_OVERLAY(name: String): Promise<Unit> {
		return game.getImageCachedAsync(name).then { bitmapData ->
			var outBitmapData = BitmapDataUtils.chromaKey(bitmapData, 0x00FF00)
			game.back.draw(outBitmapData, 32, 8);
		}
	}

	@Opcode(id = 0x4B, format = "S", description = "Puts a character in the middle of the screen")
	public fun CHARA1(name: String): Promise<Unit> {
		var nameColor = name;
		var nameMask = name.split('_')[0] + "_0"

		return game.getImageMaskCachedAsync(nameColor, nameMask).then { bitmapData ->
			game.back.draw(bitmapData, (640 / 2 - bitmapData.width / 2), (385 - bitmapData.height));
		}
	}

	@Opcode(id = 0x4C, format = "SS", description = "Puts two characters in the screen")
	public fun CHARA2(name1: String, name2: String): Promise<Unit> {
		var name1Color = name1;
		var name1Mask = name1.split('_')[0] + "_0"

		var name2Color = name2;
		var name2Mask = name2.split('_')[0] + "_0"

		return game.getImageMaskCachedAsync(name1Color, name1Mask).pipe { bitmapData1 ->
			game.getImageMaskCachedAsync(name2Color, name2Mask).then { bitmapData2 ->
				game.back.draw(bitmapData1, 640 * 1 / 3 - bitmapData1.width / 2, 385 - bitmapData1.height);
				game.back.draw(bitmapData2, 640 * 2 / 3 - bitmapData2.width / 2, 385 - bitmapData2.height);
			}
		}
	}

	// ----------------------
	//  IMAGE/EFFECT RELATED
	// ----------------------

	@Opcode(id = 0x4D, format = "", description = "Performs an animation with the current background (ABCDEF)")
	public fun ANIMATION(type: Int): Promise<Unit> {
		/*
		var time = if (game.isSkipping()) 50.milliseconds else 500.milliseconds
		var names = (0 until 6).map { n -> state.background.substr(0, -1) + String.fromCharCode('A'.code + n)] }
		var promises = names.map { game.getImageCachedAsync(name) }
		return Promise.whenAll(promises).pipe { images ->
			var stepAsync: (() -> Promise<Unit>)? = null
			stepAsync = fun(v: Any) {
				if (images.length > 0) {
					var image = images.shift();
					//trace('image', image);
					var bmp = Bitmap(image, PixelSnapping.AUTO, true);
					bmp.x = 32.0;
					bmp.y = 8.0;
					game.overlaySprite.removeChildren();
					game.overlaySprite.addChild(bmp);
					game.back.draw(image, new Matrix(1, 0, 0, 1, 32, 8));
					return game.gameSprite.timers.waitAsync(time).pipe(stepAsync);
				} else {
					return game.gameSprite.timers.waitAsync(time);
				}
			};
			stepAsync(null).then {
				//trace('*******************');
				game.overlaySprite.removeChildren();
			}
		}
		*/
		return Promise.unit
	}

	@Opcode(id = 0x4E, format = "", description = "Makes an scroll to the bottom with the current image")
	public fun SCROLL_DOWN(type: Int) = _SCROLL_DOWN_UP("A", +1.0);

	@Opcode(id = 0x4F, format = "", description = "Makes an scroll to the top with the current image")
	public fun SCROLL_UP(type: Int) = _SCROLL_DOWN_UP("B", -1.0);

	private fun _SCROLL_DOWN_UP(add: String, multiplier: Double) {
		/*
		val time = if (game.isSkipping()) 300.milliseconds else 3000.milliseconds
		val bgB = state.background + add;

		return game.getImageCachedAsync(bgB).pipe { bgBImage ->
			var bgImage = BitmapDataUtils.slice(game.front, IRectangle(32, 8, bgBImage.width, bgBImage.height));
			var a = Bitmap(bgImage, PixelSnapping.AUTO, true);
			var b = Bitmap(bgBImage, PixelSnapping.AUTO, true);
			var container = Sprite();
			b.y = a.height * multiplier;
			container.addChild(a);
			container.addChild(b);
			container.scrollRect = Rectangle(0.0, 0.0, bgImage.width, bgImage.height)
			container.x = 32.0
			container.y = 8.0
			game.overlaySprite.removeChildren();
			game.overlaySprite.addChild(container);

			game.gameSprite.animateAsync(time, Easing.easeInOutQuad) { ratio ->
				val ratio = ratio * multiplier;
				container.scrollRect = Rectangle(0, bgImage.height * ratio, bgImage.width, bgImage.height);
			}.then { v ->
				game.front.draw(container, Matrix(1.0, 0.0, 0.0, 1.0, 32.0, 8.0));
				game.back.draw(container, Matrix(1.0, 0.0, 0.0, 1.0, 32.0, 8.0));
				game.overlaySprite.removeChildren();
			}
		}
		*/
	}


	// ----------------------
	//  EFFECT RELATED
	// ----------------------

	@Opcode(id = 0x30, format = "2222", description = "Sets a clipping for the screen")
	public fun CLIP(x1: Int, y1: Int, x2: Int, y2: Int) {
	}

	@Opcode(id = 0x14, format = "2", description = "Repaints the screen")
	public fun REPAINT(type: Int) = ab.paintAsync(0, type);

	@Opcode(id = 0x4A, format = "2", description = "Repaints the inner part of the screen")
	public fun REPAINT_IN(type: Int) = ab.paintAsync(1, type);

	@Opcode(id = 0x1E, format = "", description = "Performs a fade out to color black")
	public fun FADE_OUT_BLACK() = ab.paintToColorAsync(Colors.BLACK, 1.seconds);

	@Opcode(id = 0x1F, format = "", description = "Performs a fade out to color white")
	public fun FADE_OUT_WHITE() = ab.paintToColorAsync(Colors.WHITE, 1.seconds);
}
