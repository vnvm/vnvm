package engines.dividead;
import reflash.display2.Update;
import reflash.display2.View;
import lang.promise.IPromise;
import common.event.EventListenerListGroup;
import common.event.EventListenerGroup;
import flash.display.Sprite;
import flash.display.PixelSnapping;
import flash.events.MouseEvent;
import flash.display.Bitmap;
import flash.geom.Rectangle;
import common.imaging.BitmapDataUtils;
import lang.signal.Signal;
import lang.promise.Promise;
import common.display.OptionSelectedEvent;
import common.input.GameInput;
import engines.dividead.AB;
import haxe.Log;
import flash.display.BitmapData;
import flash.errors.Error;
import flash.geom.Matrix;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.text.TextField;

class AB_OP {
//static var margin = { x = 108, y = 400, h = 12 };

    var ab:AB;
    var game:Game;
    var state:GameState;

    public function new(ab:AB) {
        this.ab = ab;
        this.game = ab.game;
        this.state = ab.game.state;
    }

// ---------------
//  FLOW RELATED
// ---------------

    @Opcode({ id:0x02, format:"P", description:"Jumps unconditionally to a fixed adress" })
    public function JUMP(offset:Int) ab.jump(offset);

    @Opcode({ id:0x10, format:"Fc2P", description:"Jumps if the condition is not true" })
    public function JUMP_IF_NOT(flag:Int, opId:Int, value:Int, pointer:Int) {
        var op:String = String.fromCharCode(opId);
        //printf("JUMP_IF_NOT (%08X) FLAG[%d] %c %d\n", pointer, flag, op, value);
        var result:Bool = false;
        switch (op)
        {
            case '=': result = (state.flags[flag] == value);
            case '}': result = (state.flags[flag] > value);
            case '{': result = (state.flags[flag] < value);
            default: throw(new Error('Unknown JUMP_IF_NOT operation \'$op\''));
        }
        if (!result) ab.jump(pointer);
    }

    @Opcode({ id:0x03, format:"FF2", description:"Sets a range of flags to a value" })
    public function SET_RANGE_FLAG(start:Int, end:Int, value:Int) {
        Log.trace('FLAG[$start..$end] = $value');
        Log.trace('CHECK: Is \'end\' flag included?');
        for (n in start ... end) state.flags[n] = value;
    }

    @Opcode({ id:0x04, format:"Fc2", description:"Sets a flag with a value" })
    public function SET(flag:Int, opId:Int, value:Int) {
        var op:String = String.fromCharCode(opId);
        Log.trace('FLAG[$flag] $op $value');
        switch (op) {
            case '=': state.flags[flag] = value;
            case '+': state.flags[flag] += value;
            case '-': state.flags[flag] -= value;
            default: throw('Unknown SET operation "$op"');
        }
    }

    @Opcode({ id:0x18, format:"S", description:"Loads and executes a script" })
    public function SCRIPT(name:String) {
        Log.trace('SCRIPT("$name")');
        return ab.loadScriptAsync(name, 0);
    }

    @Opcode({ id:0x19, format:"", description:"Ends the game" })
//@Unimplemented
    public function GAME_END() {
        Log.trace("GAME_END");
        ab.end();
        throw(new Error("GAME_END"));
    }

// ---------------
//  INPUT
// ---------------

    @Opcode({ id:0x00, format:"T", description:"Prints a text on the screen", savepoint:1 })
//@Unimplemented
    public function TEXT(text:String) {
        game.textField.text = StringTools.replace(text, '@', '"');

        return game.getImageCachedAsync('waku_p').pipe(function(wakuB:BitmapData) {
            var slices = [for (n in 0 ... 9) new Bitmap(BitmapDataUtils.slice(wakuB, new Rectangle(18 * n, 144, 18, 18)), null, true)];
            var animated = new View();
            animated.addUpdater(function(u:Update) {
                animated.removeChildren();
                animated.addChild(slices[Std.int((u.totalMs / 100) % slices.length)]);
                //u.dt
            });
            game.overlaySprite.removeChildren();
            game.overlaySprite.addChild(animated);
            var promise = if (game.isSkipping()) {
                game.gameSprite.waitAsync(50);
            } else {
                Promise.fromAnySignalOnce([GameInput.onClick, GameInput.onKeyPress]);
            }
            animated.x = 520;
            animated.y = 448;

            return promise.then(function(e) {
                game.textField.text = '';
                game.overlaySprite.removeChildren();
                if (game.voiceChannel != null) {
                    game.voiceChannel.stop();
                    game.voiceChannel = null;
                }
            });
        });
    }

