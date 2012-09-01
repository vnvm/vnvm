package engines.ethornell;

/**
 * ...
 * @author soywiz
 */

class GPD 
{

	ubyte[] lz_decompress(ubyte[] bin) {
		struct LZ_HEAD {
			char[4] magic; // '  ZL'
			uint lout;
			uint lin;
		} LZ_HEAD* h = cast(LZ_HEAD*)bin.ptr;
		
		assert(h.magic == "  ZL", "Not LZ data");
		assert(bin.length >= h.lin + 0x10);
		
		ubyte[] bout = new ubyte[h.lout - 2];
		
		ubyte* i = bin.ptr + 0x10, ie = bin.ptr + 0x10 + h.lin, o = bout.ptr, oe = bout.ptr + bout.length;
		
		try {
			while (i < ie) {
				uint fields = cast(uint)(*(i++)) | (1 << 8);
				for (; !(fields & (1 << 16)); fields <<= 1) {
					if (i >= ie) break;
					//if (o >= oe) return;
					// Uncompressed
					if (fields & 0x80) {
						*(o++) = *(i++);
						//writefln("  %02X", *(o - 1));
					}
					// Compressed
					else {
						ushort z = *(cast(ushort *)i);
						uint lz_len = ((z >> 0) & 0x00F) + 2;
						uint lz_off = ((z >> 4) & 0xFFF) + 1;
						//writefln("%08X", o - bout.ptr);
						//writefln("%d, %d", lz_off, lz_len);
						while (lz_len--) *(o++) = *(o - lz_off);
						i += 2;
					}
				}
			}
		} catch (Exception e) {
			writefln("ERROR: %s at (%d, %d)", e.toString, i - (bin.ptr + 0x10), o - bout.ptr);
		}
		
		//writefln("end");
		
		//write("lol.dat", bout);
		
		return bout;
	}

	Image gpd_extract(ubyte[] data) {
		struct GPD_HEAD {
			char[4] magic; // ' DPG'
			int _ver;
			int unk1;
			int width;
			int height;
			int bpp;
		} GPD_HEAD* h = cast(GPD_HEAD*)(data.ptr);

		assert(h.magic == " DPG", "Not GPD data");
		
		auto i = new Image(h.width, h.height, h.bpp);
		i.setPalette(data[0x40..0x440]);
		i.setData(lz_decompress(data[0x40 + (h.bpp == 8) * 0x400..data.length]));
		delete data;
		return i;
	}

	void gpd_save(char[] fin, char[] fout) {
		auto i = gpd_extract(cast(ubyte[])read(fin));
		i.save(fout);
		delete i.data; i.data = null;
		delete i;
	}

	void gpd_save(char[] fin) {
		gpd_save(fin, fin ~ ".tga");
	}

	bool mkdir2(char[] name) { try { mkdir(name); return true; } catch { return false; } }

	void fcap_extract(char[] pname) {
		struct CAPF_HEAD {
			char[4] magic; // 'CAPF'
			int _ver;
			int start;
			int count;
		} CAPF_HEAD h;
		Stream s = new BufferedFile(pname ~ ".pac");
		s.readExact(&h, h.sizeof);
		s.position = 0x20;
		
		char[] path;
		mkdir2("extract/");
		mkdir2(path = "extract/" ~ pname);
		
		for (int n = 0; n < h.count; n++) {
			uint pos, len;
			s.read(pos); s.read(len);
			char[] fname = split(s.readString(0x20), "\0")[0];
			char[] ffname = path ~ "/" ~ fname;
			writefln("%s...", fname);
			if (std.file.exists(ffname)) continue;
			auto zs = new SliceStream(s, pos, pos + len);
			ubyte[] data = new ubyte[len];
			zs.read(data);
			write(ffname, data);
			delete zs;
			delete data;
		}
		s.close();
	}

}