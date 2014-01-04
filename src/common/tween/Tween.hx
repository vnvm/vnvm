package common.tween;

import haxe.Log;
import common.signal.Signal;
import flash.events.Event;
import haxe.Timer;
import promhx.Promise;
class Tween
{
	private var totalTime:Float;
	private var stepSignal:Signal<Float>;
	private var easing:Float -> Float;

	private function new(totalTime:Float)
	{
		this.totalTime = totalTime;
		this.stepSignal = new Signal<Float>();
		this.easing = Easing.linear;
	}

	static public function forTime(time:Float):Tween
	{
		return new Tween(time);
	}

	public function onStep(handler:Float -> Void):Tween
	{
		this.stepSignal.add(handler);
		return this;
	}

	public function interpolateTo(object:Dynamic, dstProperties:Dynamic, easing:Float -> Float = null):Tween
	{
		if (easing == null) easing = Easing.linear;
		var srcProperties = {};
		for (property in Reflect.fields(dstProperties))
		{
			Reflect.setField(srcProperties, property, Reflect.field(object, property));
		}

		onStep(function(step:Float)
		{
			step = easing(step);
			for (property in Reflect.fields(dstProperties))
			{
				var src = Reflect.field(srcProperties, property);
				var dst = Reflect.field(dstProperties, property);
				var interpolated = MathEx.interpolate(step, src, dst);
				//Log.trace('$src, $dst -> $interpolated');
				Reflect.setField(object, property, interpolated);
			}
		});
		return this;
	}

	public function withEasing(easing: Float -> Float):Tween
	{
		this.easing = easing;
		return this;
	}

	public function animateAsync():Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		var start = Timer.stamp();
		var stageGroup = new EventListenerGroup(StageReference.stage);

		function step(?e)
		{
			var current = Timer.stamp();
			var elapsed = current - start;
			var ratio = MathEx.clamp(elapsed / totalTime, 0, 1);

			//Log.trace('********************* animateAsync: $start, $current, $elapsed, $totalTime, $ratio');

			stepSignal.dispatch(easing(ratio));

			if (ratio >= 1)
			{
				stageGroup.dispose();
				promise.resolve(null);
			}
		}

		stageGroup.addEventListener(Event.ENTER_FRAME, step);

		step();

		return promise;
	}
}