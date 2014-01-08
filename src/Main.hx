package ;

import flash.display.Bitmap;
import ffmpeg.FFMPEG;
import haxe.io.Bytes;
import haxe.io.BytesData;
import common.ArrayUtils;
import haxe.Log;
import common.ByteArrayUtils;
import sys.io.File;
import flash.text.TextFormat;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import openfl.Assets;
import reflash.display.Stage2;
import common.encoding.Encoding;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import common.assets.AssetsFileSystem;
import common.input.GameInput;
import common.StageReference;
import haxe.Log;
import vfs.VirtualFileSystem;
import lang.StringEx;
import flash.display.Sprite;
import flash.display.Stage;
import flash.errors.Error;
import flash.events.Event;
import flash.Lib;
import flash.utils.ByteArray;

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
		Log.trace(FFMPEG.getVersion());
		var ffmpeg:FFMPEG = new FFMPEG();
		//ffmpeg.openAndPlay("c:/temp/11/iris.dat", function() {
		//ffmpeg.openAndPlay("c:/temp/BS_OP.AVI", function() {
		//ffmpeg.openAndPlay("c:/temp/H264_test1_Talkinghead_mp4_480x360.mp4", function() {
		ffmpeg.openAndPlay("/mnt/sdcard/vnvm/angela.mpg", function() {
		//ffmpeg.openAndPlay("c:/temp/BS_OP.webm", function() {
			Log.trace('completed!');
		});

		addChild(new Bitmap(ffmpeg.bitmapData));
		return;
		*/

		/*
		var mpegVideo = new MpegVideo();
		mpegVideo.loadAndPlayAsync(File.read('c:/temp/anglea.mpg', true)).then(function(e) {
			Log.trace('ENDED!');
		});
		addChild(mpegVideo);

		return;
		*/

		//new AudioStreamSound(MP2Native.createWithStream(File.read("c:/temp/mp2/angela.mp2", true))).play();

		//var data = ByteArrayUtils.BytesToByteArray();
		//var data = File.getBytes("c:/temp/mp2/angela.mp2").getData();

		/*
		var mpeg = new MpegPs(file);
		var audioStream = mpeg.getAudioStream(0);

		new AudioStreamSound(MP2Native.createWithStream(audioStream)).play();

		return;
		*/

		/*
		var data = ByteArrayUtils.BytesToByteArray(File.getBytes("c:/temp/mp2/angela.mp2"));

		var mp2 = new MP2();
		Log.trace(mp2.kjmp2_get_sample_rate(data));
		var pcm = ArrayUtils.array1D(0x100, 0);
		var data_offset = 0;
		for (n in 0 ... 10)
		{
			var offset = mp2.kjmp2_decode_frame(data, 0, pcm);
			//data_offset += offset;
			Log.trace(offset);
			Log.trace(pcm);
		}
		return;
		*/

		/*
		var textField = new TextField();
		textField.defaultTextFormat = new TextFormat("fonts/Anonymous.ttf", 32, 0xFF0000);
		textField.autoSize = TextFieldAutoSize.LEFT;
		textField.text = 'hello';
		addChild(textField);

		Log.trace(Assets.getFont("fonts/Anonymous.ttf"));
		return;
		*/

		//Sandbox.test();
		//return;

		//new CommandLineMain().extractAllImages(); return;

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

