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
	
	static public function copy(src:Palette, dst:Palette):Void {
		for (n in 0 ... 256) {
			dst.colors[n] = src.colors[n];
		}
	}
}