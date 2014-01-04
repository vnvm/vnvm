package engines.will;

import engines.will.display.IGameElementsLayer;
import engines.will.display.WIPLayer;
import engines.will.display.GameInterfaceLayerList;
import engines.will.display.GameElementsLayer;
import common.display.GameScalerSprite2;
import haxe.io.Path;
import reflash.gl.wgl.WGLTexture;
import reflash.gl.wgl.WGLFrameBuffer;
import reflash.gl.IGLTexture;
import reflash.gl.IGLFrameBuffer;
import lang.DisposableHolder;
import reflash.display.TransitionImage2;
import reflash.display.HtmlColors;
import reflash.display.Stage2;
import reflash.display.Quad2;
import reflash.display.Color2;
import reflash.display.DisplayObject2;
import reflash.display.Image2;
import reflash.display.Sprite2;
import common.input.GameInput;
import flash.display.DisplayObject;
import engines.will.formats.anm.TBL;
import engines.will.formats.anm.ANM;
import flash.text.TextFormat;
import flash.text.TextField;
import flash.geom.Rectangle;
import common.geom.Anchor;
import flash.errors.Error;
import common.tween.Tween;
import flash.geom.Point;
import flash.display.BitmapData;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.media.Sound;
import flash.display.PixelSnapping;
import engines.will.formats.wip.WIP;
import promhx.Promise;
import haxe.Log;
import common.display.GameScalerSprite;
import common.imaging.BitmapDataUtils;
import vfs.SubVirtualFileSystem;
import vfs.VirtualFileSystem;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.utils.ByteArray;
//import sys.io.File;

/**
 * ...
 * @author soywiz
 */

class EngineMain extends Sprite2 implements IScene
{
	private var gameSprite:Sprite2;
	private var fs:VirtualFileSystem;
	private var initScript:String;
	private var initScriptPos:Int;
	private var willResourceManager:WillResourceManager;

	private var emptyTexture:IGLTexture;
	private var previousBitmap:IGLFrameBuffer;
	private var renderedBitmap:IGLFrameBuffer;
	private var currentBitmap:IGLFrameBuffer;

	private var previousBitmapImage:Image2;
	private var currentBitmapImage:Image2;

	private var contentContainer:Sprite2;

	//private var textLayer:TextField;
	//private var menuLayer:Sprite2;
	private var gameLayerList:GameInterfaceLayerList;


	private var screenRect:Rectangle;

	private var gameState:GameState;

	private var transitionMask:BitmapData;
	private var transitionMaskTexture:DisposableHolder<IGLTexture>;

