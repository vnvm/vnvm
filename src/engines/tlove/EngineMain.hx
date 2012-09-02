package engines.tlove;
import common.GameScalerSprite;
import common.io.Stream;
import common.io.SubVirtualFileSystem;
import common.io.VirtualFileSystem;
import engines.tlove.mrs.MRS;
import nme.display.Bitmap;
import nme.display.PixelSnapping;
import nme.display.Sprite;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class EngineMain extends Sprite
{
	var fs:VirtualFileSystem;
	var gameSprite:Sprite;

	public function new(fs:VirtualFileSystem) 
	{
		super();
		
		this.fs = SubVirtualFileSystem.fromSubPath(fs, "tlove");
		
		gameSprite = new Sprite();
		addChild(new GameScalerSprite(640, 400, gameSprite));
		
		init();
	}
	
	private function init():Void 
	{
		var game:Game;

		Game.initFromFileSystemAsync(fs, function(game:Game) {
			gameSprite.addChild(game.sprite);
			game.run();
			/*
			game.mrs.getBytesAsync(function("SLIDE_1.MRS", ba:ByteArray):Void {
				var mrs:MRS = new MRS(ba);
				gameSprite.addChild(new Bitmap(mrs.image.getBimapData32(), PixelSnapping.AUTO, true));
			});
			*/
		});
	}
}