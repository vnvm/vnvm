package common.display;
import flash.events.Event;

/**
 * ...
 * @author soywiz
 */

class OptionSelectedEvent extends Event
{
	public var selectedOption:Option;

	public function new(selectedOption:Option) 
	{
		super("optionSelectedEvent");
		
		this.selectedOption = selectedOption;
	}
	
}