package common.imaging;
import common.LangUtils;
import nme.display.BitmapData;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class BitmapData8 {
	public var palette:Array<BmpColor>;
	public var data:ByteArray;
	public var width:Int;
	public var height:Int;
	
	private function new(width:Int, height:Int) {
		this.palette = LangUtils.createArray(function():BmpColor { return { r : 0, g : 0, b : 0, a : 0 }; }, 256);
		this.data = new ByteArray();
		for (n in 0 .. width * height) this.data.writeByte(0);
		this.width = width;
		this.height = height;
	}
	
	static public function createNewWithSize(width:Int, height:Int):BitmapData8 {
		return new BitmapData8(width, height);
	}
	
	public function drawToBitmapData(bitmapData:BitmapData):Void {
		//bitmapData.setPixels(
	}
}