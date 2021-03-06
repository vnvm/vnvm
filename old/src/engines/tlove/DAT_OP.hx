package engines.tlove;
import reflash.display2.Seconds;
import reflash.display2.Milliseconds;
import lang.signal.Signal;
import lang.promise.Promise;
import haxe.io.Path;
import common.ByteArrayUtils;
import common.imaging.BitmapData8;
import common.imaging.BmpColor;
import common.imaging.Palette;
import lang.MathEx;
import engines.tlove.Game;
import engines.tlove.GameState;
import haxe.Log;
import flash.errors.Error;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

/**
 * XYZ Script Engine
 * 
 * @see T_LOVE95.EXE:00409430
 */
class DAT_OP {
    var dat:DAT;
    var game:Game;
    var state:GameState;
    var delayEnabled:Bool = true;

    public function new(dat:DAT) {
        this.dat = dat;
        this.game = dat.game;
        this.state = dat.game.state;
    }

    @Opcode({ id:0x00, format:"", description:"End of file" })
    @Unimplemented
    function EOF() {
        throw(new Error("Reached End Of File"));
    }

    @Opcode( { id:0x16, format:"s1", description:"Interface (0x16)" } )
    @Unimplemented
    function INTERFACE1(file:String, unk:Int) {
        Log.trace("INTERFACE1: " + file);
    }

    @Opcode({ id:0xA6, format:"22", description:"Wait?" })
    @Unimplemented
    function MOUSE_WAIT_CLICK_EVERYWHERE(leftClickLabel:Int, rightClickLabel:Int) {
        return Promise.fromAnySignalOnce([game.onMouseLeftClick, game.onMouseRightClick]).then(function(e:MouseEvent) {
            if (e.type == MouseEvent.CLICK) {
                dat.jumpLabel(leftClickLabel);
            } else if (e.type == "rightClick") {
                dat.jumpLabel(rightClickLabel);
            } else {
                throw(new Error('Invalid event for MOUSE_WAIT_CLICK_EVERYWHERE $e'));
            }
        });
    }

    @Opcode( { id:0x17, format:"1", description:"Unknown??" } )
    function MOUSE_WAIT_EVENT(v:Int) {
        return Promise.fromAnySignalOnce([game.onMouseLeftClick, game.onMouseRightClick, game.onMouseMove]).then(function(e:MouseEvent) {
            game.lastMouseEvent = e;
        });
    }

    @Opcode({ id:0xAD, format:"2221", description:"" })
//@Unimplemented
    function MOUSE_JUMP_IF_EVENT(leftClickLabel:Int, rightClickLabel:Int, missLabel:Int, rectCount:Int) {
        if (game.lastMouseEvent.type == MouseEvent.CLICK) {
            dat.jumpLabel(leftClickLabel);
        } else if (game.lastMouseEvent.type == "rightClick") {
            dat.jumpLabel(rightClickLabel);
        } else {
            dat.jumpLabel(missLabel);
        }
/*
		if (game.mouseRects.length == 0) {
			//done();
			dat.jumpLabel(missLabel);
			done();
		} else {
			done();
		}
		*/
    }

    @Opcode({ id:0xA7, format:"22222", description:"" })
    @Unimplemented
    function MOUSE_JUMP_IF_IN(x1:Int, y1:Int, x2:Int, y2:Int, label:Int) {
        var rect:Rectangle = new Rectangle(x1, y1, x2 - x1, y2 - y1);

//game.mouseRects.push({ rect: rect, label : label, flagType : flagType, flagIndex : flagIndex });

        var pos:Point = new Point(game.lastMouseEvent.localX, game.lastMouseEvent.localY);
//Log.trace(Std.format("(${rect.x},${rect.y},${rect.width},${rect.height}) // ${pos.x},${pos.y}"));
        if (rect.containsPoint(pos)) {
            dat.jumpLabel(label);
        }
    }

