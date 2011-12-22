class DATOP // T_LOVE95.EXE:00409430
{
	</ id=0x00, format="", description="End of file" />
	function EOF() {
		throw("EOF!");
	}

	// TODO.
	</ id=0x16, format="s1", description="Interface (0x16)" />
	function INTERFACE1(file, _0) {
		printf("TODO: 16\n");
	}

	// TODO.
	</ id=0x17, format="1", description="Unknown??" />
	function UNKNOWN_17(v) {
		Screen.frame(60);
		mouse_update();
	}

	// TODO.
	</ id=0x19, format="1s1", description="Set NAME_L" />
	function NAME_L(v, s, _0) {
		printf("NAME_L: %s (%02X)\n", s, v);
	}

	// TODO.
	</ id=0x1B, format="12", description="??" />
	function UNKNOWN_1B(a, b) {
		printf("TODO: 1B (%d, %d)\n", a, b);
	}

	// TODO.
	</ id=0x23, format="111", description="??" />
	function UNKNOWN_23(a, b, c) {
		printf("TODO: 23 (%d, %d, %d)\n", a, b, c);
	}

	// TODO.
	</ id=0x24, format="111", description="??" />
	function UNKNOWN_24(a, b, c) {
		printf("TODO: 24 (%d, %d, %d)\n", a, b, c);
	}

	</ id=0x28, format="2", description="Jumps to an adress" />
	function JUMP(label) {
		if (log_ins) printf("  JUMP(label_%d)\n", label);
		jump_label(label);
		Screen.frame(10000); // REMOVE
	}
	
	</ id=0x2B, format="2", description="Jumps to an adress" />
	function CALL(label) {
		if (log_ins) printf("  CALL(label_%d)\n", label);
		local state = {script=script_name, pos=script.tell()};
		call_stack.push(state);
		printf("STATE PUSH(%s:%d)\n", state.script, state.pos);
		jump_label(label);
	}

	// TODO.
	</ id=0x30, format="", description="???" />
	function UNKNOWN_30() {
		printf("TODO: 30\n");
	}

	// TODO.
	</ id=0x31, format="", description="???" />
	function UNKNOWN_31() {
		printf("TODO: 31\n");
	}

	// TODO.
	</ id=0x32, format="", description="???" />
	function UNKNOWN_32() {
		printf("TODO: 32\n");
	}

	</ id=0x33, format="s1", description="Loads an image in a buffer" />
	function IMG_LOAD(name, layer_dst) {
		if (log_ins) printf("  IMG_LOAD(%s, %d)\n", name, layer_dst);
		local mrs = ::MRS(::pak_mrs[name + ".MRS"]);
		//layers[layer_dst] = mrs.image;
		
		layers[layer_dst].drawBitmap(mrs.image, 0, 0);
		//mrs.image.draw(layers[layer_dst], 0, 0); // OLD
		//layers[layer_dst] = mrs.image;
	}

	// TODO.
	</ id=0x34, format="", description="???" />
	function UNKNOWN_34() {
		printf("TODO: 34\n");
	}

	// TODO.
	</ id=0x35, format="", description="???" />
	function UNKNOWN_35() {
		printf("TODO: 35\n");
	}

	// PUT IMAGE ?, ?, ?, slice_x, slice_y, slice_w, slice_h, ?, put_x, put_y, ?, ?, ?
	</ id=0x36, format="1112222122222", description="Copy an slice of buffer into another" />
	function IMG_PUT(time, color_key, layer_src, slice_x, slice_y, slice_w, slice_h, layer_dst, put_x = 0, put_y = 0, u1 = 0, u2 = 0, u3 = 0) {
		if (log_ins) printf("  IMG_PUT: %d, CK(%d), layers[%d](%d,%d-%d,%d) -> layers[%d](%d,%d) | [%d, %d, %d]\n", time, color_key, layer_src, slice_x, slice_y, slice_w, slice_h, layer_dst, put_x, put_y, u1, u2, u3);
		//print(layers[layer_src].image);
		local src = layers[layer_src].slice(slice_x, slice_y, slice_w, slice_h);
		//layer_dst = 0;
		local dst = layers[layer_dst];
		//src.draw(dst, put_x, put_y); // OLD
		dst.drawBitmap(src, put_x, put_y); // OLD
		
		Screen.flip();
		//Screen.delay(16);
	}

	</ id=0x38, format="s1", description="Load an animation" />
	function ANI_LOAD(name, n) {
		printf("ANI_LOAD(%s)(%d)\n", name, n);
		local mrs = ::MRS(::pak_mrs[name + ".MRS"]);
		current_ani = mrs.anims[n];
	}

	// TODO.
	</ id=0x39, format="", description="???" />
	function UNKNOWN_39() {
		printf("TODO: 39\n");
	}

	// (4039) 3A: 0A : 0000 0010 0148 01F0 0040(
	</ id=0x3A, format="22222", description="Fills a rect" />
	function FILL_RECT(_0, x, y, w, h) {
		local slice = ::screen.slice(x, y, w, h);
		slice.clear([0, 0, 0, 1]);
	}

	// TODO.
	</ id=0x3C, format="122", description="???" />
	function UNKNOWN_3C(a, b, c) {
		printf("TODO: 3C (%d, %d, %d)\n", a, b, c);
	}
	
	// TODO.
	</ id=0x40, format="", description="???" />
	function UNKNOWN_40() {
		printf("TODO: 40\n");
	}

	// TODO.
	</ id=0x41, format="221", description="???" />
	function JUMP_IF_REL(a, b, c) {
		printf("TODO: JUMP_IF_REL: 41: (%d, %d, %d)\n", a, b, c);
	}

	// TODO.
	</ id=0x42, format="12", description="????" />
	function UNKNOWN_42(a, b) {
		printf("TODO: 42 (%d, %d)\n", a, b);
	}

	</ id=0x44, format="1122", description="Jumps conditionally" />
	function JUMP_IF(flag, op, imm, label) {
		local result = false;
		switch (op) {
			case 0: result = (flag_get(2, flag) <= imm); break;
			case 1: result = (flag_get(2, flag) == imm); break;
			case 2: result = (flag_get(2, flag) >= imm); break;
			default:result = (flag_get(2, flag) >= imm); break;
		}
		if (result) jump_label(label);
	}

	// TODO.
	</ id=0x49, format="21", description="???" />
	function UNKNOWN_49(a, b) {
		printf("TODO: UNKNOWN_49: (%d, %d)\n", a, b);
	}

	</ id=0x52, format="s1", description="Loads a script and starts executing it" />
	function SCRIPT(name, _always_0) {
		local state = {script=script_name, pos=script.tell()};
		call_stack.push(state);
		printf("STATE PUSH(%s:%d)\n", state.script, state.pos);

		set_script(format("%s.DAT", name));
	}

	</ id=0x53 format="111", description="Ani play" />
	function ANI_PLAY(y, x, _ff) {
		printf("ANI_PLAY(%d, %d)(%d)\n", x, y, _ff);
		current_ani_info = {x=x, y=y, t=_ff};
		current_ani_time = 0;
		current_ani_last_idx = -1;
	}

	// TODO.
	</ id=0x54, format="212", description="???" />
	function UNKNOWN_54(a, b, c) {
		printf("TODO: 54 (%d, %d, %d)\n", a, b, c);
	}

	</ id=0x61, format="s2", description="Plays a midi file" />
	function MUSIC_PLAY(name, loop) {
		printf("MUSIC_PLAY('%s', %d)\n", name, loop);
	}

	// TODO.
	</ id=0x62, format="", description="???" />
	function UNKNOWN_62() {
		printf("TODO: 62\n");
	}

	</ id=0x63, format="", description="Music stop" />
	function MUSIC_STOP() {
		printf("MUSIC_STOP()\n");
	}
	
	</ id=0x66, format="s", description="Plays a sound" />
	function SE_PLAY(name) {
		printf("SE_PLAY('%s')\n", name);
	}

	// TODO.
	</ id=0x67, format="", description="???" />
	function UNKNOWN_67() {
		printf("TODO: 67\n");
	}

	</ id=0x70, format="?", description="Put text (dialog)" />
	function PUT_TEXT_DIALOG(s) {
		printf("PUT_TEXT\n");
		local v3 = -1, v4 = -1, v5 = -1;
		local text = "";
		try {
			local v0 = s.readn('b'), v1 = s.readn('b'), v2 = s.readn('b');
			if (v2 != 0xFF) {
				v3 = s.readn('b');
				v4 = s.readn('b');
				v5 = s.readn('b');
			}
			while (!s.eos()) text += s.readstringz(-1);
			printf("TEXT(%d, %d)(%d)(%d, %d, %d): %s\n", v0, v1, v2, v3, v4, v5, text);
		} catch (e) {
		}
		font.print(::screen, text, 26, 328, [1, 1, 1, 1]);
		Screen.flip();
		Screen.delay(100);
	}

	</ id=0x71, format="221s", description="Put text (y, x, ?color?, text, ??)" />
	function PUT_TEXT(x, y, color, text) {
		printf("TEXT2: %d, %d, %d, %s\n", x, y, color, text);
		font.print(::screen, text, x, y, [1, 1, 1, 1]);
		Screen.flip();
	}

	// TODO.
	</ id=0x72, format="1", description="???" />
	function UNKNOWN_72(v) {
		printf("TODO: 72 (%d)\n", v);
	}

	// TODO.
	</ id=0x73, format="1", description="???" />
	function UNKNOWN_73(v) {
		printf("TODO: 73 (%d)\n", v);
	}

	// TODO.
	</ id=0x75, format="111", description="???" />
	function UNKNOWN_75(a, b, c) {
		printf("TODO: 75 (%d, %d, %d)\n", a, b, c);
	}

	// TODO.
	</ id=0x82, format="22221", description="????" />
	function UNKNOWN_82(a, b, c, d, e) {
		printf("TODO: 82 (%d, %d, %d, %d, %d)\n", a, b, c, d, e);
	}

	// TODO.
	</ id=0x83, format="2", description="????" />
	function UNKNOWN_83(v) {
		printf("TODO: 83 (%d)\n", v);
	}

	// TODO.
	</ id=0x84, format="s1", description="Interface (0x84)" />
	function INTERFACE2(file, _0) {
	}

	// TODO.
	</ id=0x87, format="s1", description="Interface (0x87)" />
	function INTERFACE3(file, _0) {
	}

	</ id=0x89, format="2", description="Delay" />
	function DELAY(time) {
		//printf("  DELAY: %d\n", time);
		Screen.delay(16 * time);
	}

	</ id=0x8A, format="", description="Updates" />
	function UPDATE() {
		//printf("  UPDATE\n");
		//Screen.flip();
	}

	</ id=0x91, format="", description="Return from a CALL" />
	function RETURN() {
		if (log_ins) printf("  RETURN\n");
		local state = call_stack.pop();
		printf("STATE POP(%s:%d)\n", state.script, state.pos);
		set_script(state.script);
		jump(state.pos);
	}

	// TODO.
	</ id=0x92, format="", description="???" />
	function UNKNOWN_92() {
		printf("TODO: UNKNOWN_92\n");
	}

	</ id=0x95, format="1221", description="Sets a range of flags" />
	function FLAG_SET_RANGE(flag_type, flag, count, value) {
		if (log_ins) printf("  FLAG_SET_RANGE(%d, %d, %d, %d)\n", flag_type, flag, count, value);
		for (local cflag = flag; cflag < flag + count; cflag++) {
			flag_set(flag_type, cflag, value);
		}
	}

	</ id=0x98, format="?", description="Sets a flag" />
	function FLAG_SET(s) {
		local op_pos = 0;
		local lvalue = 0, rvalue = 0;
		local flag = (s.readn('b') << 8) | s.readn('b');
		if (!(flag & 0x8000)) throw("Not a variable in the FLAG_SET instruction?");

		//printf("[");
		while (!s.eos())
		{
			//printf(".");
			local op = s.readn('b');
			if (op == 0x04) break;
			local zvalue = 0;

			if (op == 0x08) {
				op = 0x00;
				zvalue = (s.readn('b') << 8) | s.readn('b');
			} else {
				zvalue = get_value((s.readn('b') << 8) | s.readn('b'));
			}
			
			// rand() % zvalue
			
			if ((op < 0x00) || (op > 0x03))
			{
				printf("Flag: %04X\n", flag);
				throw(format("Unknown Flag set operation 0x%02X", op));
			}

			
			if (op_pos++ & 2) {
				switch (op) {
					case 0x00: rvalue  = zvalue; break; // Add?
					case 0x01: rvalue -= zvalue; break; // Substract?
					case 0x02: rvalue *= zvalue; break; // Multiply?
					case 0x03: try { rvalue /= zvalue; } catch (e) { } break; // Divide?
				}
			} else {
				switch (op) {
					case 0x00: lvalue += zvalue; break; // Add?
					case 0x01: lvalue -= zvalue; break; // Substract?
					case 0x02: lvalue += rvalue * zvalue; rvalue = 0; break; // Multiply?
					case 0x03: try { lvalue += rvalue / zvalue; } catch (e) { } rvalue = 0; break; // Divide?
				}
			}
		}
		//printf("]\n");
		flag_set(0, flag & 0x7FFF, lvalue + rvalue);
	}

	// TODO.
	</ id=0x99, format="?", description="Sets a flag (related)" />
	function FLAG_SET_REL(s) {
		printf("TODO: FLAG_SET_REL\n");
	}

	// TODO.
	</ id=0x9D, format="2", description="????" />
	function UNKNOWN_9D(v) {
		printf("TODO 9D(%d)\n", v);
	}

	</ id=0xA6, format="22", description="Wait?" />
	function WAIT(v0, v1) {
		Screen.flip();
		while (1) {
			if (Screen.input().mouse.b) break;
			next_frame(1000 / 30);
			Screen.frame(30);
		}
	}

	</ id=0xA7, format="22222", description="" />
	function JUMP_MOUSE_IN(x1, y1, x2, y2, label) {
		local mx = mouse.x, my = mouse.y;

		if (mouse.bl && (mx >= x1 && mx < x2 && my >= y1 && my < y2)) {
			jump_label(label);
		}
	}

	// TODO.
	</ id=0xAA, format="2222", description="????" />
	function UNKNOWN_AA(x1, y1, x2, y2) {
		printf("TODO AA(%d, %d)-(%d, %d)\n", x1, y1, x2, y2);
	}

	</ id=0xAD, format="2221", description="" />
	function JUMP_IF_MOUSE_START(label_l, label_r, label_miss, count) {
		mouse_update();
		box_state = {
			label_l = label_l,
			label_r = label_r,
			label_miss = label_miss,
			count_start = count,
			count = count
		};
	}
	
	</ id=0xAE, format="2222212", description="" />
	function JUMP_IF_MOUSE_IN(x1, y1, x2, y2, label, flag_type, flag) {
		local mx = mouse.x, my = mouse.y;

		if (mouse.bl && (mx >= x1 && mx < x2 && my >= y1 && my < y2)) {
			jump_label(label);
			if (log_ins) printf("JUMP_IF_MOUSE_IN (%d,%d)-(%d,%d) : label_%d : flag_type(%d) : flag(%d)\n", x1, y1, x2, y2, label, flag_type, flag);
			return;
		}

		if (--box_state.count <= 0) {
			if (mouse.bl) {
				jump_label(box_state.label_l);
			} else if (mouse.br) {
				jump_label(box_state.label_r);
			} else {
				jump_label(box_state.label_miss);
				box_state.count = box_state.count_start;
			}
			
			Screen.frame(60);
			mouse_update();
		}
	}
	
	</ id=0xFF, format="", description="Exits the game" />
	function GAME_END() {
		throw("GAME_END");
	}
}
