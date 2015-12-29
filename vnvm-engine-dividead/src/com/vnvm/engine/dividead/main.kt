package com.vnvm.engine.dividead

import com.vnvm.common.async.EventLoop
import com.vnvm.common.io.LocalVirtualFileSystem

/*
class EngineMain extends Sprite {
	var fs:VirtualFileSystem;

	public function new(fs:VirtualFileSystem, ?scriptName:String, ?scriptPos:Int) {
		super();

		this.fs = fs;

		init(scriptName, scriptPos);
	}

	private function init(?scriptName:String, ?scriptPos:Int):Void {
		if (scriptName == null) scriptName = 'aastart';
		if (scriptPos == null) scriptPos = 0;

		var game:Game;

		Game.newAsync(SubVirtualFileSystem.fromSubPath(fs, "dividead")).then(function(game:Game) {
			var ab:AB = new AB(game);
			addChild(new GameScalerSprite(640, 480, game.gameSprite));
			ab.loadScriptAsync(scriptName, scriptPos).then(function(success:Bool):Void {
				ab.executeAsync();
			});
			/*
						gameState.sg.openAndReadAllAsync("I_98.BMP", function(byteArray:ByteArray) {
							addChild(new Bitmap(SG.getImage(byteArray)));
						});
						*/
		});
	}
}
*/

object DivideadMain {
	@JvmStatic fun main(args: Array<String>) {
		EventLoop.runAndWait {
			var fs = LocalVirtualFileSystem("assets")
			val scriptName = "aastart"
			val scriptPos = 0
			Game.newAsync(fs["dividead"]).then { game ->
				var ab = AB(game);
				//addChild(new GameScalerSprite(640, 480, game.gameSprite));
				ab.loadScriptAsync(scriptName, scriptPos).then { success ->
					ab.executeAsync();
				}
			}
		}
	}
}