    @Opcode({ id:0xAE, format:"2222212", description:"" })
//@Unimplemented
    function MOUSE_JUMP_IF_CLICK_IN_AND_FLAG(x1:Int, y1:Int, x2:Int, y2:Int, label:Int, flagType:Int, flagIndex:Int) {
        var rect:Rectangle = new Rectangle(x1, y1, x2 - x1, y2 - y1);

//game.mouseRects.push({ rect: rect, label : label, flagType : flagType, flagIndex : flagIndex });

        var pos:Point = new Point(game.lastMouseEvent.localX, game.lastMouseEvent.localY);
//Log.trace(Std.format("(${rect.x},${rect.y},${rect.width},${rect.height}) // ${pos.x},${pos.y}"));
        if (rect.containsPoint(pos)) {
            if (game.lastMouseEvent.type == MouseEvent.CLICK) {
//if (state.getBitSet(flagType, flagIndex))
                {
                    dat.jumpLabel(label);
                }
            }
        }
    }

    @Opcode( { id:0x19, format:"1s1", description:"Set NAME_L" } )
    @Unimplemented
    function NAME_L(v:Int, name:String, unk:Int) {
//Log.trace("-----------------------------------------------------------------------------");
//throw(new Error("CALL_SCRIPT_POS"));
//dat.callScriptAsync(name, true, -1, done);
    }

    @Opcode({ id:0x1B, format:"111", description:"??" })
    @Unimplemented
    function RENDER_NEW_NAME(nameIndex:Int, count:Int, varStart:Int) {
        var name = '';
        for (varIndex in varStart ... varStart + count) {
            name += String.fromCharCode(state.getLSW(varIndex));
        }
        state.setName(nameIndex, name);
    }

    @Opcode( { id:0x23, format:"111", description:"??" } )
    @Unimplemented
    function GAME_SAVE(index:Int, _unk1:Int, _unk2:Int) {
//throw(new Error("GAME_SAVE"));
    }

    @Opcode( { id:0x24, format:"111", description:"??" } )
    @Unimplemented
    function GAME_LOAD(index:Int, _unk1:Int, _unk2:Int) {
//throw(new Error("GAME_LOAD"));
    }

    @Opcode( { id:0x28, format:"2", description:"Jumps to an address" } )
//@Unimplemented
    function JUMP(label:Int) {
        dat.jumpLabel(label);
        return Promise.createResolved(null);
    }

    @Opcode( { id:0x2B, format:"2", description:"Jumps to an address" } )
    function CALL_LOCAL(label:Int) dat.callLabel(label);

    @Opcode( { id:0x30, format:"", description:"???" } )
    @Unimplemented
    function CLEAR_IMAGE_SCREEN() {
        game.layers[0].fillRect(0, game.layers[0].rect);
//throw(new Error("CLEAR_IMAGE_SCREEN"));
    }

    @Opcode( { id:0x31, format:"", description:"???" } )
    @Unimplemented
    function COPY_PALETTE() {
//Palette.copy(game.paletteRef[0], game.currentPalette);
    }

    @Opcode({ id:0x33, format:"s1", description:"Loads an image in a buffer" })
    function IMG_LOAD(name:String, layer:Int) {
        var mrs:MRS;
        return game.getMrsAsync(name, function(mrs:MRS) {
            Palette.copy(mrs.image.palette, game.lastLoadedPalette);
            mrs.image.drawToBitmapData8(game.layers[layer], 0, 0);
            if (layer == 0) game.updateImage();
        });
    }

    @Opcode({ id:0x34, format:"", description:"???" })
    @Unimplemented
    function UNKNOWN_34() {
//throw(new Error("UNKNOWN_34"));
    }

    @Opcode({ id:0x32, format:"", description:"Fade In" })
    function FADE_IN() {
        return game.sprite.interpolateAsync(game.blackOverlay, new Milliseconds(delayEnabled ? 500 : 0), { alpha: 0 });
    }

    @Opcode({ id:0x35, format:"", description:"Fade Out" })
    function FADE_OUT() {
        return game.sprite.interpolateAsync(game.blackOverlay, new Milliseconds(delayEnabled ? 500 : 0), { alpha: 1 });
    }

