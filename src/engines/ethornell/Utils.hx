package engines.ethornell;
import common.Reference;
import common.StringEx;
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
	static public inline function HIWORD(v:Int):Int { return (v >>> 16) & 0xFFFF; }
	static public inline function LOWORD(v:Int):Int { return (v >>> 0) & 0xFFFF;  }
	static public inline function HIBYTE(v:Int):Int { return (v >>> 8) & 0xFF; }
	static public inline function LOBYTE(v:Int):Int { return (v >>> 0) & 0xFF; }

	/**
	 * Utility function for the decrypting.
	 * 
	 * @param	hash_val
	 * @return
	 */
	@:noStack static public function hash_update(hash_val:Reference<Int>):Int {
		var eax:Int64;
		var ebx:Int64;
		var edx:Int64;
		
		//trace(StringEx.sprintf("V:%08X", [hash_val.value]));
		
		edx = Int64.mul(Int64.ofInt(20021), Int64.ofInt(LOWORD(hash_val.value)));
		eax = Int64.mul(Int64.ofInt(20021), Int64.ofInt(HIWORD(hash_val.value)));
		eax = Int64.add(eax, Int64.mul(Int64.ofInt(346), Int64.ofInt(hash_val.value)));
		eax = Int64.add(eax, Int64.ofInt(HIWORD(cast Int64.getLow(edx))));
		hash_val.value = (LOWORD(cast Int64.getLow(eax)) << 16) + LOWORD(cast Int64.getLow(edx)) + 1;
		
		//trace(StringEx.sprintf("D:%08X", [cast Int64.getLow(edx)]));
		//trace(StringEx.sprintf("A:%08X", [cast Int64.getLow(eax)]));
		
		return (cast Int64.getLow(eax)) & 0x7FFF;
	}
	
	/**
	 * Read a variable value from a pointer.
	 * 
	 * @param	ptr
	 * @return
	 */
	static public inline function readVariable(ptr:ByteArray):Int {
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