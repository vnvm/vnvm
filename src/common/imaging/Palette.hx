package common.imaging;
import common.LangUtils;

/**
 * ...
 * @author soywiz
 */

class Palette 
{
	public var colors:Array<BmpColor>;
	
	public function new() {
		this.colors = LangUtils.createArray(function():BmpColor { return new BmpColor(0x00, 0x00, 0x00, 0xFF); }, 256);
	}

	static public function equals(src:Palette, dst:Palette):Bool {
		if (src.colors.length != dst.colors.length) return false;
		for (n in 0 ... src.colors.length) {
			var color1:BmpColor = src.colors[n];
			var color2:BmpColor = dst.colors[n];
			/*
			if (color1.r != color2.r) return false;
			if (color1.g != color2.g) return false;
			if (color1.b != color2.b) return false;
			if (color1.a != color2.a) return false;
			*/
			if (color1 != color2) return false;
		}
		return true;
	}

	public function interpolate(left:Palette, right:Palette, step:Float):Void {
		for (n in 0 ... Std.int(Math.min(this.colors.length, Math.min(left.colors.length, right.colors.length)))) {
			this.colors[n] = BmpColor.interpolate(left.colors[n], right.colors[n], step);
		}
	}
	
	public function clone():Palette {
		var that = new Palette();
		copy(this, that);
		return that;
	}

	static public function copy(src:Palette, dst:Palette):Void {
		for (n in 0 ... Std.int(Math.min(src.colors.length, dst.colors.length))) {
			dst.colors[n] = src.colors[n];
		}
	}
}