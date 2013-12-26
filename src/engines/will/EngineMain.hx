package engines.will;

import common.GameInput;
import flash.display.DisplayObject;
import engines.will.formats.anm.TBL;
import sys.io.File;
import flash.display.PNGEncoderOptions;
import engines.will.formats.anm.ANM;
import flash.utils.RegExp;
import flash.text.TextFormat;
import flash.text.TextField;
import flash.geom.Rectangle;
import common.geom.Anchor;
import flash.errors.Error;
import common.tween.Tween;
import common.Animation;
import flash.geom.ColorTransform;
import flash.display.BitmapDataChannel;
import flash.geom.Point;
import common.Timer2;
import flash.display.BitmapData;
import common.PathUtils;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.media.Sound;
import flash.display.PixelSnapping;
import engines.will.formats.wip.WIP;
import promhx.Promise;
import haxe.Log;
import common.GameScalerSprite;
import common.BitmapDataUtils;
import vfs.SubVirtualFileSystem;
import vfs.VirtualFileSystem;
import vfs.VirtualFileSystemBase;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.utils.ByteArray;
//import sys.io.File;

/**
 * ...
 * @author soywiz
 */

class EngineMain extends Sprite implements IScene
{
	private var gameSprite:Sprite;
	private var fs:VirtualFileSystem;
	private var initScript:String;
	private var initScriptPos:Int;
	private var willResourceManager:WillResourceManager;

	public function getMaskValueAt(point:Point):Int
	{
		var x = Std.int(point.x);
		var y = Std.int(point.y);

		if (tblMask != null) {
			if (x < 0 || y < 0 || x >= tblMask.width || y >= tblMask.height) return 0;
			return tblMask.getPixel(x, y) & 0xFF;
		}
		return 0;
	}

	public function getMousePosition():Point
	{
		return gameSprite.globalToLocal(GameInput.mouseCurrent);
	}

	public function getGameSprite():Sprite
	{
		return gameSprite;
	}

	private var previousBitmap:Bitmap;
	private var currentBitmap:Bitmap;

	private var contentContainer:Sprite;

	private var textLayer:TextField;
	private var menuLayer:Sprite;
	private var objectsLayer:GameLayer;
	private var layer1Layer:GameLayer;
	private var layer2Layer:GameLayer;
	private var backgroundLayer:GameLayer;

	private var screenRect:Rectangle;

	private var gameState:GameState;

	public function new(fs:VirtualFileSystem, subpath:String, script:String, scriptPos:Int = 0)
	{
		super();

		//if (script == null) script = 'PW0001';
		if (script == null) script = 'START';

		this.initScript = script;
		this.initScriptPos = scriptPos;
		this.fs = SubVirtualFileSystem.fromSubPath(fs, subpath);

		init();
	}

	private function init()
	{
		WillResourceManager.createFromFileSystemAsync(fs).then(init2);
	}

	private function init2(willResourceManager:WillResourceManager)
	{
		this.willResourceManager = willResourceManager;
		this.gameSprite = new Sprite();

		this.contentContainer = new Sprite();

		screenRect = new Rectangle(0, 0, 800, 600);

		//var centerPoint = Anchor.centerCenter.getPointInRect(screenRect);
		//var zeroPoint = Anchor.topLeft.getPointInRect(screenRect);

		this.contentContainer.addChild(this.backgroundLayer = new GameLayer(willResourceManager, Anchor.centerCenter));
		this.contentContainer.addChild(this.layer1Layer = new GameLayer(willResourceManager, Anchor.topLeft));
		this.contentContainer.addChild(this.layer2Layer = new GameLayer(willResourceManager, Anchor.topLeft));
		this.contentContainer.addChild(this.objectsLayer = new GameLayer(willResourceManager, Anchor.topLeft));
		this.contentContainer.addChild(this.menuLayer = new Sprite());


		this.gameSprite.addChild(this.previousBitmap = new Bitmap(new BitmapData(800, 600, true, 0x00000000), PixelSnapping.ALWAYS, true));
		this.gameSprite.addChild(this.currentBitmap = new Bitmap(new BitmapData(800, 600, true, 0x00000000), PixelSnapping.ALWAYS, true));
		this.gameSprite.addChild(this.textLayer = new TextField());
		textLayer.selectable = false;

		addChild(new GameScalerSprite(800, 600, this.gameSprite));

		gameState = new GameState();
		var rio = new RIO(this, willResourceManager, gameState);

		rio.loadAsync(initScript).then(function(e)
		{
			rio.jumpAbsolute(initScriptPos);
			rio.executeAsync().then(function(e)
			{
				Log.trace('END!');
			});
		});
	}

	private var transitionMask:BitmapData;
	//private var transitionMaskBitmap:Bitmap;

	public function setTransitionMaskAsync(name:String):Promise<Dynamic>
	{
		return getBtyeArrayAsync('$name.MSK').then(function(data:ByteArray)
		{
			//Log.trace('mask: ${data.length}');
			var wip = WIP.fromByteArray(data);
			transitionMask = wip.get(0).bitmapData;
			//Log.trace('mask: ${transitionMask.width}x${transitionMask.height}');
		});
	}

