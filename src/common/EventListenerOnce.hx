package common;

import flash.events.IEventDispatcher;

class EventListenerOnce
{
	private var eventListenerGroup:EventListenerGroup;

	public function new(eventDispatcher:IEventDispatcher)
	{
		this.eventListenerGroup = new EventListenerGroup(eventDispatcher);
	}

	public function addEventListener(type:String, listener:Dynamic -> Void):Void
	{
		eventListenerGroup.addEventListener(type, function(e) {
			eventListenerGroup.dispose();
			listener(e);
		});
	}

	public function dispose():Void
	{
		eventListenerGroup.dispose();
		eventListenerGroup = null;
	}
}