    @Opcode( { id:0x36, format:"1112222122", description:"Copy an slice of buffer into another" } )
//@Unimplemented
    function COPY_RECT(effect:Int, transparentColor:Int, srcLayer:Int, srcX:Int, srcY:Int, srcWidth:Int, srcHeight:Int, dstLayer:Int, dstX:Int = 0, dstY:Int = 0) {
        var src:BitmapData8 = dat.game.layers[srcLayer];
        var dst:BitmapData8 = dat.game.layers[dstLayer];

        switch (effect)
        {
            case 0:
                BitmapData8.copyRect(src, new Rectangle(srcX, srcY, srcWidth, srcHeight), dst, new Point(dstX, dstY));
                if (dstLayer == 0) dat.game.updateImage(new Rectangle(dstX, dstY, srcWidth, srcHeight));
                return game.sprite.waitAsync(new Seconds(0.0));
//case 29:
            default:
                if (delayEnabled) {
                    return game.sprite.animateAsync(new Milliseconds(400), function(step:Float) {
                        BitmapData8.copyRectTransition(src, new Rectangle(srcX, srcY, srcWidth, srcHeight), dst, new Point(dstX, dstY), step, effect, transparentColor);
                        if (dstLayer == 0) dat.game.updateImage(new Rectangle(dstX, dstY, srcWidth, srcHeight));
                    });
                }
                else {
                    BitmapData8.copyRectTransition(src, new Rectangle(srcX, srcY, srcWidth, srcHeight), dst, new Point(dstX, dstY), 1, effect, transparentColor);
                    if (dstLayer == 0) dat.game.updateImage(new Rectangle(dstX, dstY, srcWidth, srcHeight));
                    return game.sprite.waitAsync(new Seconds(0.0));
                }
        }
    }

    @Opcode( { id:0x38, format:"s1", description:"Load an animation" } )
    @Unimplemented
    function ANIMATION_START(name, n) {
//throw(new Error("ANIMATION_START"));
    }

    @Opcode( { id:0x39, format:"", description:"???" } )
    @Unimplemented
    function ANIMATION_STOP() {
//throw(new Error("ANIMATION_STOP"));
    }

    @Opcode( { id:0x3A, format:"112222", description:"Fills a rect" } )
//@Unimplemented
    function FILL_RECT(color:Int, unk:Int, x:Int, y:Int, w:Int, h:Int) {
        var rect:Rectangle = new Rectangle(state.getVal(x), state.getVal(y), state.getVal(w), state.getVal(h));
        game.layers[0].fillRect(color, rect);
        game.updateImage(rect);
    }

    @Opcode( { id:0x3C, format:"11111", description:"???" } )
//@Unimplemented
    function PALETTE_ACTION(mode:Int, index:Int, b:Int, r:Int, g:Int) {
        var color = new BmpColor(r, g, b, 0xFF);

        switch (mode) {
            case 0: // SET_WORK_PALETTE_COLOR
                game.workPalette.colors[index] = new BmpColor(r, g, b, 0xFF);
                return Promise.createResolved();
            case 1: // APPLY_PALETTE
                Palette.copy(game.workPalette, game.currentPalette);
                game.updateImage();
                return Promise.createResolved();
            case 2: // BACKUP_PALETTE
                Palette.copy(game.workPalette, game.backupPalette);
                return Promise.createResolved();
            case 3: // RESTORE_PALETTE
                Palette.copy(game.backupPalette, game.workPalette);
                return Promise.createResolved();
            case 4: // ANIMATE_PALETTE
                var src = game.workPalette.clone();
                var dst = game.currentPalette.clone();

                return game.sprite.animateAsync(new Milliseconds(delayEnabled ? 1000 : 0), function(step:Float) {
                    game.workPalette.interpolate(src, dst, step);
                    game.updateImage();
                });
            case 5: // COPY_PALETTE
                Palette.copy(game.lastLoadedPalette, game.workPalette);
                return Promise.createResolved();
            case 6: // FADE_PALETTE
                throw(new Error("FADE_PALETTE"));
            default:
                throw(new Error("PALETTE_ACTION: " + mode));
        }
    }

