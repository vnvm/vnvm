package engines.tlove.script;
import common.imaging.BitmapData8;
import common.imaging.BmpColor;
import common.imaging.Palette;
import engines.tlove.Game;
import engines.tlove.GameState;
import engines.tlove.mrs.MRS;
import haxe.Timer;
import nme.errors.Error;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.utils.ByteArray;

class DAT_OP // T_LOVE95.EXE:00409430
{
	var dat:DAT;
	var game:Game;
	var state:GameState;
	
	public function new(dat:DAT) {
		this.dat = dat;
		this.game = dat.game;
		this.state = dat.game.state;
	}
	
	@Opcode({ id:0x00, format:"", description:"End of file" })
	function EOF() {
	}

	// TODO.
	@Opcode({ id:0x16, format:"s1", description:"Interface (0x16)" })
	function INTERFACE1(file, _0) {
	}

	// TODO.
	@Opcode({ id:0x17, format:"1", description:"Unknown??" })
	function WAIT_MOUSE_EVENT(v) {
	}

	// TODO.
	@Opcode({ id:0x19, format:"1s1", description:"Set NAME_L" })
	function NAME_L(v, s, _0) {
	}

	// TODO.
	@Opcode({ id:0x1B, format:"12", description:"??" })
	function UNKNOWN_1B(a, b) {
	}

	// TODO.
	@Opcode({ id:0x23, format:"111", description:"??" })
	function GAME_SAVE(a, b, c) {
	}

	// TODO.
	@Opcode({ id:0x24, format:"111", description:"??" })
	function GAME_LOAD(a, b, c) {
	}

	@Opcode({ id:0x28, format:"2", description:"Jumps to an address" })
	function JUMP(label:Int):Void {
		dat.jumpLabel(label);
	}
	
	@Opcode({ id:0x2B, format:"2", description:"Jumps to an address" })
	function CALL_LOCAL(label:Int):Void {
		dat.callLabel(label);
	}

	// TODO.
	@Opcode({ id:0x30, format:"", description:"???" })
	function CLEAR_IMAGE_SCREEN() {
	}

	// TODO.
	@Opcode({ id:0x31, format:"", description:"???" })
	function COPY_PALETTE() {
	}

	// TODO.
	@Opcode({ id:0x32, format:"", description:"???" })
	function FADE_IN() {
	}

	@Opcode({ id:0x33, format:"<s1", description:"Loads an image in a buffer" })
	function IMG_LOAD(done:Void -> Void, name:String, layer_dst:Int):Void {
		var mrs:MRS;
		game.getMrsAsync(name, function(mrs:MRS) {
			Palette.copy(mrs.image.palette, game.lastLoadedPalette);
			mrs.image.drawToBitmapData8(game.layers[layer_dst], 0, 0);
			done();
		});
	}

	// TODO.
	@Opcode({ id:0x34, format:"", description:"???" })
	function UNKNOWN_34() {
	}

	// TODO.
	@Opcode({ id:0x35, format:"", description:"???" })
	function FADE_OUT() {
	}

	/**
	 * Copy a rect from one layer to other
	 * 
	 * @param	done
	 * @param	time
	 * @param	transparentColor
	 * @param	srcLayer
	 * @param	srcX
	 * @param	srcY
	 * @param	srcWidth
	 * @param	srcHeight
	 * @param	dstLayer
	 * @param	dstX
	 * @param	dstY
	 */
	@Opcode( { id:0x36, format:"<1112222122", description:"Copy an slice of buffer into another" } )
	function COPY_RECT(done:Void -> Void, time:Int, transparentColor:Int, srcLayer:Int, srcX:Int, srcY:Int, srcWidth:Int, srcHeight:Int, dstLayer:Int, dstX:Int = 0, dstY:Int = 0):Void {
		var src:BitmapData8 = dat.game.layers[srcLayer];
		var dst:BitmapData8 = dat.game.layers[dstLayer];
		BitmapData8.copyRect(src, new Rectangle(srcX, srcY, srcWidth, srcHeight), dst, new Point(dstX, dstY));
		dat.game.updateImage();
		Timer.delay(done, 0);
	}

	@Opcode({ id:0x38, format:"s1", description:"Load an animation" })
	function ANIMATION_START(name, n) {
	}

	// TODO.
	@Opcode({ id:0x39, format:"", description:"???" })
	function ANIMATION_STOP() {
	}

