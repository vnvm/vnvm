package common.imaging;

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
	
	static public function add(left:BmpColor, right:BmpColor):BmpColor {
		return new BmpColor(
			(left.r + right.r) & 0xFF,
			(left.g + right.g) & 0xFF,
			(left.b + right.b) & 0xFF,
			(left.a + right.a) & 0xFF
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
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}
	
	static public function fromV(v:Int):BmpColor {
		return new BmpColor(
			(v >> 0) & 0xFF,
			(v >> 8) & 0xFF,
			(v >> 16) & 0xFF,
			(v >> 24) & 0xFF
		);
	}
}
