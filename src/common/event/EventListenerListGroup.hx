package common.event;
import flash.events.EventDispatcher;
class EventListenerListGroup {
    private var registeredEvents:Array<Array<Dynamic>> = [];

    public function new() {
    }

    public function addEventListener(dispatcher:EventDispatcher, type:String, listener:Dynamic -> Void):Void {
        dispatcher.addEventListener(type, listener);
        this.registeredEvents.push([dispatcher, type, listener]);
    }

    public function dispose():Void {
        for (registeredEvent in this.registeredEvents) {
            cast(registeredEvent[0], EventDispatcher).removeEventListener(registeredEvent[1], registeredEvent[2]);
        }
        this.registeredEvents = [];
    }
}
