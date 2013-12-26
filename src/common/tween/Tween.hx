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

	private function new(totalTime:Float)
	{
		this.totalTime = totalTime;
		this.stepSignal = new Signal<Float>();
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

	public function animateAsync():Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		var start = Timer.stamp();
		var stageGroup = new EventListenerGroup(StageReference.stage);

		function step(?e) {
			var current = Timer.stamp();
			var elapsed = current - start;
			var ratio = MathEx.clamp(elapsed / totalTime, 0, 1);

			//Log.trace('********************* animateAsync: $start, $current, $elapsed, $totalTime, $ratio');

			stepSignal.dispatch(ratio);

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