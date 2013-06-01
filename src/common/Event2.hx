package common;
import flash.events.Event;

/**
 * ...
 * @author soywiz
 */

class Event2<T : (Event)>
{

	public function new() 
	{
		events = [];
	}
	
	private var events:Array<T -> Void>;
	
	public function trigger(object:T):Void {
		for (event in events) {
			event(object);
		}
	}
	
	public function registerOnce(func:T -> Void):Void {
		var func2:T -> Void = null;
		
		func2 = function(object:T) {
			unregister(func2);
			func(object);
		};

		register(func2);
	}

	public function register(func:T -> Void):Void {
		events.push(func);
	}

	public function unregister(func:T -> Void):Void {
		events.remove(func);
	}
	
	static public function registerOnceAny(events:Array<Event2<Dynamic>>, func:Dynamic -> Void):Void {
		var func2:Dynamic -> Void = null;
		
		func2 = function(object:Dynamic) {
			for (event in events) event.unregister(func2);
			func(object);
		};

		for (event in events) event.register(func2);
	}
}