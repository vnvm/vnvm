package engines.will;

import haxe.Log;
class GameState
{
	private static inline var MAX_FLAGS = 3000;
	private static inline var TEMP_FLAGS = 1000;

	private var flags:Array<Int>;

	public var debug:Bool = true;

	public function new()
	{
		flags = new Array<Int>();
	}

	public function setFlagsRange(min:Int, max:Int, value:Int)
	{
		for (n in min ... max) flags[n] = value;
	}

	public function getFlag(id:Int):Int
	{
		// % State.MAX_FLAGS
		return flags[id];
	}

	public function setFlag(id:Int, value:Int):Void
	{
		flags[id] = value;
	}
}