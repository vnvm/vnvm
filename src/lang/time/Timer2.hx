package lang.time;
import lang.signal.Signal;
import lang.promise.IPromise;
import lang.promise.Deferred;
import haxe.PosInfos;
import haxe.Timer;
import flash.events.Event;

/**
 * ...
 * @author soywiz
 */

class Timer2 
{
	public var onTick:Signal<Event>;

	private function new(seconds:Float) 
	{
		this.onTick = new Signal<Event>();

		Timer.delay(function():Void {
			onTick.dispatch(new Event("tick"));
		}, Std.int(seconds / 1000));
	}
	
	static public function createAndStart(seconds:Float):Timer2
	{
		return new Timer2(seconds);
	}

	static public function measure(func:Void -> Void, ?pos:PosInfos)
	{
		var start:Float = Timer.stamp();
		func();
		return Timer.stamp() - start;
	}

	static public function measureAndTrace(func:Void -> Void, ?pos:PosInfos)
	{
		var elapsed = measure(func, pos);
		trace(pos.className + "." + pos.methodName + ": " + elapsed);
	}

	static public function stamp():Float
	{
		return Timer.stamp();
	}

	static public function waitAsync(seconds:Float):IPromise<Dynamic>
	{
		var deferred = new Deferred<Dynamic>();
		Timer.delay(function() {
			deferred.resolve(null);
		}, Std.int(seconds * 1000));
		return deferred.promise;
	}
}