	public function performTransitionAsync(kind:Int, time:Int):Promise<Dynamic>
	{
		var rect = previousBitmap.bitmapData.rect;
		var previousBitmapData = previousBitmap.bitmapData;
		var currentBitmapData = currentBitmap.bitmapData;

		previousBitmapData.copyPixels(currentBitmapData, rect, new Point(0, 0));

		previousBitmap.alpha = 1;
		currentBitmap.alpha = 0;

		currentBitmapData.lock();
		currentBitmapData.fillRect(rect, 0x00000000);
		currentBitmapData.draw(contentContainer);
		currentBitmapData.unlock();

		/*
		var outputBitmapData = previousBitmap.bitmapData;

		var previous = renderPrev();
		var next = renderNext();
		var temp1 = renderTemp1();
		var temp2 = renderTemp2();
		*/

		//return new Promise<Dynamic>();

		return Tween.forTime(time / 1000).onStep(function(ratio:Float)
		{
			switch (kind) {
				case 42, 44: // TRANSITION MASK (blend) (42: normal, 44: reverse)
				{
					BitmapDataUtils.applyBlendMaskWithOffset(currentBitmapData, transitionMask, ratio, (kind != 44));
					currentBitmap.alpha = 1;
				}
				case 23, 24: // TRANSITION MASK (no blend) (42: normal, 44: reverse)
				{
					BitmapDataUtils.applyNoBlendMaskWithOffset(currentBitmapData, transitionMask, ratio, (kind == 24));
					currentBitmap.alpha = 1;
				}
				default:
				{
					currentBitmap.alpha = ratio;
				}
			}
		}).animateAsync();
	}

	public function getLayerWithName(name:String):GameLayer
	{
		return switch (name) {
			case 'layer2': layer2Layer;
			case 'layer1': layer1Layer;
			case 'objects': objectsLayer;
			case 'background': backgroundLayer;
			default: throw(new Error());
		}
	}

	public function getBtyeArrayAsync(name:String):Promise<ByteArray>
	{
		return willResourceManager.readAllBytesAsync(name);
	}

	private var channels:Map<String, SoundChannel>;

	private function getChannelVolume(name:String):Float
	{
		return switch (name) {
			case 'music': 0.5;
			default: 1.0;
		}
	}

	public function setText(text:String):Void
	{
		textLayer.defaultTextFormat = new TextFormat("Arial", 16, 0xFFFFFFFF);
		textLayer.selectable = false;
		textLayer.width = 800;
		textLayer.height = 600;
		textLayer.text = StringTools.replace(text, '\\n', '\n');
	}

	public function soundPlayStopAsync(channelName:String, name:String, fadeInOutMs:Int):Promise<Dynamic>
	{
		//return Promise.promise(null);

		if (channels == null) channels = new Map<String, SoundChannel>();

		if (channels.exists(channelName))
		{
			channels[channelName].stop();
			channels.remove(channelName);
		}

		if (name == null || name.length == 0)
		{
			return Promise.promise(null);
		}
		else
		{
			return getBtyeArrayAsync(PathUtils.addExtensionIfMissing(name, 'ogg')).then(function(data:ByteArray)
			{
				var sound = new Sound();
				var playAsMusic = (channelName == 'music');
				sound.loadCompressedDataFromByteArray(data, data.length, playAsMusic);
				var channel:SoundChannel = channels[channelName] = sound.play();
				channel.soundTransform = new SoundTransform(getChannelVolume(channelName));
			});
		}
	}

	private var menuItems:Array<DisplayObject>;

	public function animLoadAsync(name:String):Promise<Dynamic>
	{
		if (menuItems == null) menuItems = new Array<DisplayObject>();

		var promise = new Promise<Dynamic>();
		getBtyeArrayAsync(PathUtils.addExtensionIfMissing(name, 'anm')).then(function(data:ByteArray)
		{
			var anm = ANM.fromByteArray(data);
			willResourceManager.getWipWithMaskAsync(anm.wipName).then(function(wip:WIP)
			{
				if (menuLayer.numChildren > 0) menuLayer.removeChildren();
				for (n in 0 ... wip.getLength())
				{
					var wipEntry = wip.get(n);
					var bitmap = new Bitmap(wipEntry.bitmapData, PixelSnapping.ALWAYS, true);
					bitmap.x = wipEntry.x;
					bitmap.y = wipEntry.y;
					bitmap.visible = false;
					menuItems.push(bitmap);
					menuLayer.addChild(bitmap);
				}
				promise.resolve(null);
			});
		});
		return promise;
	}

	private function updateMenuEnable()
	{
		menuLayer.getChildAt(0).visible = true;
		for (n in 0 ... tbl.count)
		{
			var enableFlag = tbl.enable_flags[n];
			var enable = gameState.getFlag(enableFlag) != 0;
			//Log.trace(enableFlag);
			//menuLayer.getChildAt(n + 1).visible = enable;
		}
	}

	private var tbl:TBL;

	private var tblMask:BitmapData;

	public function tableLoadAsync(name:String):Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		getBtyeArrayAsync(PathUtils.addExtensionIfMissing(name, 'TBL')).then(function(data:ByteArray)
		{
			tbl = TBL.fromByteArray(data);

			willResourceManager.getWipAsync(tbl.mskName + '.MSK').then(function(msk:WIP):Void
			{
				tblMask = msk.get(0).bitmapData;
				//File.saveBytes('c:/temp/lol2.png', msk.get(0).bitmapData.encode('png'));
				updateMenuEnable();
				promise.resolve(null);
			});
		});
		return promise;
	}

	public function setDirectMode(directMode:Bool):Void
	{
		if (gameSprite.contains(contentContainer) == directMode) return;

		if (gameSprite.contains(contentContainer)) gameSprite.removeChild(contentContainer);
		if (directMode) gameSprite.addChild(contentContainer);

		if (!directMode)
		{

			while (menuLayer.numChildren > 0) menuLayer.removeChildAt(0);
		}
	}

	public function setAnimObjectVisibility(index:Int, visible:Bool):Promise<Dynamic>
	{
		var index1 = index + 1;
		menuItems[index1].visible = visible;
		//Log.trace('@@@@@@@@@@@ index: $index1 -> $visible');
		//menuLayer.getChildAt(index1).visible = visible;
		//return new Promise<Dynamic>();
		return Promise.promise(null);
	}
}