	public function new(fs:VirtualFileSystem, subpath:String, script:String, scriptPos:Int = 0)
	{
		super();

		transitionMaskTexture = new DisposableHolder<IGLTexture>();

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
		this.gameSprite = new Sprite2();

		this.contentContainer = new Sprite2();

		screenRect = new Rectangle(0, 0, 800, 600);

		//var centerPoint = Anchor.centerCenter.getPointInRect(screenRect);
		//var zeroPoint = Anchor.topLeft.getPointInRect(screenRect);

		this.contentContainer.addChild(this.gameLayerList = new GameInterfaceLayerList(willResourceManager));

		this.emptyTexture = WGLTexture.fromEmpty(800, 600);
		this.previousBitmap = WGLFrameBuffer.create(800, 600).clear(HtmlColors.black).finish();
		this.renderedBitmap = WGLFrameBuffer.create(800, 600).clear(HtmlColors.black).finish();
		this.currentBitmap = WGLFrameBuffer.create(800, 600).clear(HtmlColors.black).finish();

		this.gameSprite.addChild(previousBitmapImage = new Image2(previousBitmap.texture));
		this.gameSprite.addChild(currentBitmapImage = new Image2(currentBitmap.texture));

		addChild(new GameScalerSprite2(800, 600, this.gameSprite));

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

	public function setTransitionMaskAsync(name:String):Promise<Dynamic>
	{
		return getBtyeArrayAsync('$name.MSK').then(function(data:ByteArray)
		{
			var wip = WIP.fromByteArray(data);
			transitionMask = wip.get(0).bitmapData;
			transitionMaskTexture.set(WGLTexture.fromBitmapData(transitionMask));
		});
	}

	public function performTransitionAsync(kind:Int, time:Int):Promise<Dynamic>
	{
		previousBitmap.clear(HtmlColors.black).draw(renderedBitmap).finish();
		renderedBitmap.clear(HtmlColors.black).draw(contentContainer).finish();
		currentBitmap.clear(HtmlColors.black).draw(renderedBitmap).finish();

		return Tween.forTime(time / 1000).onStep(function(ratio:Float)
		{
			currentBitmapImage.y = currentBitmapImage.x = 0;
			switch (kind)
			{
				case 0: // EFFECT
					// @TODO
					currentBitmapImage.alpha = ratio;
				case 11, 12, 13, 14: // COURTAIN TOP-BOTTOM, BOTTOM-TOP, LEFT->RIGHT, RIGHT->LEFT
					// @TODO
					currentBitmapImage.alpha = ratio;
				case 28, 29, 30, 31: // EFFECT BOTTOM->TOP, TOP->BOTTOM, RIGHT->LEFT, LEFT->RIGHT
					// @TODO
					currentBitmapImage.alpha = ratio;

				case 25: // TRANSITION NORMAL FADE IN (alpha)
					currentBitmapImage.alpha = ratio;

				case 26: // TRANSITION NORMAL FADE IN BURN (alpha)
					// @TODO
					currentBitmapImage.alpha = ratio;

				case 42, 44, 23, 24: // TRANSITION MASK (blend) (42: normal, 44: reverse), TRANSITION MASK (no blend) (23: normal, 24: reverse)
					var reverse = (kind == 44) || (kind == 24);
					var blend = (kind == 42) || (kind == 44);
					currentBitmap.clear(HtmlColors.transparent).draw(new TransitionImage2(previousBitmap.texture, renderedBitmap.texture, transitionMaskTexture.value, ratio, reverse, blend)).finish();
					//currentBitmap.clear(HtmlColors.transparent).draw(new TransitionImage2(emptyTexture, renderedBitmap.texture, transitionMaskTexture.value, ratio)).finish();

				default:
					throw('Invalid transition kind $kind');
			}
		}).animateAsync();
	}

	public function getLayerWithName(name:String):IGameElementsLayer
	{
		return gameLayerList.getLayerWithName(name);
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
		/*
		textLayer.defaultTextFormat = new TextFormat("Arial", 16, 0xFFFFFFFF);
		textLayer.selectable = false;
		textLayer.width = 800;
		textLayer.height = 600;
		textLayer.text = StringTools.replace(text, '\\n', '\n');
		*/
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
			return getBtyeArrayAsync(Path.withExtension(name, 'ogg')).then(function(data:ByteArray)
			{
				var sound = new Sound();
				var playAsMusic = (channelName == 'music');

				if (playAsMusic) return;

				sound.loadCompressedDataFromByteArray(data, data.length, playAsMusic);
				var channel:SoundChannel = channels[channelName] = sound.play();
				channel.soundTransform = new SoundTransform(getChannelVolume(channelName));
			});
		}
	}

	public function animLoadAsync(name:String):Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		getBtyeArrayAsync(Path.withExtension(name, 'anm')).then(function(data:ByteArray)
		{
			var anm = ANM.fromByteArray(data);
			willResourceManager.getWipWithMaskAsync(anm.wipName).then(function(wip:WIP)
			{
				gameLayerList.getMenuLayer().setAnmAndWip(anm, wip);

				promise.resolve(null);
			});
		});
		return promise;
	}

	public function tableLoadAsync(name:String):Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		getBtyeArrayAsync(Path.withExtension(name, 'TBL')).then(function(data:ByteArray)
		{
			var tbl = TBL.fromByteArray(data);
			willResourceManager.getWipAsync(tbl.mskName + '.MSK').then(function(msk:WIP):Void
			{
				gameLayerList.getMenuLayer().setTableMask(tbl, msk.get(0).bitmapData);
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
		if (!directMode) gameLayerList.getMenuLayer().setAnmAndWip(null, null);
	}

	public function setAnimObjectVisibility(index:Int, visible:Bool):Promise<Dynamic>
	{
		var menuWipLayer = gameLayerList.getMenuLayer().getWipLayer();
		if (menuWipLayer != null)
		{
			var index1 = index + 1;
			menuWipLayer.setLayerVisibility(index1, visible);
		}
		return Promise.promise(null);
	}

	public function isEnabledKind(kind:Int):Bool
	{
		var menuWipLayer = gameLayerList.getMenuLayer().getWipLayer();
		if (menuWipLayer != null)
		{
			//return true;
			return menuWipLayer.isLayerEnabled(kind);
		}
		return false;
	}

	public function getMaskValueAt(point:Point):Int
	{
		return gameLayerList.getMenuLayer().getTableAt(Std.int(point.x), Std.int(point.y));
	}

	public function getMousePosition():Point
	{
		return gameSprite.globalToLocal(GameInput.mouseCurrent);
	}
}