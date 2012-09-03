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
		this.colors = LangUtils.createArray(function():BmpColor { return { r : 0, g : 0, b : 0, a : 0 }; }, 256);
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

	static public function copy(src:Palette, dst:Palette):Void {
		for (n in 0 ... Std.int(Math.min(src.colors.length, dst.colors.length))) {
			dst.colors[n] = src.colors[n];
		}
	}
}