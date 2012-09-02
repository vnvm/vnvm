package engines.dividead;
import common.AssetsFileSystem;
import common.GameScalerSprite;
import common.io.SubVirtualFileSystem;
import common.io.VirtualFileSystem;
import nme.display.Bitmap;
import nme.display.Sprite;

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
		
		this.fs = fs;
		
		init();
	}
	
	private function init():Void 
	{
		var game:Game;
		
		Game.newAsync(SubVirtualFileSystem.fromSubPath(fs, "dividead"), function(game:Game) {
			var ab:AB = new AB(game);
			addChild(new GameScalerSprite(640, 480, game.gameSprite));
			ab.loadScriptAsync("aastart", function():Void {
				ab.execute();
			});
			/*
			gameState.sg.openAndReadAllAsync("I_98.BMP", function(byteArray:ByteArray) {
				addChild(new Bitmap(SG.getImage(byteArray)));
			});
			*/
		});
	}
}