    @Opcode( { id:0x40, format:"112", description:"???" } )
    @Unimplemented
    function JUMP_IF_MENU_VAR(index:Int, value:Int, label:Int) {
        if ((state.getMV(index) & value) != 0) {
            dat.jumpLabel(label);
        }
    }

    @Opcode({ id:0x41, format:"221", description:"???" })
//@Unimplemented
    function JUMP_IF_FLAG(flagIndex:Int, mask:Int, label:Int) {
        if ((state.getNormalFlag(flagIndex) & mask) != 0) {
            dat.jumpLabel(label);
        }
    }

    @Opcode({ id:0x42, format:"12", description:"????" })
    @Unimplemented
    function JUMP_CHAIN(a, b) {
        throw(new Error("JUMP_CHAIN"));
    }

    @Opcode({ id:0x43, format:"", description:"????" })
    @Unimplemented
    function JUMP_IF_LSB(a, b) {
        throw(new Error("JUMP_IF_LSB"));
    }

    @Opcode({ id:0x44, format:"1122", description:"Jumps conditionally" })
    @Unimplemented
    function JUMP_IF_LSW(flag:Int, op:Int, imm:Int, label:Int) {
        var f = state.getLSW(flag);
        if (this.condition(f, op, imm)) {
            dat.jumpLabel(label);
        }
        return Promise.createResolved(null);
    }

    function condition(left, operator, right) {
        return switch (operator)
        {
            case 0: left <= right;
            case 1: left == right;
            case 2: left >= right;
            default: throw(new Error("Invalid operator"));
        }
    }

    @Opcode({ id:0x45, format:"", description:"????" })
    @Unimplemented
    function JUMP_SETTINGS() {
        throw(new Error("JUMP_SETTINGS"));
    }

    @Opcode({ id:0x48, format:"11", description:"???" })
    @Unimplemented
    function SET_MENU_VAR_BITS(index:Int, value:Int) {
        state.setMV(index, state.getMV(index) | value);
    }

    @Opcode({ id:0x49, format:"21", description:"???" })
    @Unimplemented
    function FLAG_SET_BITS(index:Int, value:Int) {
        var byteIndex:Int = Std.int(index / 8);
        var bitIndex:Int = Std.int(index % 8);
        if (value != 0) {
            state.setNormalFlag(byteIndex, state.getNormalFlag(byteIndex) | (1 << bitIndex));
        } else {
            state.setNormalFlag(byteIndex, state.getNormalFlag(byteIndex) & ~(1 << bitIndex));
        }
    }

    @Opcode({ id:0x4A, format:"21", description:"???" })
    @Unimplemented
    function SET_SEQUENCE(a:Int, b:Int) throw(new Error("SET_SEQUENCE"));

    @Opcode({ id:0x4B, format:"21", description:"???" })
    @Unimplemented
    function ADD_OR_RESET_LSB(a:Int, b:Int) throw(new Error("ADD_OR_RESET_LSB"));

    @Opcode( { id:0x4C, format:"11", description:"???" } )
    function ADD_OR_RESET_LSW(varIndex:Int, value:Int) {
        state.setLSW(varIndex, (value == 0) ? 0 : (state.getLSW(varIndex) + value));
    }

    @Opcode( { id:0x4D, format:"11", description:"???" } )
    @Unimplemented
    function SET_SET(index:Int, value:Int) state.setSettings(index, value);

    @Opcode( { id:0x52, format:"s1", description:"Loads a script and starts executing it" } )
    @Unimplemented
    function CALL_SCRIPT(name:String, _always_0:Int) {
        Log.trace("-----------------------------------------------------------------------------");
        return dat.callScriptAsync(name, -1);
    }

    @Opcode({ id:0x53, format:"111", description:"Ani play" })
    function SAVE_SYS_FLAG(flagIndex:Int, value:Int, _ff) {
        state.setSysFlag(flagIndex, value);
// TODO: Save Sys Flag
//throw(new Error("SAVE_SYS_FLAG"));
    }

