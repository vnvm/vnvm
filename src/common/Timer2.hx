package common;
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
	
	static public function createAndStart(seconds:Float):Timer2 {
		return new Timer2(seconds);
	}
	
	static public function measure(func:Void -> Void, ?pos:PosInfos) {
		var start:Float = Timer.stamp();
		func();
		var end:Float = Timer.stamp();
		trace(pos.className + "." + pos.methodName + ": " + (end - start));
	}
}