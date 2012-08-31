package ;

import common.AssetsFileSystem;
import common.imaging.BMP;
import common.io.FileStream;
import common.io.LocalFileSystem;
import common.io.SubVirtualFileSystem;
import common.io.VirtualFileSystem;
import engines.dividead.DL1;
import engines.dividead.GameState;
import engines.dividead.LZ;
import engines.dividead.SG;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Loader;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;
import nme.utils.ByteArray;
import sys.io.File;

/**
 * ...
 * @author 
 */

class Main extends Sprite 
{
	
	public function new() 
	{
		super();
		#if iphone
		Lib.current.stage.addEventListener(Event.RESIZE, init);
		#else
		addEventListener(Event.ADDED_TO_STAGE, init);
		#end
	}

	private function init(e) 
	{
		// entry point

		var fs:VirtualFileSystem = AssetsFileSystem.getAssetsFileSystem();
		var gameState:GameState;
		
		/*
		GameState.newAsync(SubVirtualFileSystem.fromSubPath(fs, "dividead"), function(gameState:GameState) {
			gameState.sg.openAndReadAllAsync("I_98.BMP", function(byteArray:ByteArray) {
				addChild(new Bitmap(SG.getImage(byteArray)));
			});
		});
		*/
		
		addChild(new engines.brave.EngineMain());
	}
	
	static public function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP_LEFT;
		
		Lib.current.addChild(new Main());
	}
	
}