    @Opcode({ id:0x54, format:"212", description:"???" })
//@Unimplemented
    function JUMP_COND_SYS_FLAG(flagIndex:Int, value:Int, label:Int) {
        if (this.state.getSysFlag(flagIndex) == value) dat.jumpLabel(label);
//return game.sprite.waitAsync(0);
        return Promise.createResolved(null);
    }

    @Opcode({ id:0x61, format:"s2", description:"Plays a midi file" })
    function MUSIC_PLAY(name:String, loop:Int) {
        return MUSIC_STOP().pipe(function(e) {
            return game.midi.getBytesAsync(Path.withExtension(name, "mid").toUpperCase()).then(function(bytes:ByteArray) {
//var sound:Sound = new Sound();
//sound.loadCompressedDataFromByteArray(bytes, bytes.length);
//game.musicChannel = sound.play();
            });
        });
    }

    @Opcode({ id:0x62, format:"", description:"???" })
    @Unimplemented
    function MUSIC_FIX() {
        throw(new Error("MUSIC_FIX"));
    }

    @Opcode( { id:0x63, format:"", description:"Music stop" } )
//@Unimplemented
    function MUSIC_STOP() {
        if (game.musicChannel != null) {
            game.musicChannel.stop();
            game.musicChannel = null;
        }
        return game.sprite.waitAsync(new Milliseconds(10));
    }

    @Opcode( { id:0x66, format:"s", description:"Plays a sound" } )
    @Unimplemented
    function SOUND_PLAY(name:String) {
        throw(new Error("SOUND_PLAY"));
        return game.sprite.waitAsync(new Milliseconds(10));
    }

    @Opcode( { id:0x67, format:"", description:"???" } )
    @Unimplemented
    function SOUND_STOP() {
        throw(new Error("SOUND_STOP"));
        return game.sprite.waitAsync(new Milliseconds(10));
    }

    @Opcode({ id:0x70, format:"?", description:"Put text (dialog)" })
    @Unimplemented
    function PUT_TEXT_DIALOG(text:ByteArray) {
        var outText = getProcessText(text);
        Log.trace(outText);
        game.putTextRectangle(state.textRectangle, outText);
//for (n in 0 ... textBA.length) {
//	Log.trace(textBA[n]);
//}
//throw(new Error("PUT_TEXT_DIALOG: " + textBA));
//if (state.textVisible) {
//
//}
    }

    function getProcessText(text:ByteArray):String {
        var out = '';
        for (command in processText(text)) out += command;
        return out;
    }

    function processText(text:ByteArray):Array<String> {
        var parts:Array<String> = [];
        try {
            while (text.bytesAvailable > 0) {
                var op:Int = text.readUnsignedByte();
                switch (op) {
                    case 5, 7, 13:
                    case 0:
                        text.readUnsignedByte();
                    case 1:
                        text.readUnsignedByte();
                    case 2:
                        text.readUnsignedByte();
                        parts.push("<push_button>");
                    case 3:
                        parts.push("<clear>");
                    case 4:
                        parts.push("<name:" + text.readUnsignedByte() + ">");
                    case 6:
                        if (text.readUnsignedByte() == 13) {
                            parts.push("<break>");
                        }
                    case 10:
                        var flagIndex = text.readUnsignedByte();
                        parts.push('' + state.getLSW(flagIndex));
                    case 12:
                        var flagIndex = text.readUnsignedByte();
                        var charCode0:Int = state.getLSW(flagIndex);
                        var charCode:Int = charCode0;
                        if ((charCode & 0xFF00) == 0x2000) charCode &= 0xFF;
                        parts.push(String.fromCharCode(charCode));
                    case 255:
                        var text = ByteArrayUtils.readStringz(text);
                        parts.push(text);
                    default:
                        throw(new Error("PUT_TEXT_DIALOG: " + op));
                }
            }
        } catch (e:Dynamic) {
            Log.trace("error text: " + e);
        }
        return parts;
    }

