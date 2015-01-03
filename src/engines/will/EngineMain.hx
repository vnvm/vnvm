package engines.will;

import reflash.display2.Milliseconds;
import reflash.display2.Seconds;
import reflash.display2.View;
import engines.will.utils.WillCommandLineMain;
import lang.MathEx;
import reflash.display.TransitionImageBlend2;
import reflash.display.BlendMode;
import reflash.display.DisplayObjectContainer2;
import common.input.Keys;
import lang.promise.Deferred;
import lang.promise.Promise;
import lang.promise.IPromise;
import engines.will.display.GameInterfaceLayer;
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
import flash.geom.Point;
import flash.display.BitmapData;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.media.Sound;
import flash.display.PixelSnapping;
import engines.will.formats.wip.WIP;
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

	public var view:View;

	//private var textLayer:TextField;
	//private var menuLayer:Sprite2;
	private var gameLayerList:GameInterfaceLayerList;
	private var interfaceLayer:GameInterfaceLayer;


	private var screenRect:Rectangle;

	private var gameState:GameState;

	private var transitionMask:BitmapData;
	private var transitionMaskTexture:DisposableHolder<IGLTexture>;

	public function new(view:View, fs:VirtualFileSystem, subpath:String, script:String, scriptPos:Int = 0)
	{
		super();

		this.view = view;
		transitionMaskTexture = new DisposableHolder<IGLTexture>();

//if (script == null) script = 'PW0001';
		if (script == null) script = 'START';

		this.initScript = script;
		this.initScriptPos = scriptPos;
		this.fs = SubVirtualFileSystem.fromSubPath(fs, subpath);

		init();
	}

	public function getFileSystem():VirtualFileSystem
	{
		return fs;
	}

	public function getGameSprite():DisplayObjectContainer2
	{
		return gameSprite;
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

		//new WillCommandLineMain().extractAllImages();
		//return;

		//var centerPoint = Anchor.centerCenter.getPointInRect(screenRect);
		//var zeroPoint = Anchor.topLeft.getPointInRect(screenRect);

		this.contentContainer.addChild(this.gameLayerList = new GameInterfaceLayerList(willResourceManager));

		this.emptyTexture = WGLTexture.fromEmpty(800, 600);
		this.previousBitmap = WGLFrameBuffer.create(800, 600).clear(HtmlColors.black).finish();
		this.renderedBitmap = WGLFrameBuffer.create(800, 600).clear(HtmlColors.black).finish();
		this.currentBitmap = WGLFrameBuffer.create(800, 600).clear(HtmlColors.black).finish();

		this.gameSprite.addChild(previousBitmapImage = new Image2(previousBitmap.texture));
		this.gameSprite.addChild(currentBitmapImage = new Image2(currentBitmap.texture));
		this.gameSprite.addChild(interfaceLayer = new GameInterfaceLayer(view, willResourceManager));

		interfaceLayer.setZIndex(10);

		addChild(new GameScalerSprite2(800, 600, this.gameSprite));

		gameState = new GameState();
		var rio = new RIO(view, this, willResourceManager, gameState);

		interfaceLayer.initAsync().then(function(?e)
		{
			rio.loadAsync(initScript).then(function(?e)
			{
				rio.jumpAbsolute(initScriptPos);
				rio.executeAsync().then(function(?e)
				{
					Log.trace('END!');
				});
			});
		});
	}

	public function setTransitionMaskAsync(name:String):IPromise<Dynamic>
	{
		return getBtyeArrayAsync('$name.MSK').then(function(data:ByteArray)
		{
			var wip = WIP.fromByteArray(data);
			transitionMask = wip.get(0).bitmapData;
			transitionMaskTexture.set(WGLTexture.fromBitmapData(transitionMask));
		});
	}

	public function performTransitionAsync(kind:Int, time:Milliseconds):IPromise<Dynamic>
	{
		var deferred = Promise.createDeferred();

		interfaceLayer.hideAsync(new Seconds(isSkiping() ? 0.0 : 0.3)).then(function(?e)
		{
			previousBitmap.clear(HtmlColors.black).draw(renderedBitmap).finish();
			renderedBitmap.clear(HtmlColors.black).draw(contentContainer).finish();
			currentBitmap.clear(HtmlColors.black).draw(renderedBitmap).finish();

			view.animateAsync(time, function(ratio:Float) {
				currentBitmapImage.y = currentBitmapImage.x = 0;
				currentBitmapImage.blendMode = BlendMode.NORMAL;
				switch (kind)
				{
					case 0: // EFFECT // @TODO
						currentBitmapImage.alpha = ratio;
					case 11, 12, 13, 14: // COURTAIN TOP-BOTTOM, BOTTOM-TOP, LEFT->RIGHT, RIGHT->LEFT // @TODO
						currentBitmapImage.alpha = ratio;
					case 28, 29, 30, 31: // EFFECT BOTTOM->TOP, TOP->BOTTOM, RIGHT->LEFT, LEFT->RIGHT // @TODO
						currentBitmapImage.alpha = ratio;

					case 5, 22, 34: // ZOOM IN // @TODO: pw:pw0001:EB42
						currentBitmapImage.alpha = ratio;

					case 6: // BOXES; // pw0002_1@0FC1
						currentBitmapImage.alpha = ratio;

					case 9: // DIAGONAL: pw0002_1:7F71
						currentBitmapImage.alpha = ratio;

					case 21: // PIXELATE // @TODO: pw:pw0001:EB42
						currentBitmapImage.alpha = ratio;

					case 40: // --- // @TODO: pw:pw0002_1:10209
						currentBitmapImage.alpha = ratio;

					case 25: // TRANSITION NORMAL FADE IN (alpha)
						currentBitmapImage.alpha = ratio;

					case 26: // TRANSITION NORMAL FADE IN BURN (alpha) // @TODO
//currentBitmap.clear(HtmlColors.transparent).draw(new TransitionImageBlend2(previousBitmap.texture, renderedBitmap.texture, ratio)).finish();
						if (ratio < 0.5) {
							currentBitmapImage.blendMode = BlendMode.ADD;
							currentBitmapImage.alpha = MathEx.translateRange(ratio, 0, 0.5, 0, 1);
						} else {
							currentBitmapImage.blendMode = BlendMode.NORMAL;
							currentBitmapImage.alpha = MathEx.translateRange(ratio, 0.5, 1.0, 0, 1);
						}

					case 35: // ZOOM OUT // @TODO: pw:pw0001:BFB7
						currentBitmapImage.alpha = ratio;

					case 36: // WAVE // @TODO: pw:pw0001:BC81
						currentBitmapImage.alpha = ratio;

					case 27: // UNKNOWN : CHECK // @TODO: pw:pw0001:1105A
						currentBitmapImage.alpha = ratio;

					case 39: // UNKNOWN : CHECK // @TODO: pw:pw0001:F445
						currentBitmapImage.alpha = ratio;

					case 43: // STRETCHING EFFECT @TODO: pw:pw0002_1:A5D2
						currentBitmapImage.alpha = ratio;

					case 45: // UNKNOWN : CHECK // @TODO: pw:pw0001:23848
						currentBitmapImage.alpha = ratio;

					case 42, 44, 23, 24: // TRANSITION MASK (blend) (42: normal, 44: reverse), TRANSITION MASK (no blend) (23: normal, 24: reverse)
						var reverse = (kind == 44) || (kind == 24);
						var blend = (kind == 42) || (kind == 44);
						currentBitmap.clear(HtmlColors.transparent).draw(new TransitionImage2(previousBitmap.texture, renderedBitmap.texture, transitionMaskTexture.value, ratio, reverse, blend)).finish();

					default:
						throw('Invalid transition kind $kind');
				}
			}).then(function(?e)
			{
				deferred.resolve(null);
			});
		});

		return deferred.promise;
	}

	public function getLayerWithName(name:String):IGameElementsLayer
	{
		return gameLayerList.getLayerWithName(name);
	}

	public function getBtyeArrayAsync(name:String):IPromise<ByteArray>
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

	public function setTextAsync(text:String, title:String, timePerCharacter:Seconds):IPromise<Dynamic>
	{
		text = StringTools.replace(text, '\\n', '\n');
		title = StringTools.replace(title, '\\n', '\n');

		var deferred = Promise.createDeferred();
		interfaceLayer.showAsync(new Seconds(isSkiping() ? 0.0 : 0.3)).then(function(?e)
		{
			interfaceLayer.setTextAsync(text, title, timePerCharacter).then(function(?e)
			{
				deferred.resolve(null);
			});

		});
		return deferred.promise;
	}

	public function setTextSize(size:Int):Void
	{
		interfaceLayer.setTextSize(size);
	}

	public function soundPlayStopAsync(channelName:String, name:String, fadeInOutMs:Int):IPromise<Dynamic>
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
			return Promise.createResolved(null);
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

	public function animLoadAsync(name:String):IPromise<Dynamic>
	{
		return getBtyeArrayAsync(Path.withExtension(name, 'anm')).pipe(function(data:ByteArray)
		{
			var anm = ANM.fromByteArray(data);
			return willResourceManager.getWipWithMaskAsync(anm.wipName).then(function(wip:WIP)
			{
				gameLayerList.getMenuLayer().setAnmAndWip(anm, wip);
			});
		});
	}

	public function tableLoadAsync(name:String):IPromise<Dynamic>
	{
		return getBtyeArrayAsync(Path.withExtension(name, 'TBL')).pipe(function(data:ByteArray)
		{
			var tbl = TBL.fromByteArray(data);
			return willResourceManager.getWipAsync(tbl.mskName + '.MSK').then(function(msk:WIP):Void
			{
				gameLayerList.getMenuLayer().setTableMask(tbl, msk.get(0).bitmapData);
			});
		});
	}

	public function setDirectMode(directMode:Bool):Void
	{
		if (gameSprite.contains(contentContainer) == directMode) return;
		if (gameSprite.contains(contentContainer)) gameSprite.removeChild(contentContainer);
		if (directMode) gameSprite.addChild(contentContainer);
		if (!directMode) gameLayerList.getMenuLayer().setAnmAndWip(null, null);
		if (!directMode)
		{
			renderedBitmap.clear(HtmlColors.black).draw(contentContainer).finish();
		}
	}

	public function setAnimObjectVisibility(index:Int, visible:Bool):IPromise<Dynamic>
	{
		var menuWipLayer = gameLayerList.getMenuLayer().getWipLayer();
		if (menuWipLayer != null)
		{
			var index1 = index + 1;
			menuWipLayer.setLayerVisibility(index1, visible);
		}
		return Promise.createResolved();
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

	public function isSkiping():Bool
	{
		return GameInput.isPressing(Keys.Control);
	}

}