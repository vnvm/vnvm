package engines.dividead;

/**
 * ...
 * @author soywiz
 */

class GameState 
{
	public var options:Array<Dynamic>;
	public var optionsMap:Array<Dynamic>;
	public var flags:Array<Int>;
	public var title:String;

	public function new() 
	{
		this.options = new Array<Dynamic>();
		this.optionsMap = new Array<Dynamic>();
		this.flags = [];
		this.title = "NoTitle";
		for (n in 0 ... 1000) this.flags.push(0);
	}
	
}