    @Opcode({ id:0x50, format:"T", description:"Sets the title for the save" })
    public function TITLE(title:String) state.title = title;

    @Opcode({ id:0x06, format:"", description:"Empties the option list", savepoint:1 })
    public function OPTION_RESET() {
        game.optionList.clear();
        state.options = [];
    }

    @Opcode({ id:0x01, format:"PT", description:"Adds an option to the list of options" })
//@Unimplemented
    public function OPTION_ADD(pointer:Int, text:String) {
        state.options.push({ pointer : pointer, text : text });
        game.optionList.addOption(text, { pointer : pointer, text : text });
    }

    @Opcode({ id:0x07, format:"", description:"Show the list of options" })
//@Unimplemented
    public function OPTION_SHOW() {
        var e:OptionSelectedEvent;
        game.optionList.visible = true;
        return Promise.fromSignalOnce(game.optionList.onSelected).then(function(e:OptionSelectedEvent) {
            game.optionList.visible = false;
            ab.jump(e.selectedOption.data.pointer);
        });
    }

    @Opcode({ id:0x0A, format:"", description:"Shows again a list of options" })
    public function OPTION_RESHOW() return OPTION_SHOW();

    @Opcode({ id:0x37, format:"SS", description:"Sets the images that will be used in the map overlay" })
    @Unimplemented
    public function MAP_IMAGES(name1:String, name2:String) {
        game.state.mapImage1 = name1;
        game.state.mapImage2 = name2;
    }

    @Opcode({ id:0x38, format:"", description:"Empties the map_option list", savepoint:1 })
    @Unimplemented
    public function MAP_OPTION_RESET() {
        game.state.optionsMap = [];
    }

    @Opcode({ id:0x40, format:"P2222", description:"Adds an option to the map_option list" })
    @Unimplemented
    public function MAP_OPTION_ADD(pointer:Int, x1:Int, y1:Int, x2:Int, y2:Int) {
        game.state.optionsMap.push({pointer: pointer, rect: new Rectangle(x1, y1, x2 - x1, y2 - y1)});
    }

    @Opcode({ id:0x41, format:"", description:"Shows the map and waits for selecting an option" })
    @Unimplemented
    public function MAP_OPTION_SHOW() {
        return Promise.whenAll([
            game.getImageCachedAsync(game.state.mapImage1),
            game.getImageCachedAsync(game.state.mapImage2)
        ]).pipe(function(bitmaps:Array<Dynamic>) {
            var bg:BitmapData = bitmaps[0];
            var fg:BitmapData = bitmaps[1];
            var matrix = new Matrix();
            matrix.translate(32, 8);
            game.front.draw(bg, matrix);

            var events = new EventListenerListGroup();
            var deferred = Promise.createDeferred();

            Lambda.foreach(game.state.optionsMap, function(option: { pointer:Int, rect: Rectangle }) {
                var pointer = option.pointer;
                var rect:Rectangle = option.rect;
                var slice = new Sprite();
                slice.addChild(new Bitmap(BitmapDataUtils.slice(fg, rect), PixelSnapping.AUTO, true));
                slice.x = rect.x + 32;
                slice.y = rect.y + 8;
                slice.alpha = 0;
                events.addEventListener(slice, MouseEvent.MOUSE_OVER, function(e) {
                    trace('over');
                    slice.alpha = 1;
                });
                events.addEventListener(slice, MouseEvent.MOUSE_OUT, function(e) {
                    trace('out');
                    slice.alpha = 0;
                });
                events.addEventListener(slice, MouseEvent.CLICK, function(e) {
                    deferred.resolve(option);
                });
                game.overlaySprite.addChild(slice);
                return true;
            });

            return deferred.promise.then(function(option) {
                events.dispose();
                game.overlaySprite.removeChildren();
                ab.jump(option.pointer);
                return;
            });
        });
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
    }

    @Opcode({ id:0x11, format:"2", description:"Wait `time` milliseconds" })
//@Unimplemented
    public function WAIT(time:Int) {
        if (game.isSkipping()) return Promise.createResolved();

        return game.gameSprite.waitAsync(time);
    }

// ---------------
//  SOUND RELATED
// ---------------

