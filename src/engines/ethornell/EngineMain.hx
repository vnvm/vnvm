package engines.ethornell;
import common.BitmapDataUtils;
import vfs.SubVirtualFileSystem;
import vfs.VirtualFileSystem;
import vfs.VirtualFileSystemBase;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.utils.ByteArray;
//import sys.io.File;

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
		//01_dou_tuu_l
		
		var arc:ARC;
		var data:ByteArray;
		fs = SubVirtualFileSystem.fromSubPath(fs, "edelweiss");
		ARC.openAsyncFromFileSystem(fs, "data02000.arc", function(arc:ARC):Void {
			arc.tableLookup.get("tik_jik_sit").readAsync(function(data:ByteArray):Void {
				//File.saveBytes("c:/temp/dump.bin", data);
				data.position = 0;
				var compressedBG:CompressedBG = new CompressedBG(data);
				addChild(new Bitmap(compressedBG.data, null, true));
			});
		});
	}
	
}