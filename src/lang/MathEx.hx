package lang;
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

	@:noStack static public function _length(x:Float, y:Float):Float
	{
		return Math.sqrt(x * x + y * y);
	}

	@:noStack static public function clamp(v:Float, min:Float, max:Float):Float
	{
		if (v < min) return min;
		if (v > max) return max;
		return v;
	}

	@:noStack static public inline function clampInt(v:Int, min:Int, max:Int):Int
	{
		return (v < min) ? min : ((v > max) ? max : v);
	}

	static public function randomInt(min:Int, max:Int):Int
	{
		return Std.int((Math.random() * (max - min)) + min);
	}

	static public function interpolate(v:Float, aMin:Float, aMax:Float):Float
	{
		return aMin + ((aMax - aMin) * v);
	}

	static public function interpolateDynamic(step:Float, a:Dynamic, b:Dynamic):Float
	{
		return a + ((b - a) * step);
	}

	static public function translateRange(v:Float, aMin:Float, aMax:Float, bMin:Float, bMax:Float):Float
	{
		var aDist:Float = aMax - aMin;
		var bDist:Float = bMax - bMin;
		v = clamp(v, aMin, aMax);
		var v0:Float = (v - aMin) / aDist;
		return (v0 * bDist) + bMin;
	}

	// http://haxe.org/manual/tips_and_tricks#cpp-specific-metadata
	#if cpp @:functionCode("return numerator / denominator;") #end
	@:noStack static public function int_div(numerator:Int, denominator:Int):Int
	{
		return Std.int(numerator / denominator);
	}
}