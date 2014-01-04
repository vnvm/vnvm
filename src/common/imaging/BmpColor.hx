package common.imaging;
import lang.MathEx;

/**
 * ...
 * @author soywiz
 */

class BmpColor
{
	public var r:Int;
	public var g:Int;
	public var b:Int;
	public var a:Int;
	
	public function getV():Int {
		return (
			(r << 0) |
			(g << 8) |
			(b << 16) |
			(a << 24)
		);
	}

	public function getARGB():Int {
		return (
			(a << 0) |
			(r << 8) |
			(g << 16) |
			(b << 24)
		);
	}
	
	public function getPixel32():Int {
		#if flash
		return (
			((a & 0xFF) << 24) |
			((r & 0xFF) << 16) |
			((g & 0xFF) <<  8) |
			((b & 0xFF) <<  0)
		);
		#else
		return (
			((b & 0xFF) << 24) |
			((g & 0xFF) << 16) |
			((r & 0xFF) <<  8) |
			((a & 0xFF) <<  0)
		);
		#end
	}

	static public function add(left:BmpColor, right:BmpColor):BmpColor {
		return new BmpColor(
			(left.r + right.r) & 0xFF,
			(left.g + right.g) & 0xFF,
			(left.b + right.b) & 0xFF,
			(left.a + right.a) & 0xFF
		);
	}
	
	static public function interpolate(left:BmpColor, right:BmpColor, step:Float):BmpColor {
		var step_l = MathEx.clamp(step, 0, 1);
		var step_r = 1.0 - step_l;
		return new BmpColor(
			(Std.int(left.r * step_l + right.r * step_r)) & 0xFF,
			(Std.int(left.g * step_l + right.g * step_r)) & 0xFF,
			(Std.int(left.b * step_l + right.b * step_r)) & 0xFF,
			(Std.int(left.a * step_l + right.a * step_r)) & 0xFF
		);
	}
	
	static public function avg(left:BmpColor, right:BmpColor):BmpColor {
		return new BmpColor(
			((left.r + right.r) >> 1) & 0xFF,
			((left.g + right.g) >> 1) & 0xFF,
			((left.b + right.b) >> 1) & 0xFF,
			((left.a + right.a) >> 1) & 0xFF
		);
	}
	
	public function new(r:Int, g:Int, b:Int, a:Int) {
		this.r = r & 0xFF;
		this.g = g & 0xFF;
		this.b = b & 0xFF;
		this.a = a & 0xFF;
	}
	
	static public function fromV(v:Int):BmpColor {
		return new BmpColor(
			(v >> 0) & 0xFF,
			(v >> 8) & 0xFF,
			(v >> 16) & 0xFF,
			(v >> 24) & 0xFF
		);
	}
	
	static inline private function fromColors(v:Int, r:Int, g:Int, b:Int, a:Int):BmpColor {
		return new BmpColor(
			(v >> r) & 0xFF,
			(v >> g) & 0xFF,
			(v >> b) & 0xFF,
			(v >> a) & 0xFF
		);
	}
	
	static public function fromARGB(v:Int):BmpColor {
		return fromColors(v, 8, 16, 24, 0);
	}
	
	public function toString():String {
		return "BmpColor(" + r + "," + g + "," + b + "," + a + ")";
	}
}
