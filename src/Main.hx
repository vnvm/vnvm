package ;

import common.imaging.BMP;
import common.io.FileStream;
import engines.dividead.DL1;
import engines.dividead.LZ;
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

		/*
		var dl1:DL1 = new DL1();
		var byteArray:ByteArray;
		
		dl1.loadAsync(new FileStream("H:/SG.DL1"), function() {
			dl1.openAndReadAllAsync("I_98.BMP", function(byteArray:ByteArray) {
				var decodedByteArray:ByteArray = LZ.decode(byteArray);
				//File.saveBytes("c:/temp/test.bmp", decodedByteArray);
				addChild(new Bitmap(BMP.decode(decodedByteArray)));
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
