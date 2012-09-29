package engines.ethornell;
import common.Reference;
import haxe.Int32;
import haxe.Int64;
import nme.errors.Error;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class Utils 
{
	// Utility macros.
	static public function HIWORD(v:Int):Int
	{
		return (v >>> 16) & 0xFFFF;
	}
	static public function LOWORD(v:Int):Int {
		return (v >>> 0) & 0xFFFF;
	}
	static public function HIBYTE(v:Int):Int {
		return (v >>> 8) & 0xFF;
	}
	static public function LOBYTE(v:Int):Int {
		return (v >>> 0) & 0xFF;
	}

	/**
	 * Utility function for the decrypting.
	 * 
	 * @param	hash_val
	 * @return
	 */
	static public function hash_update(hash_val:Reference<Int>):Int {
		var eax:Int;
		var ebx:Int;
		var edx:Int;
		var esi:Int;
		var edi:Int;
		edx = (20021 * LOWORD(hash_val.value));
		eax = (20021 * HIWORD(hash_val.value)) + (346 * hash_val.value) + HIWORD(edx);
		hash_val.value = (LOWORD(eax) << 16) + LOWORD(edx) + 1;
		return eax & 0x7FFF;
	}
	
	/**
	 * Read a variable value from a pointer.
	 * 
	 * @param	ptr
	 * @return
	 */
	static public function readVariable(ptr:ByteArray):Int {
		var c:Int;
		var v:Int = 0;
		var shift:Int = 0;
		
		do {
			c = ptr.readUnsignedByte();
			v |= (c & 0x7F) << shift;
			shift += 7;
		} while ((c & 0x80) != 0);
		
		return v;
	}

	static public function find_variable_match(s:ByteArray, match:ByteArray, min_dist:Int = 0):PosLen {
		var pos:Int = 0;
		var len:Int = 0;
		var matchLength:Int = match.length;
		
		if (matchLength > s.length) matchLength = s.length;
		
		if ((s.length > 0) && (matchLength > 0))
		{
			var iter_len:Int = s.length - matchLength - min_dist;
			
			for (n in 0 ... iter_len) {
				var foundM:Int = 0;
				
				for (m in 0 ... matchLength) {
					//writefln("%d, %d", n, m);
					if (match[m] != s[n + m]) { foundM = m;  break; }
				}
				
				if (len < foundM) {
					len = foundM;
					pos = n;
				}
			}
			pos = iter_len - pos;
		}
		
		return new PosLen(pos, len);
	}

	static public function varbits(v:Int64, bits:Int):String {
		throw(new Error("varbits not implemented"));
		return "";
		/*
		if (bits == 0) return "";
		return format(format("%%0%db", bits), v);
		*/
	}
}