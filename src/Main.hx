package ;
import common.AssetsFileSystem;
import common.GameInput;
import common.StageReference;
import vfs.VirtualFileSystem;
import common.StringEx;
import flash.display.Sprite;
import flash.display.Stage;
import flash.errors.Error;
import flash.events.Event;
import flash.Lib;
import flash.utils.ByteArray;

/**
 * ...
 * @author 
 */

class Main extends Sprite 
{
	var fs:VirtualFileSystem;
	var initialized:Bool = false;
	
	public function new() 
	{
		super();
		
		#if (cpp || neko)
		Stage.setFixedOrientation(Stage.OrientationLandscapeRight);
		#end

		addEventListener(Event.ADDED_TO_STAGE, initOnce);
	}
	
	private function initOnce(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, initOnce);
		if (!initialized) {
			initialized = true;
			init(e);
		}
	}

	private function init(e) 
	{
		StageReference.stage = this.stage;
		GameInput.init();
		
		fs = AssetsFileSystem.getAssetsFileSystem();

		var loadByteArray:ByteArray;
		fs.tryOpenAndReadAllAsync("load.txt", function(loadByteArray:ByteArray) {
			if (loadByteArray == null) {
				loadEngine("dividead", null);
			} else {
				var text:String = StringTools.trim(loadByteArray.readUTFBytes(loadByteArray.length));
				var parts:Array<String> = text.split(':');
				var name:String;
				var scriptName:String = null;
				var scriptPos:Int = 0;
				
				name = parts[0];
				if (parts.length >= 1) scriptName = parts[1];
				if (parts.length >= 2) scriptPos = StringEx.parseInt(parts[2], 16);
				loadEngine(name, scriptName, scriptPos);
			}
		});
	}
	
	private function loadEngine(name:String, ?scriptName:String, ?scriptPos:Int):Void
	{
		switch (name) {
			case "tlove": addChild(new engines.tlove.EngineMain(fs, scriptName, scriptPos));
			case "dividead": addChild(new engines.dividead.EngineMain(fs, scriptName, scriptPos));
			case "brave": addChild(new engines.brave.EngineMain(fs, scriptName));
			case "edelweiss": addChild(new engines.ethornell.EngineMain(fs, scriptName));
			case "yume":
			case "pw": addChild(new engines.will.EngineMain(fs, name, scriptName));
			default: throw(new Error('Invalid engine \'$name\''));
		}
	}
	
	static public function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.align = flash.display.StageAlign.TOP_LEFT;
		
		Lib.current.addChild(new Main());
	}
	
}
