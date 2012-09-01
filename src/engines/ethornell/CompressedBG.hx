package engines.ethornell;

/**
 * ...
 * @author soywiz
 */

// Class to uncompress "CompressedBG" files.
class CompressedBG {
	// Header for the CompressedBG.
	struct Header {
		char[0x10] magic;
		ushort w, h;
		uint bpp;
		uint[2] _pad0;
		uint data1_len;
		uint data0_val;
		uint data0_len;
		ubyte hash0, hash1;
		ubyte _unknown;
	}
	// Node for the Huffman decompression.
	struct Node {
		uint[6] vv;
		char[] toString() { return format("(%d, %d, %d, %d, %d, %d)", vv[0], vv[1], vv[2], vv[3], vv[4], vv[5]); }
	}
	
	static assert(Header.sizeof == 0x30, "Invalid size for CompressedBG.Header");
	static assert(Node.sizeof   == 24  , "Invalid size for CompressedBG.Node");
	
	Header header;
	ubyte[] data0;
	uint[0x100] table;
	Node[0x1FF] table2;
	ubyte[] data1;
	uint[] data;

	this(char[] name) { this(new BufferedFile(name)); }
	this(Stream s) {
		s.readExact(&header, header.sizeof);
		assert(header.magic == "CompressedBG___\0");
		data0 = cast(ubyte[])s.readString(header.data0_len);
		auto datahf = cast(ubyte[])s.readString(s.size - s.position);

		decode_chunk0(data0, header.data0_val);
		// Check the decoded chunk with a hash.
		assert(check_chunk0(data0, header.hash0, header.hash1));
	
		process_chunk0(data0, table, 0x100);
		int method2_res = method2(table, table2);
		data = new uint[header.w * header.h];
		auto data3 = new ubyte[header.w * header.h * 4];
		
		data1.length = header.data1_len;
		uncompress_huffman(datahf, data1, table2, method2_res);
		uncompress_rle(data1, data3);
		
		unpack_real(data, data3);
	}

	static void decode_chunk0(ubyte[] data, uint hash_val) {
		for (int n = 0; n < data.length; n++) data[n] -= hash_update(hash_val) & 0xFF;
	}
	
	static bool check_chunk0(ubyte[] data, ubyte hash_dl, ubyte hash_bl) {
		ubyte dl = 0, bl = 0;
		foreach (c; data) { dl += c; bl ^= c; }
		return (dl == hash_dl) && (bl == hash_bl);
	}

	static void process_chunk0(ubyte[] data0, uint[] table, int count = 0x100) {
		ubyte *ptr = data0.ptr;
		for (int n = 0; n < count; n++) table[n] = readVariable(ptr);
	}

	static int method2(uint[] table1, Node[] table2) {
		uint sum_of_values = 0;
		Node node;
		
		{ // Verified.
			for (uint n = 0; n < 0x100; n++) {
				with (table2[n]) {
					vv[0] = table1[n] > 0;
					vv[1] = table1[n];
					vv[2] = 0;
					vv[3] =-1;
					vv[4] = n;
					vv[5] = n;
				}
				sum_of_values += table1[n];
				//writefln(table2[n]);
			}
			//writefln(sum_of_values);
			if (sum_of_values == 0) return -1;
			assert(sum_of_values != 0);
		}

		{ // Verified.
			with (node) {
				vv[0] = 0;
				vv[1] = 0;
				vv[2] = 1;
				vv[3] =-1;
				vv[4] =-1;
				vv[5] =-1;
			}
			for (uint n = 0; n < 0x100 - 1; n++) table2[0x100 + n] = node;
			
			//std.file.write("table_out", cast(ubyte[])cast(void[])*(&table2[0..table2.length]));
		}

		uint cnodes = 0x100;
		uint vinfo[2];

		while (1) {
			for (uint m = 0; m < 2; m++) {
				vinfo[m] = -1;

				// Find the node with min_value.
				uint min_value = 0xFFFFFFFF;
				for (uint n = 0; n < cnodes; n++) {
					auto cnode = &table2[n];

					if (cnode.vv[0] && (cnode.vv[1] < min_value)) {
						vinfo[m] = n;
						min_value = cnode.vv[1];
					}
				}

				if (vinfo[m] != -1) {
					with (table2[vinfo[m]]) {
						vv[0] = 0;
						vv[3] = cnodes;
					}
				}
			}
			
			//assert(0 == 1);
			
			with (node) {
				vv[0] = 1;
				vv[1] = ((vinfo[1] != 0xFFFFFFFF) ? table2[vinfo[1]].vv[1] : 0) + table2[vinfo[0]].vv[1];
				vv[2] = 1;
				vv[3] =-1;
				vv[4] = vinfo[0];
				vv[5] = vinfo[1];
			}

			//writefln("node(%03x): ", cnodes, node);
			table2[cnodes++] = node;
			
			if (node.vv[1] == sum_of_values) break;
		}
		
		return cnodes - 1;
	}

