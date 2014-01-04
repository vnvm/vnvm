package engines.will.display;

import common.tween.Easing;
import common.tween.Tween;
import haxe.Log;
import engines.will.formats.wip.WIP;
import common.PromiseUtils;
import promhx.Promise;
import reflash.display.Sprite2;

class GameInterfaceLayer extends Sprite2
{
	private var willResourceManager:WillResourceManager;
	private var wipLayer:WIPLayer;

	public function new(willResourceManager:WillResourceManager)
	{
		super();

		this.willResourceManager = willResourceManager;
	}

	public function initAsync():Promise<Dynamic>
	{
		// QLOAD, QSAVE, LOAD, SAVE, LOG, AUTO, SKIP, STATUS, SYSTEM
		var promise = PromiseUtils.create();
		willResourceManager.getWipWithMaskAsync("WINBASE0").then(function(wip:WIP)
		{
			//wip.save('c:/temp');
			//Log.trace("$wip");
			wipLayer = WIPLayer.fromWIP(wip);
			wipLayer.setPosition(400, 600);
			wipLayer.setAnchor(0.5, 1);
			addChild(wipLayer);

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
				promise.resolve(null);
			});
		});
		return promise;
	}

	public function hideAsync(time:Float = 0.5):Promise<Dynamic>
	{
		if (wipLayer.alpha == 0) return PromiseUtils.createResolved();

		return Tween.forTime(time)
			.interpolateTo(wipLayer.getLayer(0), { scaleY: 0 })
			.interpolateTo(wipLayer, { alpha: 0 })
			.withEasing(Easing.easeInOutQuad)
			.animateAsync()
		;
	}

	public function showAsync(time:Float = 0.5):Promise<Dynamic>
	{
		if (wipLayer.alpha == 1) return PromiseUtils.createResolved();

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
