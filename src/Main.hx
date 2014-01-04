package ;
import engines.will.WIPLayer;
import common.imaging.BitmapDataBuilder;
import reflash.display.HtmlColors;
import vfs.SubVirtualFileSystem;
import common.tween.Easing;
import common.tween.Tween;
import reflash.display.Stage2;
import flash.display.BitmapData;
import reflash.gl.wgl.WGLTexture;
import flash.display.BitmapData;
import common.BitmapDataUtils;
import reflash.gl.wgl.WGLTextureBase;
import reflash.display.Image2;
import reflash.display.Color2;
import reflash.display.Sprite2;
import reflash.display.Sprite2;
import reflash.display.Quad2;
import reflash.display.DrawContext;
import reflash.display.DisplayObject2;
import reflash.gl.wgl.WGLFrameBuffer;
import reflash.gl.wgl.WGLVertexBuffer;
import reflash.gl.wgl.WGLType;
import reflash.gl.wgl.WGLProgram;
import flash.geom.Matrix3D;
import openfl.utils.Float32Array;
import flash.geom.Rectangle;
import openfl.display.OpenGLView;
import openfl.gl.GL;
import common.encoding.Encoding;
import flash.display.Shape;
import engines.will.RIO;
import engines.will.WillResourceManager;
import haxe.Serializer;
import engines.tlove.GameState;
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

		Stage2.createAndInitializeStage2(stage);

		/*
		var texture1 = WGLTexture.fromBitmapData(BitmapDataBuilder.create(512, 512).noise().bitmapData);
		var buffer1 = WGLFrameBuffer.create(512, 512).clear(HtmlColors.red).draw(new Image2(texture1)).finish();

		//var buffer1 = WGLFrameBuffer.create(512, 512).clear(HtmlColors.black).draw(new Image2(texture1)).finish();
		//var buffer2 = WGLFrameBuffer.create(512, 512).clear(HtmlColors.black).draw(new Image2(texture2)).finish();


		//Stage2.instance.addChild(new Image2(texture1));
		Stage2.instance.addChild(new Image2(buffer1.texture));
		return;
		*/


		/*
		var bitmapData = new BitmapData(512, 512); bitmapData.noise(0);
		var test = WGLFrameBuffer.create(512, 512);
		test.clear(HtmlColors.red);
		test.draw(new Image2(WGLTexture.createWithBitmapData(bitmapData)));
		//test.drawElement();
		//test.draw(new Quad2(200, 200, HtmlColors.red));
		Stage2.instance.addChild(new Image2(test.texture).setAnchor(0, 0));
		return;
		*/

		/*
		var view = new OpenGLView();
		var screen = WGLFrameBuffer.getScreen();
		var test = WGLFrameBuffer.create(512, 512);
		test.clear(HtmlColors.blue);

		var once = true;

		view.render = function(rect:Rectangle) {
			screen.clear(HtmlColors.red);
			screen.draw(test);
		};
		this.stage.addChild(view);
		return;
		*/


		fs = AssetsFileSystem.getAssetsFileSystem();

		//Log.trace(haxe.Serializer.run(new GameState()));

		/*
		WillResourceManager.createFromFileSystemAsync(SubVirtualFileSystem.fromSubPath(fs, "pw")).then(function(willResourceManager:WillResourceManager) {
			//
			//var rio = new RIO(willResourceManager);
//
			//rio.loadAsync('PW0001').then(function(e) {
			//	rio.executeAsync().then(function(e) {
			//		Log.trace('END!');
			//	});
			//});
			//
			//
			//willResourceManager.getWipWithMaskAsync("CLKWAIT").then(function(wip:WIP) {
			//	var bitmapData = wip.get(0).bitmapData;
			//	Stage2.instance.addChild(new Image2(WGLTexture.fromBitmapData(bitmapData)));
			//});
			//

			willResourceManager.getWipWithMaskAsync("WINBASE0").then(function(wip:WIP) {
				Stage2.instance.addChild(WIPLayer.fromWIP(wip));
			});

		});

		return;
		*/

		var loadByteArray:ByteArray;
		var fileName:String = "load.txt";
		fs.existsAsync(fileName).then(function(exists:Bool)
		{
			Log.trace('Exists load.txt: ' + exists);
			if (exists)
			{
				fs.openAndReadAllAsync(fileName).then(function(loadByteArray:ByteArray)
				{
					var text:String = StringTools.trim(Encoding.UTF8.getString(loadByteArray));
					for (line in text.split('\n'))
					{
						line = StringTools.trim(line);
						Log.trace('load line: $line');
						if (line.substr(0, 1) == '#') continue;

						var parts:Array<String> = line.split(':');
						var scriptName:String = null;
						var scriptPos:Int = 0;

						fileName = parts[0];
						if (parts.length >= 1) scriptName = parts[1];
						if (parts.length >= 2) scriptPos = StringEx.parseInt(parts[2], 16);
						loadEngine(fileName, scriptName, scriptPos);

						return;
					}
				});
			} else
			{
				loadEngine("dividead", null);
				//loadEngine("tlove", null);
			}
		});
	}

	private function loadEngine(name:String, ?scriptName:String, ?scriptPos:Int):Void
	{
		Log.trace('loadEngine: $name:$scriptName:$scriptPos');
		switch (name) {
			case "tlove": addChild(new engines.tlove.EngineMain(fs, scriptName, scriptPos));
			case "dividead": addChild(new engines.dividead.EngineMain(fs, scriptName, scriptPos));
			case "brave": addChild(new engines.brave.EngineMain(fs, scriptName));
			case "edelweiss": addChild(new engines.ethornell.EngineMain(fs, scriptName));
			case "yume":
			case "pw":
				Stage2.instance.addChild(new engines.will.EngineMain(fs, name, scriptName, scriptPos));
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
