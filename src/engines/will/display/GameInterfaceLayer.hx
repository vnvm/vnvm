package engines.will.display;

import lang.time.Timer2;
import lang.DisposableGroup;
import lang.IDisposable;
import lang.signal.Signal;
import common.input.GameInput;
import lang.promise.Promise;
import lang.promise.IPromise;
import reflash.display.DisplayObject2;
import reflash.display.AnimatedImage2;
import reflash.display.TextField2;
import flash.text.TextFormat;
import reflash.gl.wgl.WGLTexture;
import reflash.display.Image2;
import reflash.display.Stage2;
import flash.display.BitmapData;
import flash.text.TextField;
import common.tween.Easing;
import common.tween.Tween;
import haxe.Log;
import engines.will.formats.wip.WIP;
import reflash.display.Sprite2;

class GameInterfaceLayer extends Sprite2
{
	private var willResourceManager:WillResourceManager;
	private var wipLayer:WIPLayer;
	private var textField2:TextField2;
	private var waitingLayer:DisplayObject2;

	public function new(willResourceManager:WillResourceManager)
	{
		super();

		this.willResourceManager = willResourceManager;
	}

	public function initAsync():IPromise<Dynamic>
	{
		// QLOAD, QSAVE, LOAD, SAVE, LOG, AUTO, SKIP, STATUS, SYSTEM
		var deferred = Promise.createDeferred();
		willResourceManager.getWipWithMaskAsync("CLKWAIT").then(function(clkWaitWip:WIP)
		{
			willResourceManager.getWipWithMaskAsync("WINBASE0").then(function(winBase0Wip:WIP)
			{
				var clkwaitTexture = WGLTexture.fromBitmapData(clkWaitWip.get(0).bitmapData);
				var clkwaitFrames = clkwaitTexture.split(55, clkwaitTexture.height);

				//wip.save('c:/temp');
				//Log.trace("$wip");
				wipLayer = WIPLayer.fromWIP(winBase0Wip);
				wipLayer.setPosition(400, 600 - 8);
				wipLayer.setAnchor(0.5, 1);
				addChild(wipLayer);
				wipLayer.addChild(textField2 = new TextField2());
				textField2.setPosition(50, 56);

				wipLayer.addChild(this.waitingLayer = new AnimatedImage2(clkwaitFrames, 30).setPosition(650, 120));
				this.waitingLayer.visible = false;
				//wipLayer.addChild(new Image2(clkwaitTexture));

				setButtonState(Buttons.QLOAD, 1);
				setButtonState(Buttons.QSAVE, 1);
				setButtonState(Buttons.LOAD, 1);
				setButtonState(Buttons.SAVE, 1);
				setButtonState(Buttons.LOG, 1);
				setButtonState(Buttons.AUTO, 1);
				setButtonState(Buttons.SKIP, 1);
				setButtonState(Buttons.STATUS, 1);
				setButtonState(Buttons.SYSTEM, 1);

				hideAsync(0).then(function(?e)
				{
					deferred.resolve(null);
				});
			});
		});
		return deferred.promise;
	}

	public function setTextAsync(text:String, timePerCharacter:Float = 0.05):IPromise<Dynamic>
	{
		var totalTime = timePerCharacter * text.length;
		this.waitingLayer.visible = false;

		var disposable = DisposableGroup.create();

		var promise = Tween.forTime(totalTime).onStep(function(step:Float) {
			textField2.text = text.substr(0, Math.round(text.length * step));
		}).animateAsync().then(function(e) {
			waitingLayer.visible = true;
			Log.trace('Completed text! $text');
			disposable.dispose();
		});

		disposable.add(Signal.addAnyOnce([GameInput.onClick], function(e) {
			promise.cancel();
		}));

		return promise;
	}

	public function hideAsync(time:Float = 0.3):IPromise<Dynamic>
	{
		if (wipLayer.alpha == 0) return Promise.createResolved();

		this.waitingLayer.visible = false;

		return Tween.forTime(time)
			.interpolateTo(wipLayer.getLayer(0), { scaleY: 0 })
			.interpolateTo(wipLayer, { alpha: 0 })
			.withEasing(Easing.easeInOutQuad)
			.animateAsync()
		;
	}

	public function showAsync(time:Float = 0.3):IPromise<Dynamic>
	{
		if (wipLayer.alpha == 1) return Promise.createResolved();

		this.waitingLayer.visible = false;

		return Tween.forTime(time)
			.interpolateTo(wipLayer.getLayer(0), { scaleY: 1 })
			.interpolateTo(wipLayer, { alpha: 1 })
			.withEasing(Easing.easeInOutQuad)
			.animateAsync()
		;
	}

	private function setButtonState(button:Int, state:Int):Void
	{
		if (state == 0) wipLayer.setLayerVisibility(1 + button, true);
		if (state == 1) wipLayer.setLayerVisibility(10 + button, true);
		if (state == 2) wipLayer.setLayerVisibility(19 + button, true);
	}
}

//@:coreType abstract Button from Int to Int { }

class Buttons
{
	static public var QLOAD :Int = 0;
	static public var QSAVE :Int = 1;
	static public var LOAD  :Int = 2;
	static public var SAVE  :Int = 3;
	static public var LOG   :Int = 4;
	static public var AUTO  :Int = 5;
	static public var SKIP  :Int = 6;
	static public var STATUS:Int = 7;
	static public var SYSTEM:Int = 8;
}