	// (4039) 3A: 0A : 0000 0010 0148 01F0 0040(
	@Opcode({ id:0x3A, format:"112222", description:"Fills a rect" })
	function FILL_RECT(color:Int, unk:Int, x:Int, y:Int, w:Int, h:Int):Void {
		game.layers[0].fillRect(color, new Rectangle(x, y, w, h));
		game.updateImage();
	}

	// TODO.
	@Opcode({ id:0x3C, format:"<11111", description:"???" })
	function PALETTE_ACTION(done:Void -> Void, mode:Int, index:Int, b:Int, r:Int, g:Int) {
		switch (mode) {
			case 0:
				// SET_WORK_PALETTE_COLOR
				dat.game.workPalette.colors[index] = { r : r, g : g, b : b, a : 0xFF };
			case 1:
				// APPLY_PALETTE
				Palette.copy(dat.game.workPalette, dat.game.currentPalette);
			case 2:
				// BACKUP_PALETTE
				Palette.copy(dat.game.workPalette, dat.game.backupPalette);
			case 3:
				// RESTORE_PALETTE
				Palette.copy(dat.game.backupPalette, dat.game.workPalette);
			case 4:
				// ANIMATE_PALETTE
				throw(new Error("ANIMATE_PALETTE"));
			case 5:
				// COPY_PALETTE
				Palette.copy(dat.game.lastLoadedPalette, dat.game.workPalette);
			case 6:
				// FADE_PALETTE
				throw(new Error("FADE_PALETTE"));
			default:
				throw(new Error("PALETTE_ACTION"));
		}
		
		Timer.delay(done, 0);
	}
	
	// TODO.
	@Opcode({ id:0x40, format:"", description:"???" })
	function JUMP_IF_MENU_VAR() {
	}

	// TODO.
	@Opcode({ id:0x41, format:"221", description:"???" })
	function JUMP_IF_REL(a, b, c) {
	}

	// TODO.
	@Opcode({ id:0x42, format:"12", description:"????" })
	function JUMP_CHAIN(a, b) {
	}
	
	// TODO.
	@Opcode({ id:0x43, format:"", description:"????" })
	function JUMP_IF_LSB(a, b) {
	}

	@Opcode({ id:0x44, format:"1122", description:"Jumps conditionally" })
	function JUMP_IF_LSW(flag, op, imm, label) {
	}
	
	// TODO.
	@Opcode({ id:0x45, format:"", description:"????" })
	function JUMP_SETTINGS() {
	}

	// TODO.
	@Opcode({ id:0x48, format:"21", description:"???" })
	function SET_MENU_VAR_BITS(a, b) {
	}

	// TODO.
	@Opcode({ id:0x49, format:"21", description:"???" })
	function SET_FLAG_BITS(a, b) {
	}
	
	// TODO.
	@Opcode({ id:0x4A, format:"21", description:"???" })
	function SET_SEQUENCE(a, b) {
	}
	
	// TODO.
	@Opcode({ id:0x4B, format:"21", description:"???" })
	function ADD_OR_RESET_LSB(a, b) {
	}

	// TODO.
	@Opcode({ id:0x4C, format:"21", description:"???" })
	function ADD_OR_RESET_LSW(a, b) {
	}
	
	// TODO.
	@Opcode({ id:0x4D, format:"21", description:"???" })
	function SET_SET(a, b) {
	}

	@Opcode({ id:0x52, format:"s1", description:"Loads a script and starts executing it" })
	function SCRIPT(name, _always_0) {
	}

	@Opcode({ id:0x53, format:"111", description:"Ani play" })
	function SAVE_SYS_FLAG(y, x, _ff) {
	}

	// TODO.
	@Opcode({ id:0x54, format:"212", description:"???" })
	function JUMP_COND_SYS_FLAG(a, b, c) {
	}

	@Opcode({ id:0x61, format:"s2", description:"Plays a midi file" })
	function MUSIC_PLAY(name, loop) {
	}

	// TODO.
	@Opcode({ id:0x62, format:"", description:"???" })
	function UNKNOWN_62() {
	}

	@Opcode({ id:0x63, format:"", description:"Music stop" })
	function MUSIC_STOP() {
	}
	
	@Opcode({ id:0x66, format:"s", description:"Plays a sound" })
	function SOUND_PLAY(name) {
	}

	// TODO.
	@Opcode({ id:0x67, format:"", description:"???" })
	function SOUND_STOP() {
	}

	@Opcode({ id:0x70, format:"?", description:"Put text (dialog)" })
	function PUT_TEXT_DIALOG(textBA:ByteArray) {
		if (state.textVisible) {
			
		}
	}

