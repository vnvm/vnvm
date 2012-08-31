package engines.dividead;
import common.AssetsFileSystem;
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

	public function new() 
	{
		super();
		
		init();
	}
	
	private function init():Void 
	{
		var fs:VirtualFileSystem = AssetsFileSystem.getAssetsFileSystem();
		var game:Game;
		
		Game.newAsync(SubVirtualFileSystem.fromSubPath(fs, "dividead"), function(game:Game) {
			var ab:AB = new AB(game);
			addChild(new Bitmap(game.front));
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