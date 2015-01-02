package engines.dividead;
import common.display.GameScalerSprite;
import vfs.SubVirtualFileSystem;
import vfs.VirtualFileSystem;
import flash.display.Sprite;

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