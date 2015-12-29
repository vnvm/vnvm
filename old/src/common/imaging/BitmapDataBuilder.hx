package common.imaging;

import flash.display.BitmapData;
class BitmapDataBuilder
{
	public var bitmapData(default, null):BitmapData;

	private function new(width:Int, height:Int)
	{
		this.bitmapData = new BitmapData(width, height, true, 0x00000000);
	}

	static public function create(width:Int, height:Int):BitmapDataBuilder
	{
		return new BitmapDataBuilder(width, height);
	}

	public function noise():BitmapDataBuilder
	{
		this.bitmapData.noise(0);
		return this;
	}
}