    @Opcode( { id:0x71, format:"22?", description:"Put text (y, x, text)" } )
    @Unimplemented
    function PUT_TEXT_AT_POSITION(x:Int, y:Int, text:ByteArray) {
        Log.trace("PUT_TEXT_AT_POSITION(" + x + "," + y + "):(" + state.getVal(x) + ", " + state.getVal(y) + ")");
        game.putText(state.getVal(x), state.getVal(y), getProcessText(text));
        Log.trace(text.position + "/" + text.length);
//throw(new Error("PUT_TEXT_AT_POSITION(" + x + "," + y + "):" + color + ":'" + text + "'"));
    }

    @Opcode({ id:0x72, format:"b", description:"???" })
    @Unimplemented
    function SET_DIALOG_TEXT_VISIBLE(visible:Bool) {
        state.textVisible = visible;
    }

    @Opcode({ id:0x73, format:"1", description:"???" })
    @Unimplemented
    function UNKNOWN_73(v) {
//throw(new Error("UNKNOWN_73"));
    }

    @Opcode({ id:0x75, format:"111", description:"???" })
    @Unimplemented
    function UNKNOWN_75(a, b, c) {
//throw(new Error("UNKNOWN_75"));
    }

    @Opcode({ id:0x82, format:"22221", description:"????" })
    @Unimplemented
    function SET_TEXT_WINDOW_RECTANGLE(x:Int, y:Int, width:Int, height:Int, _unk:Int) {
        x = state.getVal(x) + 8;
        y = state.getVal(y) + 8;
        width = state.getVal(width) - 16;
        height = state.getVal(height) - 16;
        var rect:Rectangle = new Rectangle(x, y, width, height);
        state.textRectangle = rect;
        Log.trace("SET_TEXT_WINDOW_RECTANGLE: " + rect);
//throw(new Error("SET_TEXT_WINDOW_RECTANGLE"));
    }

/**
	 * 
	 * @param	time
	 */

    @Opcode({ id:0x83, format:"2", description:"????" })
    @Unimplemented
    function DELAY_83(time:Int) {
        if (delayEnabled) {
            return game.sprite.waitAsync(new Milliseconds(time * 10));
        } else {
            return Promise.createResolved(null);
        }
    }

    @Opcode({ id:0x84, format:"s1", description:"Interface (0x84)" })
    @Unimplemented
    function INTERFACE2(file:String, _0:Int) {
        Log.trace("INTERFACE2: " + file);
//throw(new Error("INTERFACE2"));
    }

    @Opcode({ id:0x85, format:"", description:"" })
    @Unimplemented
    function UNKNOWN_85() {
//throw(new Error("UNKNOWN_85"));
    }

    @Opcode({ id:0x86, format:"22", description:"" })
    @Unimplemented
    function SET_PUSH_BUTTON_POSITION(x:Int, y:Int) {
//throw(new Error("SET_PUSH_BUTTON_POSITION"));
    }

    @Opcode({ id:0x87, format:"s1", description:"Interface (0x87)" })
    @Unimplemented
    function INTERFACE3(file:String, _0:Int) {
        Log.trace("INTERFACE3: " + file);
//throw(new Error("INTERFACE3"));
    }

    @Opcode( { id:0x89, format:"2", description:"Delay" } )
    function DELAY_89(time:Int) return game.sprite.waitAsync(new Milliseconds(time * 10));

/**
	 * 
	 */

    @Opcode({ id:0x8A, format:"", description:"Updates" })
    @Unimplemented
    function UPDATE() {
//throw(new Error("UPDATE"));
    }

    @Opcode({ id:0x91, format:"", description:"Return from a CALL" })
    function RETURN_LOCAL() dat.returnLabel();

    @Opcode({ id:0x92, format:"", description:"???" })
    @Unimplemented
    function RETURN_SCRIPT() {
        return dat.returnScriptAsync();
    }

    @Opcode({ id:0x94, format:"111", description:"???" })
    @Unimplemented
    function SET_LS_RAND(type:Int, index:Int, maxValue:Int) {
        if (type > 0) {
            state.setLSW(index, MathEx.randomInt(0, maxValue));
        } else {
            state.setLSB(index, MathEx.randomInt(0, maxValue));
        }
    }