	@Opcode({ id:0x71, format:"221s", description:"Put text (y, x, ?color?, text, ??)" })
	function PUT_TEXT_AT_POSITION(x, y, color, text) {
	}

	// TODO.
	@Opcode({ id:0x72, format:"b", description:"???" })
	function SET_DIALOG_TEXT_VISIBLE(visible:Bool):Void {
		state.textVisible = visible;
	}

	// TODO.
	@Opcode({ id:0x73, format:"1", description:"???" })
	function UNKNOWN_73(v) {
	}

	// TODO.
	@Opcode({ id:0x75, format:"111", description:"???" })
	function UNKNOWN_75(a, b, c) {
	}

	// TODO.
	@Opcode({ id:0x82, format:"22221", description:"????" })
	function TEXT_WND_SET(a, b, c, d, e) {
	}

	// TODO.
	@Opcode({ id:0x83, format:"<2", description:"????" })
	function DELAY_83(done:Void -> Void, time:Int) {
		Timer.delay(done, time * 10);
	}

	// TODO.
	@Opcode({ id:0x84, format:"s1", description:"Interface (0x84)" })
	function INTERFACE2(file, _0) {
	}
	
	// TODO.
	@Opcode({ id:0x85, format:"", description:"" })
	function UNKNOWN_85() {
	}

	// TODO.
	@Opcode({ id:0x86, format:"22", description:"" })
	function SET_PUSH_BUTTON_POSITION(x:Int, y:Int) {
	}

	// TODO.
	@Opcode({ id:0x87, format:"s1", description:"Interface (0x87)" })
	function INTERFACE3(file, _0) {
	}

	@Opcode({ id:0x89, format:"<2", description:"Delay" })
	function DELAY_89(done:Void -> Void, time:Int) {
		Timer.delay(done, time * 10);
	}

	@Opcode({ id:0x8A, format:"", description:"Updates" })
	function UPDATE() {
	}

	@Opcode({ id:0x91, format:"", description:"Return from a CALL" })
	function RETURN_LOCAL() {
		dat.returnLabel();
	}

	// TODO.
	@Opcode({ id:0x92, format:"", description:"???" })
	function RETURN_SCRIPT() {
	}

	@Opcode({ id:0x94, format:"", description:"???" })
	function SET_LS_RAND() {
	}

	@Opcode({ id:0x95, format:"122?", description:"Sets a range of flags" })
	function FLAG_SET_RANGE(type:Int, start:Int, count:Int, left:ByteArray) {
		var value:Int = 0;
		
		if (type == 3) {
			value = left.readUnsignedShort();
		} else {
			value = left.readUnsignedByte();
		}
		
		for (flag in start ... start + count) {
			state.setFlag(type, flag, value);
		}
	}

	@Opcode({ id:0x98, format:"?", description:"Sets a flag" })
	function FLAG_SET(s) {
	}

	// TODO.
	@Opcode({ id:0x99, format:"?", description:"Sets a flag (related)" })
	function JUMP_SET_LSW_ROUTINE(s) {
	}

	// TODO.
	@Opcode({ id:0x9D, format:"2", description:"????" })
	function UNKNOWN_9D(v) {
	}

	@Opcode({ id:0xA6, format:"22", description:"Wait?" })
	function WAIT_MOUSE_CLICK(v0, v1) {
	}

	@Opcode({ id:0xA7, format:"22222", description:"" })
	function JUMP_IF_MOUSE_CLICK(x1, y1, x2, y2, label) {
	}

	// TODO.
	@Opcode({ id:0xAA, format:"2222", description:"????" })
	function DISABLED_SET_AREA_HEIGHT(x1, y1, x2, y2) {
	}

	@Opcode({ id:0xAD, format:"2221", description:"" })
	function JUMP_IF_MOUSE_CLICK_ADV(label_l, label_r, label_miss, count) {
	}
	
	@Opcode({ id:0xAE, format:"2222212", description:"" })
	function JUMP_IF_MOUSE_IN(x1, y1, x2, y2, label, flag_type, flag) {
	}

	@Opcode({ id:0xF0, format:"", description:"" })
	function FLASH_IN() {
	}

	@Opcode({ id:0xF1, format:"", description:"" })
	function FLASH_OUT() {
	}

	@Opcode({ id:0xFF, format:"", description:"Exits the game" })
	function GAME_END() {
		throw("GAME_END");
	}
}
