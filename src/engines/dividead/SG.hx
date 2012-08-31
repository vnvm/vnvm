package engines.dividead;
import common.imaging.BMP;
import nme.display.BitmapData;
import nme.utils.ByteArray;

class SG
{
	static public function get(data:ByteArray):BitmapData
	{
		return BMP.decode(LZ.decode(data));
	}
}
