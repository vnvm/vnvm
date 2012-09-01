package engines.ethornell;

/**
 * ...
 * @author soywiz
 */

class Utils 
{
	// Utility macros.
	static int max(int a, int b) { return (a > b) ? a : b; }
	static int min(int a, int b) { return (a < b) ? a : b; }
	static ushort HIWORD(uint   v) { return (v >> 16); }
	static ushort LOWORD(uint   v) { return (v & 0xFFFF); }
	static ubyte  HIBYTE(ushort v) { return (v >> 8); }
	static ubyte  LOBYTE(ushort v) { return (v & 0xFFFF); }

	// Utility functin for the decrypting.
	static uint hash_update(ref uint hash_val) {
		uint eax, ebx, edx, esi, edi;
		edx = (20021 * LOWORD(hash_val));
		eax = (20021 * HIWORD(hash_val)) + (346 * hash_val) + HIWORD(edx);
		hash_val = (LOWORD(eax) << 16) + LOWORD(edx) + 1;
		return eax & 0x7FFF;
	}
	

	// Read a variable value from a pointer.
	static uint readVariable(ref ubyte *ptr) {
		ubyte c; uint v;
		int shift = 0;
		do {
			c = *ptr++;
			v |= (c & 0x7F) << shift;
			shift += 7;
		} while (c & 0x80);
		return v;
	}


	void find_variable_match(ubyte[] s, ubyte[] match, out int pos, out int len, int min_dist = 0) {
		pos = len = 0;
		if (match.length > s.length) match.length = s.length;
		if ((s.length > 0) && (match.length > 0)) {
			int iter_len = s.length - match.length - min_dist;
			for (int n = 0, m = 0; n < iter_len; n++) {
				for (m = 0; m < match.length; m++) {
					//writefln("%d, %d", n, m);
					if (match[m] != s[n + m]) break;
				}
				if (len < m) {
					len = m;
					pos = n;
				}
			}
			pos = iter_len - pos;
		}
	}

	char[] varbits(ulong v, uint bits) {
		if (bits == 0) return "";
		return format(format("%%0%db", bits), v);
	}


}