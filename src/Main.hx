package ;
import flash.display.PixelSnapping;
import common.GameScalerSprite;
import engines.will.formats.wip.WIP;
import vfs.Stream;
import engines.will.formats.arc.ARC;
import flash.display.Bitmap;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import common.AssetsFileSystem;
import common.GameInput;
import common.StageReference;
import haxe.Log;
import vfs.VirtualFileSystem;
import common.StringEx;
import flash.display.Sprite;
import flash.display.Stage;
import flash.errors.Error;
import flash.events.Event;
import flash.Lib;
import flash.utils.ByteArray;
import promhx.Promise;

/**
 * ...
 * @author
 * @see http://developer.android.com/reference/android/Manifest.permission.html
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

		if (stage != null)
		{
			initOnce();
		} else
		{
			addEventListener(Event.ADDED_TO_STAGE, initOnce);
		}
	}

	private function initOnce(?e)
	{
		removeEventListener(Event.ADDED_TO_STAGE, initOnce);
		if (!initialized)
		{
			initialized = true;
			init(e);
		}
	}

	private function init(e)
	{
		StageReference.stage = this.stage;
		GameInput.init();

/*
		var bitmap = new Bitmap(BitmapSerializer.decode(
			ByteUtils.ArrayToByteArray([
				0xFF, 0xFF, 0, 0,
				0xFF, 0, 0, 0xFF
			]),
			1,
			2,
			"arbg",
			true
		));

		bitmap.scaleX = bitmap.scaleY = 100;

		addChild(bitmap);

		return;
		*/

		fs = AssetsFileSystem.getAssetsFileSystem();

		fs.openAsync('pw/Chip.arc').then(function(stream:Stream)
		{
			ARC.fromStreamAsync(stream).then(function(arc:ARC)
			{
				Log.trace(arc);

/*
				arc.openAsync("PW0006_1.WSC").then(function(wipStream:Stream)
				{
					wipStream.readAllBytesAsync().then(function(data:ByteArray) {
						ByteArrayUtils.rotateBytesInplaceRight(data, 2);
						File.saveBytes("c:/temp/lol.bin", data);
					});
				});
				*/

				arc.openAsync("CG12_12.WIP").then(function(wipStream:Stream)
				{
					WIP.fromStreamAsync(wipStream).then(function(wip:WIP)
					{
						addChild(new GameScalerSprite(800, 600, new Bitmap(wip.get(0).bitmapData, PixelSnapping.AUTO, true)));
						Log.trace('image loaded!');
					});
				});
			});
		});

		return;

		var loadByteArray:ByteArray;
		var fileName:String = "load.txt";
		fs.existsAsync(fileName).then(function(exists:Bool)
		{
			Log.trace('Exists load.txt: ' + exists);
			if (exists)
			{
				fs.openAndReadAllAsync(fileName).then(function(loadByteArray:ByteArray)
				{
					var text:String = StringTools.trim(loadByteArray.readUTFBytes(loadByteArray.length));
					var parts:Array<String> = text.split(':');
					var scriptName:String = null;
					var scriptPos:Int = 0;

					fileName = parts[0];
					if (parts.length >= 1) scriptName = parts[1];
					if (parts.length >= 2) scriptPos = StringEx.parseInt(parts[2], 16);
					loadEngine(fileName, scriptName, scriptPos);
				});
			} else
			{
//loadEngine("dividead", null);
				loadEngine("tlove", null);
			}
		});
	}

	private function loadEngine(name:String, ?scriptName:String, ?scriptPos:Int):Void
	{
		Log.trace('loadEngine: ' + name);
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
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;

		Lib.current.addChild(new Main());
	}

}
