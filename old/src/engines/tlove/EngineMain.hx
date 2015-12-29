package engines.tlove;
import common.display.GameScalerSprite;
import vfs.Stream;
import vfs.SubVirtualFileSystem;
import vfs.VirtualFileSystem;
import flash.display.Bitmap;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class EngineMain extends Sprite
{
	var fs:VirtualFileSystem;
	var gameSprite:Sprite;

	public function new(fs:VirtualFileSystem, script:String, scriptPos:Int = 0) 
	{
		super();
		
		this.fs = SubVirtualFileSystem.fromSubPath(fs, "tlove");
		
		gameSprite = new Sprite();
		addChild(new GameScalerSprite(640, 400, gameSprite));
		
		init(script, scriptPos);
	}
	
	private function init(script:String, scriptPos:Int = 0):Void 
	{
		var game:Game;

		Game.initFromFileSystemAsync(fs, function(game:Game) {
			#if (true)
				gameSprite.addChild(game.sprite);
				game.run(script, scriptPos);
			#else
				game.mrs.getBytesAsync("WINDOW.MRS", function(ba:ByteArray):Void {
					var mrs:MRS = new MRS(ba);
					gameSprite.addChild(new Bitmap(mrs.image.getBimapData32(), PixelSnapping.AUTO, true));
				});
			#end
		});
	}
}