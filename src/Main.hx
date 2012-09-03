package ;
import common.AssetsFileSystem;
import common.GameInput;
import common.io.VirtualFileSystem;
import nme.display.Sprite;
import nme.display.Stage;
import nme.errors.Error;
import nme.events.Event;
import nme.Lib;
import nme.utils.ByteArray;

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
		
		Stage.setFixedOrientation(Stage.OrientationLandscapeRight);
		#if iphone
		Lib.current.stage.addEventListener(Event.RESIZE, initOnce);
		#else
		addEventListener(Event.ADDED_TO_STAGE, initOnce);
		#end
	}
	
	private function initOnce(e) 
	{
		if (!initialized) {
			initialized = true;
			init(e);
		}
	}

	private function init(e) 
	{
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
				var script:String = null;
				name = parts[0];
				if (parts.length > 0) script = parts[1];
				loadEngine(name, script);
			}
		});
	}
	
	private function loadEngine(name:String, script:String):Void
	{
		switch (name) {
			case "tlove": addChild(new engines.tlove.EngineMain(fs, script));
			case "dividead": addChild(new engines.dividead.EngineMain(fs, script));
			case "brave": addChild(new engines.brave.EngineMain(fs, script));
			default: throw(new Error(Std.format("Invalid engine '$name'")));
		}
	}
	
	static public function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP_LEFT;
		
		Lib.current.addChild(new Main());
	}
	
}
