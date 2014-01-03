package ;
import common.tween.Tween;
import reflash.display.Stage2;
import flash.display.BitmapData;
import reflash.wgl.WGLTexture;
import flash.display.BitmapData;
import common.BitmapDataUtils;
import reflash.wgl.WGLTextureBase;
import reflash.display.Image2;
import reflash.display.Color;
import reflash.display.Sprite2;
import reflash.display.Sprite2;
import reflash.display.Quad2;
import reflash.display.DrawContext;
import reflash.display.DisplayObject2;
import reflash.wgl.WGLFrameBuffer;
import reflash.wgl.WGLVertexBuffer;
import reflash.wgl.WGLType;
import reflash.wgl.WGLProgram;
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

		var quad = new Quad2(200, 200, Color.create(1, 0, 0)).setPosition(0, 0).setAnchor(0.5, 0.5);
		Stage2.instance.addChild(quad);

		Tween.forTime(4).interpolateTo(quad, {angle: 360, x: 500, y: 500}).animateAsync();

		/*
		var view = new OpenGLView();

		var screen = WGLFrameBuffer.getScreen();
		var test = WGLFrameBuffer.create(512, 512);
		//var projectionMatrix:Matrix3D;
		//var modelViewMatrix:Matrix3D;

		//var drawContext:DrawContext = new DrawContext();

		var sprite = new Sprite2();
		var quad1 = new Quad2(200, 200, Color.create(1, 0, 0)).setPosition(0, 0).setAnchor(0.5, 0.5);

		var bitmapData:BitmapData = new BitmapData(256, 256, true);
		bitmapData.noise(0);
		bitmapData.setPixel32(0, 0, 0xFF0000FF);
		bitmapData.setPixel32(1, 0, 0x00FF00FF);
		bitmapData.setPixel32(0, 1, 0x0000FFFF);
		bitmapData.setPixel32(1, 1, 0x000000FF);

		//BitmapData.noise(0);

		var image = new Image2(WGLTexture.createWithBitmapData(bitmapData)).setPosition(200, 200);

		var zx = 0;

		sprite.addChild(quad1);
		sprite.addChild(image);
		//sprite.addChild(quad2);

		view.render = function(rect:Rectangle)
		{
			sprite.x = 100;
			sprite.y = 100;
			//sprite.scaleY = sprite.scaleX = 0.5;
			//sprite.alpha = 0.8;
			//quad1.alpha = 0.1;

			quad1.angle++;

			test.clear(Color.create(0, 0, 0, 0));
			test.draw(sprite);

			screen.clear(Color.create(8 / 256, 146 / 256, 208 / 256, 1));
			screen.draw(sprite);
			screen.draw(test, 100, 0);
			//screen.draw(new Image2(frameBuffer.texture).setAnchor(0, 0).setPosition(600 - zx, 0));

			zx++;
		};

		addChild(view);
		*/

		return;

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

		/*
		var svg = new SVG(Assets.getText("nme.svg"));
		var shape = new Shape();
		svg.render(shape.graphics);
		addChild(shape);
		*/

		fs = AssetsFileSystem.getAssetsFileSystem();

		//Log.trace(haxe.Serializer.run(new GameState()));

		/*
		WillResourceManager.createFromFileSystemAsync(fs).then(function(willResourceManager:WillResourceManager) {
			var rio = new RIO(willResourceManager);

			rio.loadAsync('PW0001').then(function(e) {
				rio.executeAsync().then(function(e) {
					Log.trace('END!');
				});
			});
		});
		*/

		//return;

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
			case "pw": addChild(new engines.will.EngineMain(fs, name, scriptName, scriptPos));
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
