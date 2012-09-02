package engines.tlove.script;

class DAT_OP // T_LOVE95.EXE:00409430
{
	var dat:DAT;
	
	public function new(dat:DAT) {
		this.dat = dat;
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

	@Opcode({ id:0x28, format:"2", description:"Jumps to an adress" })
	function JUMP(label) {
	}
	
	@Opcode({ id:0x2B, format:"2", description:"Jumps to an adress" })
	function CALL(label) {
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

	@Opcode({ id:0x33, format:"s1", description:"Loads an image in a buffer" })
	function IMG_LOAD(name, layer_dst) {
	}

	// TODO.
	@Opcode({ id:0x34, format:"", description:"???" })
	function UNKNOWN_34() {
	}

	// TODO.
	@Opcode({ id:0x35, format:"", description:"???" })
	function FADE_OUT() {
	}

	// PUT IMAGE ?, ?, ?, slice_x, slice_y, slice_w, slice_h, ?, put_x, put_y, ?, ?, ?
	@Opcode({ id:0x36, format:"1112222122222", description:"Copy an slice of buffer into another" })
	function IMG_PUT(time, color_key, layer_src, slice_x, slice_y, slice_w, slice_h, layer_dst, put_x = 0, put_y = 0, u1 = 0, u2 = 0, u3 = 0) {
	}

	@Opcode({ id:0x38, format:"s1", description:"Load an animation" })
	function ANIMATION_START(name, n) {
	}

	// TODO.
	@Opcode({ id:0x39, format:"", description:"???" })
	function ANIMATION_STOP() {
	}

	// (4039) 3A: 0A : 0000 0010 0148 01F0 0040(
	@Opcode({ id:0x3A, format:"22222", description:"Fills a rect" })
	function FILL_RECT(_0, x, y, w, h) {
	}

	// TODO.
	@Opcode({ id:0x3C, format:"122", description:"???" })
	function PALETTE_WORK(a, b, c) {
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

	@Opcode({ id:0x53 format="111", description:"Ani play" })
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
	function PUT_TEXT_DIALOG(s) {
	}

	@Opcode({ id:0x71, format:"221s", description:"Put text (y, x, ?color?, text, ??)" })
	function PUT_TEXT_AT_POSITION(x, y, color, text) {
	}

	// TODO.
	@Opcode({ id:0x72, format:"1", description:"???" })
	function SET_TEXT_MODE(v) {
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
	@Opcode({ id:0x83, format:"2", description:"????" })
	function PAUSE_83(v) {
	}

	// TODO.
	@Opcode({ id:0x84, format:"s1", description:"Interface (0x84)" })
	function INTERFACE2(file, _0) {
	}

	// TODO.
	@Opcode({ id:0x86, format:"", description:"" })
	function SET_PUSH_BUTTON_POSITION(file, _0) {
	}

	// TODO.
	@Opcode({ id:0x87, format:"s1", description:"Interface (0x87)" })
	function INTERFACE3(file, _0) {
	}

	@Opcode({ id:0x89, format:"2", description:"Delay" })
	function DELAY(time) {
	}

	@Opcode({ id:0x8A, format:"", description:"Updates" })
	function UPDATE() {
	}

	@Opcode({ id:0x91, format:"", description:"Return from a CALL" })
	function RETURN_LOCAL() {
	}

	// TODO.
	@Opcode({ id:0x92, format:"", description:"???" })
	function RETURN_SCRIPT() {
	}

	@Opcode({ id:0x94, format:"", description:"???" })
	function SET_LS_RAND() {
	}

	@Opcode({ id:0x95, format:"1221", description:"Sets a range of flags" })
	function FLAG_SET_RANGE(flag_type, flag, count, value) {
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