    @Opcode({ id:0x95, format:"1221", description:"Sets a range of flags" })
    @Unimplemented
    function FLAG_SET_RANGE(type:Int, start:Int, count:Int, value:Int) {
        for (flag in start ... start + count) {
            state.setFlag(type, flag, value);
        }
    }

    @Opcode({ id:0x98, format:"?", description:"Sets a flag" })
//@Unimplemented
    function SET_LSW(params:ByteArray) {
        var flag:Int = params.readUnsignedShort() & 0x7FFF;
        var edi:Int = 0;
        var ebp:Int = 0;
        while (params.bytesAvailable > 0) {
            var op:Int = params.readUnsignedByte();
            if (op == 4) break;
            var value:Int = params.readUnsignedShort();
            if (op == 8) {
                op = 0;
            } else {
                value = state.getValR(value);
            }

            if ((params[params.position] & 2) != 0) {
                switch (op & 7) {
                    case 0: edi = value;
                    case 1: edi = -value;
                    case 2: edi = edi * value;
                    case 3: edi = Std.int(edi / value); edi = 0;
                    case 4:
                    default: throw(new Error());
                }
            } else {
                switch (op & 7) {
                    case 0: ebp += value;
                    case 1: ebp -= value;
                    case 2: ebp += value * edi; edi = 0;
                    case 3: ebp += Std.int(edi / value); edi = 0;
                    case 4:
                    default: throw(new Error());
                }
            }
        }
//Log.trace("FLAG_SET:" + flag + " :: " + edi + ", " + ebp + ": " + (edi + ebp));
        state.setLSW(flag, ebp + edi);
    }

    @Opcode({ id:0x99, format:"?", description:"Sets a flag (related)" })
    @Unimplemented
    function JUMP_SET_LSW_ROUTINE(s:ByteArray) {
        var left:Int, right:Int;
        var comparison:Int, operation:Int;
        var comparisonResult:Bool;
//throw(new Error("JUMP_SET_LSW_ROUTINE"));
        s.position = 0;
        while (s.bytesAvailable >= 5) {
//Log.trace("POS: " + s.position + ", " + s.length);
            left = state.getValR(s.readUnsignedShort());
            comparison = s.readUnsignedByte();
            right = state.getValR(s.readUnsignedShort());
            operation = s.readUnsignedByte();

            comparisonResult = switch (comparison) {
                case 0: left == right;
                case 1: left < right;
                case 2: left <= right;
                case 3: left > right;
                case 4: left >= right;
                case 5: left != right;
                default: throw(new Error("Invalid operation: " + operation));
            };

            switch (operation) {
                case 0: // JUMP
                    var label = state.getValR(s.readUnsignedShort());
                    if (comparisonResult) dat.jumpLabel(label);
                case 1: // SET FLAG
                    var varIndex = s.readUnsignedByte();
                    var value = state.getValR(s.readUnsignedShort());
                    if (comparisonResult) state.setLSW(varIndex, value);
            }
        }
    }

    @Opcode({ id:0x9D, format:"2", description:"????" })
    @Unimplemented
    function UNKNOWN_9D(v:Int) {
        Log.trace("UNKNOWN_9D: " + v);
//throw(new Error("UNKNOWN_9D"));
    }

    @Opcode({ id:0xAA, format:"2222", description:"????" })
    @Unimplemented
    function DISABLED_SET_AREA_HEIGHT(x1, y1, x2, y2) {
        throw(new Error("DISABLED_SET_AREA_HEIGHT"));
    }

    @Opcode({ id:0xF0, format:"", description:"" })
    @Unimplemented
    function FLASH_IN() {
        throw(new Error("FLASH_IN"));
    }

    @Opcode({ id:0xF1, format:"", description:"" })
    @Unimplemented
    function FLASH_OUT() {
        throw(new Error("FLASH_OUT"));
    }

    @Opcode({ id:0xF5, format:"1s", description:"" })
    @Unimplemented
    function ASSIGN_NAME(nameIndex:Int, name:String) {
        state.setName(nameIndex, name);
    }

    @Opcode({ id:0xFF, format:"", description:"Exits the game" })
    @Unimplemented
    function GAME_END() {
        throw("GAME_END");
    }
}
