package engines.tlove;
import common.io.Stream;
import common.io.SubVirtualFileSystem;
import common.io.VirtualFileSystem;
import engines.tlove.mrs.MRS;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class EngineMain extends Sprite
{
	var fs:VirtualFileSystem;

	public function new(fs:VirtualFileSystem) 
	{
		super();
		
		this.fs = SubVirtualFileSystem.fromSubPath(fs, "tlove");
		
		init();
	}
	
	private function init():Void 
	{
		var game:Game;

		Game.initFromFileSystemAsync(fs, function(game:Game) {
			var stream:Stream = game.mrs.get("SLIDE_1.MRS");
			
			stream.readAllBytesAsync(function(ba:ByteArray):Void {
				var mrs:MRS = new MRS(ba);
				addChild(new Bitmap(mrs.image.getBimapData32()));
			});
		});
	}
}