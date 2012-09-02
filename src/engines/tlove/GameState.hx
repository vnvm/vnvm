package engines.tlove;
import common.LangUtils;

/**
 * ...
 * @author soywiz
 */

class GameState 
{
	public var flags:Array<Bool>;
	public var MV:Array<Bool>;
	public var LSB:Array<Int>;
	public var LSW:Array<Int>;
	public var textVisible:Bool = true;
	
	public function setFlag(type:Int, index:Int, value:Int):Void {
		switch (type) {
			case 0: flags[index] = (value != 0);
			case 1: MV[index] = (value != 0);
			case 2: LSB[index] = value;
			case 3: LSW[index] = value;
		}
	}
	
	public function new() {
		this.flags = LangUtils.createArray(function() { return false; }, 1000);
		this.MV = LangUtils.createArray(function() { return false; }, 1000);
		this.LSB = LangUtils.createArray(function() { return 0; }, 1000);
		this.LSW = LangUtils.createArray(function() { return 0; }, 1000);
	}
}