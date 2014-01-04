package common;
import common.event.Event2;
import promhx.Promise;
import haxe.Log;
import haxe.PosInfos;
import haxe.Timer;
import flash.events.Event;

/**
 * ...
 * @author soywiz
 */

class Timer2 
{
	public var onTick:Event2<Event>;

	private function new(seconds:Float) 
	{
		this.onTick = new Event2<Event>();

		Timer.delay(function():Void {
			onTick.trigger(new Event("tick"));
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

	static public function waitAsync(timeMilliseconds:Int):Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		Timer.delay(function() {
			promise.resolve(null);
		}, timeMilliseconds);
		return promise;
	}

}