	static void uncompress_huffman(ubyte[] src, ubyte[] dst, Node[] nodes, uint method2_res) {
		uint mask = 0x80;
		ubyte *psrc = src.ptr;
		int iter = 0;
		
		for (int n = 0; n < dst.length; n++) {
			uint cvalue = method2_res;

			if (nodes[method2_res].vv[2] == 1) {
				do {
					int bit = !!(*psrc & mask);
					mask >>= 1;

					cvalue = nodes[cvalue].vv[4 + bit];

					if (!mask) {
						psrc++;
						mask = 0x80;
					}
				} while (nodes[cvalue].vv[2] == 1);
			}

			dst[n] = cvalue;
		}
	}

	static void uncompress_rle(ubyte[] src, ref ubyte[] dst) {
		ubyte *psrc = src.ptr;
		ubyte *pdst = dst.ptr;
		ubyte *pslide = src.ptr;
		bool type = false;

		try {
			while (psrc < src.ptr + src.length) {
				uint len = readVariable(psrc);
				// RLE (for byte 00).
				if (type) {
					pdst[0..len] = 0;
				}
				// Copy from stream.
				else {
					pdst[0..len] = psrc[0..len];
					psrc += len;
				}
				pdst += len;
				type = !type;
			}
			dst.length = pdst - dst.ptr;
		} catch (Exception e) {
			throw(e);
		}
	}

	void unpack_real(uint[] output, ubyte[] data0) {
		switch (header.bpp) {
			case 24, 32: unpack_real_24_32(output, data0, header.bpp); break;
			//case 8: break; // Not implemented yet.
			default:
				assert(0, format("Unimplemented BPP %d", header.bpp));
			break;
		}
	}

	void unpack_real_24_32(uint[] output, ubyte[] data0, int bpp = 32) {
		auto out_ptr = output.ptr;
		Color c = Color(0, 0, 0, (bpp == 32) ? 0 : 0xFF);
		ubyte* src = data0.ptr;
		uint*  dst = output.ptr;
		
		Color extract_32() { scope (exit) src += 4; return Color(src[0], src[1], src[2], src[3]); }
		Color extract_24() { scope (exit) src += 3; return Color(src[0], src[1], src[2], 0); }
		
		auto extract = (bpp == 32) ? &extract_32 : &extract_24;
		Color extract_up() { return Color(*(dst - header.w)); }

		for (int x = 0; x < header.w; x++) {
			*dst++ = (c += extract()).v;
		}
		for (int y = 1; y < header.h; y++) {
			*dst++ = (c = (extract_up + extract())).v;
			for (int x = 1; x < header.w; x++) {
				*dst++ = (c = (Color.avg([c, extract_up]) + extract())).v;
			}
		}
	}

	void write_tga(char[] name) { TGA.write32(name, header.w, header.h, data); }
}