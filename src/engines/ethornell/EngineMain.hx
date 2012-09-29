package engines.ethornell;
import common.BitmapDataUtils;
import common.io.VirtualFileSystem;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class EngineMain extends Sprite
{

	public function new(fs:VirtualFileSystem, script:String) 
	{
		super();
		
		var data:ByteArray;
		fs.openAndReadAllAsync("edelweiss/housou_jikoa_n", function(data:ByteArray) {
			data.position = 0;
			var compressedBG:CompressedBG = new CompressedBG(data);
			addChild(new Bitmap(compressedBG.data, null, true));
		});
	}
	
}