    @Opcode({ id:0x26, format:"S", description:"Starts a music" })
//@Unimplemented
    public function MUSIC_PLAY(name:String) {
        var sound:Sound;

        MUSIC_STOP();
        return ab.game.getMusicAsync(name).then(function(sound:Sound) {
            ab.game.musicChannel = sound.play(0, -1, new SoundTransform(1, 0));
        });
    }

    @Opcode({ id:0x28, format:"", description:"Stops the currently playing music" })
    public function MUSIC_STOP() {
        if (ab.game.musicChannel == null) return;
        ab.game.musicChannel.stop();
        ab.game.musicChannel = null;
    }

    @Opcode({ id:0x2B, format:"S", description:"Plays a sound in the voice channel" })
//@Unimplemented
    public function VOICE_PLAY(name:String) {
        var sound:Sound;
        return ab.game.getSoundAsync(name).then(function(sound:Sound) {
            ab.game.voiceChannel = sound.play(0, 0, new SoundTransform(1, 0));
        });
    }

    @Opcode({ id:0x35, format:"S", description:"Plays a sound in the effect channel" })
//@Unimplemented
    public function EFFECT_PLAY(name:String) {
        var sound:Sound;
        EFFECT_STOP();
        return ab.game.getSoundAsync(name).then(function(sound:Sound) {
            ab.game.effectChannel = sound.play(0, 0, new SoundTransform(1, 0));
        });
    }

    @Opcode({ id:0x36, format:"", description:"Stops the sound playing in the effect channgel" })
//@Unimplemented
    public function EFFECT_STOP() {
        if (ab.game.effectChannel == null) return;
        ab.game.effectChannel.stop();
        ab.game.effectChannel = null;
    }

// ---------------
//  IMAGE RELATED
// ---------------

    @Opcode({ id:0x46, format:"S", description:"Sets an image as the foreground" })
//@Unimplemented
    public function FOREGROUND(name:String) {
        return game.getImageCachedAsync(name).then(function(bitmapData:BitmapData) {
            var matrix:Matrix = new Matrix();
            matrix.translate(0, 0);
            game.back.draw(bitmapData, matrix);
        });
    }

    @Opcode({ id:0x47, format:"s", description:"Sets an image as the background" })
//@Unimplemented
    public function BACKGROUND(name:String) {
        state.background = name;
        return game.getImageCachedAsync(name).then(function(bitmapData:BitmapData) {
            var matrix:Matrix = new Matrix();
            matrix.translate(32, 8);
            game.back.draw(bitmapData, matrix);
        });
    }

    @Opcode({ id:0x16, format:"S", description:"Puts an image overlay on the screen" })
    @Unimplemented
    public function IMAGE_OVERLAY(name:String) {
        return game.getImageCachedAsync(name).then(function(bitmapData:BitmapData) {
            var outBitmapData = BitmapDataUtils.chromaKey(bitmapData, 0x00FF00);
            var matrix:Matrix = new Matrix();
            matrix.translate(32, 8);
            game.back.draw(outBitmapData, matrix);
        });
    }

    @Opcode({ id:0x4B, format:"S", description:"Puts a character in the middle of the screen" })
//@Unimplemented
    public function CHARA1(name:String) {
        var bitmapData:BitmapData;

        var nameColor = name;
        var nameMask = name.split('_')[0] + '_0' ;

        return game.getImageMaskCachedAsync(nameColor, nameMask).then(function(bitmapData:BitmapData) {
            var matrix:Matrix = new Matrix();
            matrix.translate(Std.int(640 / 2 - bitmapData.width / 2), Std.int(385 - bitmapData.height));
            game.back.draw(bitmapData, matrix);
        });
    }

    @Opcode({ id:0x4C, format:"SS", description:"Puts two characters in the screen" })
    @Unimplemented
    public function CHARA2(name1:String, name2:String) {
        var bitmapData1:BitmapData;
        var bitmapData2:BitmapData;

        var name1Color = name1;
        var name1Mask = name1.split('_')[0] + '_0' ;

        var name2Color = name2;
        var name2Mask = name2.split('_')[0] + '_0' ;

        return game.getImageMaskCachedAsync(name1Color, name1Mask).pipe(function(bitmapData1:BitmapData) {
            return game.getImageMaskCachedAsync(name2Color, name2Mask).then(function(bitmapData2:BitmapData) {
                var matrix:Matrix;
                matrix = new Matrix();
                matrix.translate(Std.int(640 * 1 / 3 - bitmapData1.width / 2), Std.int(385 - bitmapData1.height));
                game.back.draw(bitmapData1, matrix);

                matrix = new Matrix();
                matrix.translate(Std.int(640 * 2 / 3 - bitmapData2.width / 2), Std.int(385 - bitmapData2.height));
                game.back.draw(bitmapData2, matrix);
            });
        });
    }

// ----------------------
//  IMAGE/EFFECT RELATED
// ----------------------

