package common.event;

import flash.events.IEventDispatcher;

class EventListenerGroup
{
	private var eventDispatcher:IEventDispatcher;
	private var registeredEvents:Array<Array<Dynamic>>;

	public function new(eventDispatcher:IEventDispatcher)
	{
		this.registeredEvents = [];
		this.eventDispatcher = eventDispatcher;
	}

	public function addEventListener(type:String, listener:Dynamic -> Void):Void
	{
		this.eventDispatcher.addEventListener(type, listener);
		this.registeredEvents.push([type, listener]);
	}

	public function dispose():Void
	{
		for (registeredEvent in this.registeredEvents)
		{
			this.eventDispatcher.removeEventListener(registeredEvent[0], registeredEvent[1]);
		}
		this.registeredEvents = null;
		this.eventDispatcher = null;
	}
}