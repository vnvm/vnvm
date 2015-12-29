package engines.ethornell;

/**
 * ...
 * @author soywiz
 */

struct BitWritter {
	ubyte[] data;
	uint cval; int av_bits = 8;
	static int mask(int bits) { return (1 << bits) - 1; }
	static ubyte reverse(ubyte b) { return ((b * 0x0802LU & 0x22110LU) | (b * 0x8020LU & 0x88440LU)) * 0x10101LU >> 16; }
	version (safebit) {
		void putbit(bool bit) {
			cval |= (bit << --av_bits);
			if (av_bits == 0) finish();
		}
		void write(ulong ins_val, int ins_bits) {
			for (int n = 0; n < ins_bits; n++) {
				bool bit = cast(bool)((ins_val >> (ins_bits - n - 1)) & 1);
				putbit(bit);
			}
		}
	} else {
		void write(ulong ins_val, int ins_bits) {
			//writefln("%s", varbits(ins_val, ins_bits));
			int ins_bits0 = ins_bits;

			while (ins_bits > 0) {
				int bits = min(ins_bits, av_bits);

				uint extract = (ins_val >> (ins_bits0 - bits)) & mask(bits);
				//writefln("  %s", varbits(extract, bits));
				
				cval |= extract << (av_bits - bits);

				ins_val  <<= bits;
				ins_bits -= bits;
				av_bits  -= bits;
				if (av_bits <= 0) finish();
			}
		}
	}
	void finish() {
		if (av_bits == 8) return;
		//writefln("  byte: %08b", cval);
		data   ~= (cval);
		av_bits = 8;
		cval = 0;
		//exit(0);
	}
}