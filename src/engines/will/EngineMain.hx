package engines.will;

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

	private var previousBitmap:Bitmap;
	private var currentBitmap:Bitmap;

	private var contentContainer:Sprite;

	private var objectsLayer:GameLayer;
	private var layer1Layer:GameLayer;
	private var layer2Layer:GameLayer;
	private var backgroundLayer:GameLayer;
	private var textLayer:TextField;

	private var screenRect:Rectangle;

	public function new(fs:VirtualFileSystem, subpath:String, script:String, scriptPos:Int = 0)
	{
		super();

		if (script == null) script = 'PW0001';

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

		this.gameSprite.addChild(this.previousBitmap = new Bitmap(new BitmapData(800, 600, true, 0x00000000), PixelSnapping.ALWAYS, true));
		this.gameSprite.addChild(this.currentBitmap = new Bitmap(new BitmapData(800, 600, true, 0x00000000), PixelSnapping.ALWAYS, true));
		this.gameSprite.addChild(this.textLayer = new TextField());
		textLayer.selectable = false;

		addChild(new GameScalerSprite(800, 600, this.gameSprite));

		var rio = new RIO(this, willResourceManager);

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
		return getBtyeArrayAsync('$name.MSK').then(function(data:ByteArray) {
			var wip = WIP.fromByteArray(data);
			transitionMask = wip.get(0).bitmapData;
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

		return Tween.forTime(time / 1000).onStep(function(ratio:Float)
		{
			switch (kind) {
				case 42, 44: // TRANSITION MASK (blend) (42: normal, 44: reverse)
				{
					BitmapDataUtils.applyBlendMaskWithOffset(currentBitmapData, transitionMask, ratio, (kind == 44));
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
			return getBtyeArrayAsync(PathUtils.addExtensionIfMissing(name, 'ogg')).then(function(data:ByteArray) {
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(data, data.length);
				var channel:SoundChannel = channels[channelName] = sound.play();
				channel.soundTransform = new SoundTransform(getChannelVolume(channelName));
			});
		}
	}

	public function animLoadAsync(name:String):Promise<Dynamic>
	{
		return getBtyeArrayAsync(PathUtils.addExtensionIfMissing(name, 'anm')).then(function(data:ByteArray) {
			var anm = ANM.fromByteArray(data);
		});
	}

	public function tableLoadAsync(name:String):Promise<Dynamic>
	{
		return Promise.promise(null);
	}
}