package engines.dividead.formats;
import common.imaging.format.image.BMP;
import flash.display.BitmapData;
import flash.utils.ByteArray;

class SG
{
	static public function getImage(data:ByteArray):BitmapData
	{
		//return new BitmapData(640, 480);
		return BMP.decode(LZ.decode(data));
	}
}
