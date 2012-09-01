package engines.ethornell;

/**
 * ...
 * @author soywiz
 */

class DSC {
	// Header for DSC files.
	struct Header {
		char[0x10] magic;
		uint hash;
		uint usize;
		uint v2;
		uint _pad;

		void check() {
			assert(magic == "DSC FORMAT 1.00\0", format("Not a DSC file"));
			assert(usize <= 0x_3_000_000,      format("Too big uncompressed size '%d'", usize));
		}
	}

	// A node for the huffman tree.
	struct Node {
		union {
			struct {
				uint has_childs;
				uint leaf_value;
				union {
					struct { uint node_left, node_right; }
					uint childs[2];
				}
			}
			uint vv[4];
		}
		char[] toString() { return format("(childs:%08X, leaf:%08X, L:%08X, R:%08X)", (vv[0]), (vv[1]), (vv[2]), (vv[3])); }
	}

	// Check the sizes for the class structs.
	static assert (Header.sizeof == 0x20, "Invalid size for DSC.Header");
	static assert (Node.sizeof   == 4*4 , "Invalid size for DSC.Node");

	Header header;
	ubyte[] data;
	
	this(char[] name) { this(new BufferedFile(name)); }

	this(Stream s) {
		s.readExact(&header, header.sizeof);
		header.check();

		scope src = new ubyte[s.size - s.position]; s.read(src);
		Node[0x400] nodes;
		data = new ubyte[header.usize];

		// Decrypt and initialize the huffman tree.
		CompressionInit(header.hash, src, nodes);
		// Decompress the data using that tree.
		CompressionDo(src[0x200..src.length], data, nodes);
	}

	// Initializes the huffman tree.
	static void CompressionInit(uint hash, ubyte[] src, Node[] nodes)
		// Input asserts.
		in {
			assert(src.length >= 0x200);
		}
		// Output asserts.
		out {
		}
		body {{
			scope uint[0x200] buffer;
			scope uint[0x400] vector0;
			int buffer_len = 0;
			
			// Decrypt the huffman header.
			for (int n = 0; n < buffer.length; n++) {
				ubyte v = src[n] - cast(ubyte)hash_update(hash);
				//src[n] = v;
				if (v) buffer[buffer_len++] = (v << 16) + n;
			}
			//writefln(src[0x000..0x100]); writefln(src[0x100..0x200]);

			// Sort the used slice of the buffer.
			buffer[0..buffer_len].sort;
			
			uint toggle = 0, cnt0_a = 0, nn = 0, value_set = 1, dec0 = 1;
			vector0[0] = 0;
			uint* v13 = vector0.ptr;

			for (int buffer_cur = 0; buffer_cur < buffer_len - 1; nn++) {
				auto vector0_ptr = &vector0[toggle ^= 0x200];
				auto group_count = 0;
				auto vector0_ptr_init = vector0_ptr;
				
				for ( ;nn == HIWORD(buffer[buffer_cur]); buffer_cur++, v13++, group_count++ ) {
					nodes[*v13].has_childs = false;
					nodes[*v13].leaf_value = buffer[buffer_cur + 0] & 0x1FF;
				}
				
				auto v18 = 2 * (dec0 - group_count);
				if ( group_count < dec0 ) {
					dec0 = (dec0 - group_count);
					for (int dd = 0; dd < dec0; dd++) {
						nodes[*v13].has_childs = true;
						for (int m = 0; m < 2; m++) {
							*vector0_ptr++ = nodes[*v13].childs[m] = value_set;
							value_set++;
						}
						v13++;
					}
				}
				dec0 = v18;
				v13 = vector0_ptr_init;
			}
		}
	}

	static void CompressionDo(ubyte[] src, ubyte[] dst, Node[] nodes) {
		//uint v2 = header.v2;

		uint bits = 0, nbits = 0;
		auto src_ptr = src.ptr, dst_ptr = dst.ptr;
		auto src_end = src.ptr + src.length, dst_end = dst.ptr + dst.length;
		
		//writefln("--------------------");

		// Check the input and output pointers.
		while ((dst_ptr < dst_end) && (src_ptr < src_end)) {
			uint nentry = 0;

			// Look over the tree.
			for (; nodes[nentry].has_childs; nbits--, bits = (bits << 1) & 0xFF) {
				// No bits left. Let's extract 8 bits more.
				if (!nbits) {
					nbits = 8;
					bits = *src_ptr++;
				}
				//writef("%b", (bits >> 7) & 1);
				nentry = nodes[nentry].childs[(bits >> 7) & 1];
			}
			//writefln();

			// We are in a leaf.
			ushort info = LOWORD(nodes[nentry].leaf_value);

			// Compressed chunk.
			if (HIBYTE(info) == 1) {
				auto cvalue = bits >> (8 - nbits);
				auto nbits2 = nbits;
				if (nbits < 12) {
					auto bytes = ((11 - nbits) >> 3) + 1;
					nbits2 = nbits;
					while (bytes--) {
						cvalue = *src_ptr++ + (cvalue << 8);
						nbits2 += 8;
					}
				}
				nbits = nbits2 - 12;
				bits = LOBYTE(cvalue << (8 - (nbits2 - 12)));

				int offset = (cvalue >> (nbits2 - 12)) + 2;
				auto ring_ptr = dst_ptr - offset;
				uint count = LOBYTE(info) + 2;
				
				//writefln("LZ(%d, %d)", -offset, count);

				assert((ring_ptr >= dst.ptr) && (ring_ptr + count < dst_end), "Invalid reference pointer");
				//assert((dst_ptr + count > dst.ptr + dst.length), "Buffer overrun");

				// Copy byte to byte to avoid overlapping issues.
				while (count--) *dst_ptr++ = *ring_ptr++;
			}
			// Uncompressed byte.
			else {
				//writefln("BYTE(%02X)", LOBYTE(info));
				*dst_ptr++ = LOBYTE(info);
			}
		}
		try {
			//assert(dst_ptr == dst_end, "Not written all the bytes to the output buffer");
			assert(src_ptr == src_end, "Not readed all the bytes from the input buffer");
		} catch (Exception e) {
			writefln(e);
		}
	}

	// Allow storing the data in a stream.
	void save(char[] name) { std.file.write(name, data); }
}