    @Opcode({ id:0x4D, format:"", description:"Performs an animation with the current background (ABCDEF)" })
    @Unimplemented
    public function ANIMATION(type:Int) {
        var time = game.isSkipping() ? 50 : 500;
        var names = [for (n in 0 ... 6) state.background.substr(0, -1) + String.fromCharCode('A'.code + n)];
        var promises = [for (name in names) game.getImageCachedAsync(name)];
        return Promise.whenAll(promises).pipe(function(images:Array<Dynamic>) {
            var stepAsync:Dynamic -> IPromise<Dynamic> = null;
            stepAsync = function(v:Dynamic) {
                if (images.length > 0) {
                    var image = images.shift();
                    //trace('image', image);
                    var bmp = new Bitmap(image, PixelSnapping.AUTO, true);
                    bmp.x = 32;
                    bmp.y = 8;
                    game.overlaySprite.removeChildren();
                    game.overlaySprite.addChild(bmp);
                    game.back.draw(image, new Matrix(1, 0, 0, 1, 32, 8));
                    return game.gameSprite.waitAsync(time).pipe(stepAsync);
                } else {
                    return game.gameSprite.waitAsync(time);
                }
            };
            return stepAsync(null).then(function(v) {
                //trace('*******************');
                game.overlaySprite.removeChildren();
            });
        });
    }

    @Opcode({ id:0x4E, format:"", description:"Makes an scroll to the bottom with the current image" })
    public function SCROLL_DOWN(type:Int) return _SCROLL_DOWN_UP('A', 1);

    @Opcode({ id:0x4F, format:"", description:"Makes an scroll to the top with the current image" })
    public function SCROLL_UP(type:Int) return _SCROLL_DOWN_UP('B', -1);

    private function _SCROLL_DOWN_UP(add:String, multiplier:Float) {
        var time:Int = game.isSkipping() ? 300 : 3000;
        var bgB = state.background + add;

        return game.getImageCachedAsync(bgB).pipe(function(bgBImage:BitmapData) {
            var bgImage = BitmapDataUtils.slice(game.front, new Rectangle(32, 8, bgBImage.width, bgBImage.height));
            var a = new Bitmap(bgImage, PixelSnapping.AUTO, true);
            var b = new Bitmap(bgBImage, PixelSnapping.AUTO, true);
            var container = new Sprite();
            b.y = a.height * multiplier;
            container.addChild(a);
            container.addChild(b);
            container.scrollRect = new Rectangle(0, 0, bgImage.width, bgImage.height);
            container.x = 32;
            container.y = 8;
            game.overlaySprite.removeChildren();
            game.overlaySprite.addChild(container);

            return game.gameSprite.animateAsync(time, function(ratio) {
                ratio = ratio * multiplier;
                container.scrollRect = new Rectangle(0, bgImage.height * ratio, bgImage.width, bgImage.height);
            }).then(function(v) {
                game.front.draw(container, new Matrix(1, 0, 0, 1, 32, 8));
                game.back.draw(container, new Matrix(1, 0, 0, 1, 32, 8));
                game.overlaySprite.removeChildren();
            });
        });
    }


// ----------------------
//  EFFECT RELATED
// ----------------------

    @Opcode({ id:0x30, format:"2222", description:"Sets a clipping for the screen" })
    @Unimplemented
    public function CLIP(x1:Int, y1:Int, x2:Int, y2:Int) {
    }

    @Opcode({ id:0x14, format:"2", description:"Repaints the screen" })
    public function REPAINT(type:Int) return ab.paintAsync(0, type);

    @Opcode({ id:0x4A, format:"2", description:"Repaints the inner part of the screen" })
    public function REPAINT_IN(type:Int) return ab.paintAsync(1, type);

    @Opcode({ id:0x1E, format:"", description:"Performs a fade out to color black" })
    public function FADE_OUT_BLACK() return ab.paintToColorAsync([0x00, 0x00, 0x00], 1.0);

    @Opcode({ id:0x1F, format:"", description:"Performs a fade out to color white" })
    public function FADE_OUT_WHITE() return ab.paintToColorAsync([0xFF, 0xFF, 0xFF], 1.0);
}