package engines.ethornell;

/**
 * ...
 * @author soywiz
 */

class BSS {
	static class OP {
		uint ori_pos;
		uint type;
		enum TYPE { INT, STR, PTR };
		int[]    i;
		char[][] s;
		TYPE[]   t;
		static OP opCall(uint type) {
			OP op = new OP;
			op.type = type;
			return op;
		}
		OP ori(int v) { ori_pos = v; return this; }
		OP push(int v   ) { i ~= v; s ~= null; t ~= TYPE.INT; return this; }
		OP push(char[] v) { i ~= 0; s ~= v;    t ~= TYPE.STR; return this; }
		OP pushPTR(int v) { i ~= v; s ~= null; t ~= TYPE.PTR; return this; }
		long length() { return i.length; }
		char[] toString() {
			char[] r;
			if (type == 0x7F) {
				return format("\n%s_%d:", s[0], i[1]);
			}
			switch (type) {
				case 0x0_00: r = "PUSH_INT";  break;
				case 0x0_01: r = "PUSH_PTR";  break;
				case 0x0_03: r = "PUSH_STR";  break;
				case 0x0_3F: r = "STACK";     break;
				case 0x1_40: r = "TEXT_PUT";  break;
				case 0x1_4D: r = "TEXT_SIZE"; break;
				default: r = std.string.format("OP_%03X", type); break;
			}
			r ~= " ";
			for (int n = 0; n < length; n++) {
				if (n != 0) r ~= ", ";
				r ~= (s[n] !is null) ? ("'" ~ s[n] ~ "'") : format("%d", i[n]);
			}
			r ~= "";
			return r;
		}
		int popi() {
			if (i.length <= 0) return 0;
			int r = i[i.length - 1];
			s.length = t.length = i.length = (length - 1);
			return r;
		}
		long size() { return 4 + length * 4; }
		void print() { printf("%s\n", toStringz(toString)); }
	}
	OP[] ops;
	void parse(char[] name) {
		parse(new BufferedFile(name, FileMode.In));
	}
	void parse(Stream s) {
		ubyte[] data = cast(ubyte[])s.readString(s.size - s.position);
		uint* op_ptr, op_start, op_end = cast(uint *)(data.ptr + data.length);
		ops = null;
		
		for (op_start = op_ptr = cast(uint *)data.ptr; op_ptr < cast(uint *)(data.ptr + data.length); op_ptr++) {
			if (op_end !is null) {
				//writefln("%08X: %08X", op_ptr, op_end);
				if (op_ptr >= op_end) break;
			}
			auto op = OP(*op_ptr).ori((op_ptr - op_start) * 4);
			
			int pushInt() {
				int v = cast(int)*(++op_ptr);
				op.push(v);
				return v;
			}

			int pushPtr() {
				int v = cast(int)*(++op_ptr);
				op.pushPTR(v);
				return v;
			}

			char[] pushStr() {
				char *ptr = cast(char *)data.ptr + cast(int)*(++op_ptr);
				if (cast(uint *)ptr < cast(uint *)op_end) op_end = cast(uint *)ptr;

				char[] v = std.string.toString(ptr);
				op.push(v);
				return v;
			}
			
			switch (op.type) {
				case 0x0_00: pushInt(); break; // PUSH_INT
				case 0x0_01: pushPtr(); break; // PUSH_ADDR?
				case 0x0_02: break; // ??
				case 0x0_03: pushStr(); break; // PUSH_STRING
				case 0x0_04: pushInt(); break; // ??
				case 0x0_09: pushInt(); break; // PUSH_??
				case 0x0_19: pushInt(); break; // ??
				/*
				case 0x0_10: pushInt(); pushInt(); break; // ??
				case 0x0_11:
					pushInt();
					int size = pushInt();
					string_ptr = size + (op_ptr - op_start);
					op_end = cast(uint *)((cast(ubyte *)op_ptr) + size);
				break;
				*/
				case 0x0_3F:
					pushInt();
				break;
				case 0x0_7F: { // SCRIPT_LINE
					pushStr();
					pushInt();
				} break;
				case 0x0_F0: break; // SCRIPT_CALL
				case 0x0_1E: break;
				case 0x0_20: break;
				case 0x0_21: pushInt(); pushInt(); break; // UNK_STACK_OP_22
				case 0x0_22: break; // UNK_STACK_OP_22
				case 0x1_80: break; // AUDIO
				case 0x1_4D: break;  // TEXT_SIZE
				case 0x1_40: break; // TEXT_WRITE
				default:
				break;
			}

			ops ~= op;
		}
	}
	ubyte[] serialize() {
		int[char[]] table;
		uint[] ins; char[] str; int str_start;
		foreach (op; ops) str_start += op.size;

		foreach (op; ops) {
			ins ~= op.type;
			for (int n = 0; n < op.length; n++) {
				if (op.s[n] is null) {
					ins ~= op.i[n];
				} else {
					auto s = op.s[n];
					if ((s in table) is null) {
						table[s] = str_start + str.length;
						str ~= s ~ '\0';
					}
					ins ~= table[s];
				}
			}
			//writefln(op);
		}
		return cast(ubyte[])ins ~ cast(ubyte[])str;
	}
	void write(char[] name) {
		scope s = new BufferedFile(name, FileMode.OutNew); write(s); s.close();
	}
	void write(Stream s) {
		s.write(serialize);
	}
	void dump() {
		int pos = 0;
		foreach (k, op; ops) {
			printf("%08d: %s\n", pos, toStringz(op.toString));
			pos += op.size;
		}
	}
	void insert(int pos, OP[] new_ops) {
		ops = ops[0..pos] ~ new_ops ~ ops[pos..ops.length] ;
	}
	void patchStrings(ACME acme) {
		struct PATCH { int pos; OP[] ops; }
		PATCH[] patches;
		int line, line_pos;
		OP[] pushes;
		OP sstack = OP(0);
		int font_width = 22, font_height = 22;
		int last_op_type;
		bool changed_size = false;
		foreach (pos, op; ops) {
			switch (op.type) {
				case 0x7F: // SCRIPT_LINE
					if (last_op_type == 0x1_4D) {
						changed_size = true;
					} else {
						changed_size = false;
					}
					line = op.i[1];
					line_pos = pos + 1;
					sstack = OP(-1);
					pushes = null;
				break;
				case 0x00: sstack.push(op.i[0]); pushes ~= op; break;
				case 0x03: sstack.push(op.s[0]); pushes ~= op; break;
				case 0x3F:
					//writefln(op);
				break;
				case 0x1_40: // TEXT_WRITE
					//writefln("TEXT_WRITE");
					if (acme.has(line)) {
						char[] text = acme[line].text;
						
						// Has title.
						if (sstack.s[1] !is null) {
							auto tt = explode("\n", text, 2);
							auto title = strip(tt[0]); text = (tt.length >= 2) ? tt[1] : "";
							assert(title.length > 2);
							assert(title[0] == '{', format("Line(%d): Invalid start", line));
							assert(title[title.length - 1] == '}');
							title = title[1..title.length - 1];
							//writefln(pushes[1]);
							pushes[1].s[0] = title;
						}
						// Has text.
						if (sstack.s[0] !is null) {
							auto ttext = stripr(text);
							//writefln(pushes[0]);
							pushes[0].s[0] = ttext = ttext.replace("\r", "").replace("\n ", " ").replace(" \n", " ").replace("\n", " ");
							//pushes[0].s[0] = ttext;
							
							int calc_lines = (ttext.length / 42) + 1;

							if ((font_height <= 22) && (font_height >= 19)) {
								int calc_height = 22;
								if (ttext.length <= 44 * 3) {
									calc_height = 22;
								} else if (ttext.length <= 44 * 4) {
									calc_height = 20;
								} else if (ttext.length < 44 * 5) {
									calc_height = 19;
								}
								//int calc_height = 22 - cast(int)(1.1 * (calc_lines - 2));
								//calc_height = max(19, min(calc_height, 22));
								if (calc_height != font_height) {
									// 2, font_width, font_height, 0
									PATCH patch;
									{
										patch.pos = line_pos;
										patch.ops ~= OP(0x00).push(2);
										patch.ops ~= OP(0x00).push(calc_height);
										patch.ops ~= OP(0x00).push(calc_height);
										patch.ops ~= OP(0x00).push(0);
										patch.ops ~= OP(0x3F).push(4);
										patch.ops ~= OP(0x1_4D);
									}
									patches ~= patch;
									font_height = calc_height;
								}
							}
						}
					}
				break;
				case 0x0_22:
					int a = sstack.popi();
					int b = sstack.popi();
					pushes.length = pushes.length - 1;
					sstack.push(a * b);
				break;
				case 0x1_4D:
					//writefln("TEXT_SIZE: %s", sstack);
					font_width  = sstack.i[0];
					font_height = sstack.i[1];
				break;
				default:
				break;
			}
			last_op_type = op.type;
		}
		
		int disp = 0;
		foreach (patch; patches) {
			insert(patch.pos + disp, patch.ops);
			disp += patch.ops.length;
		}
		
		// Fix pointers.
		int size = 0;
		int[int] translate;
		foreach (op; ops) {
			translate[op.ori_pos] = size;
			//writefln("%d, %d", op.ori_pos, size);
			size += op.size;
		}
		int pos = 0;
		foreach (op; ops) {
			pos += op.size;
			//if (op.type == 0x11) op.i[1] = size - pos;
			foreach (k, t; op.t) {
				if (t == OP.TYPE.PTR) {
					op.i[k] = translate[op.i[k]];
					//writefln("Update!");
				}
			}
		}
	}
	
	ACME extract() {
		auto acme = new ACME;
		OP sstack = OP(0);
		int line, line_pos;

		foreach (pos, op; ops) {
			switch (op.type) {
				case 0x7F: // SCRIPT_LINE
					line = op.i[1];
					line_pos = pos + 1;
					sstack = OP(-1);
				break;
				case 0x00: sstack.push(op.i[0]); break;
				case 0x03: sstack.push(op.s[0]); break;
				case 0x1_40: // TEXT_WRITE
					//writefln("TEXT_WRITE");
					char[] r;
					if (sstack.s[1]) r ~= "{" ~ sstack.s[1] ~ "}\n";
					r ~= sstack.s[0];
					acme.add(line, r);
				break;
				default:
				break;
			}
		}

		return acme;
	}
}