package common;
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author 
 */

class MathEx 
{

	public function new() 
	{
		
	}

	static public function _length(x:Float, y:Float):Float {
		return Math.sqrt(x * x + y * y);
	}

	static public function clamp(v:Float, min:Float, max:Float):Float {
		if (v < min) return min;
		if (v > max) return max;
		return v;
	}

	static public function clampInt(v:Int, min:Int, max:Int):Int {
		if (v < min) return min;
		if (v > max) return max;
		return v;
	}

	static public function randomInt(min:Int, max:Int):Int {
		return Std.int((Math.random() * (max - min)) + min);
	}

	static public function interpolate(v:Float, aMin:Float, aMax:Float, bMin:Float, bMax:Float):Float {
		var aDist:Float = aMax - aMin;
		var bDist:Float = bMax - bMin;
		v = clamp(v, aMin, aMax);
		var v0:Float = (v - aMin) / aDist;
		return (v0 * bDist) + bMin;
	}

	#if cpp @:functionCode("return numerator / denominator;") #end
	@:noStack static inline public function int_div(numerator:Int, denominator:Int):Int
	{
		return Std.int(numerator / denominator);
	}
	
	/**
	 * Divide the first integer expression by the second constant integer value.
	 * It will just work with numerator being and unsigned short value (0x0000-0xFFFF)
	 * 
	 * @param	numerator     Unsigned short numerator value
	 * @param	denominator   Constant denominator value
	 * @return
	 */
	macro static public function fastUintConstDivShort(numerator:Expr, denominator:Int):Expr {
		var result = _magicu2_bits(denominator, 16);
		
		var mult:Expr = { expr : EConst(CInt(Std.string(result.magic))), pos : Context.currentPos() };
		var shift:Expr = { expr : EConst(CInt(Std.string(result.shift))), pos : Context.currentPos() };
		var mult2:Expr = { expr : EBinop(OpMult, numerator, mult), pos : Context.currentPos() };
		var combined:Expr = { expr : EBinop(OpUShr, mult2, shift), pos : Context.currentPos() };
		
		return combined;
	}
	
	/**
	 * 
	 * @param	d
	 * @param	bits
	 * @return
	 * 
	 * @see http://www.hackersdelight.org/magic.htm
	 * @see http://research.swtch.com/divmult
	 */
	static private inline function _magicu2_bits(d:Int, bits:Int):Dynamic {
		var mask2:Int = ((1 << (bits - 1)));
		var mask:Int = ((1 << (bits - 1)) - 1);
		var p:Int;
		var p32:Int = 0, q:Int, r:Int, delta:Int;
		var add:Int = 0;             // Initialize "add" indicator.
		p = bits - 1;                 // Initialize p.
		q = Std.int(mask / d);       // Initialize q = (2**p - 1)/d.
		r = mask - q*d;   // Init. r = rem(2**p - 1, d).
		do {
			p = p + 1;
			if (p == bits) {
				p32 = 1;     // Set p32 = 2**(p-32).
			}
			else {
				p32 = 2 * p32;
			}
			if (r + 1 >= d - r) {
				if (q >= mask) add = 1;
				q = 2*q + 1;           // Update q.
				r = 2*r + 1 - d;       // Update r.
			}
			else {
				if (q >= mask2) add = 1;
				q = 2*q;
				r = 2*r + 1;
			}
			delta = d - 1 - r;
		} while (p < (bits * 2) && p32 < delta);
		
		return {
			magic : q + 1,
			shift : p,
			add : add,
		};
	}
}