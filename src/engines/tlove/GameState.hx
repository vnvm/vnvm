package engines.tlove;
import common.LangUtils;

/**
 * ...
 * @author soywiz
 */

class GameState 
{
	public var flags:Array<Int>;
	public var menuFlags:Array<Int>;
	public var LSB:Array<Int>;
	public var LSW:Array<Int>;
	public var textVisible:Bool = true;

	public function new() {
		this.flags = LangUtils.createArray(function() { return 0x00; }, 0x1000);
		this.menuFlags = LangUtils.createArray(function() { return 0x00; }, 0x100);
		this.LSB = LangUtils.createArray(function() { return 0; }, 0x8000);
		this.LSW = LangUtils.createArray(function() { return 0; }, 0x8000);
	}

	public function setFlag(type:Int, index:Int, value:Int):Void {
		switch (type) {
			case 0: flags[index] = value;
			case 1: menuFlags[index] = value;
			case 2: LSB[index] = value;
			case 3: LSW[index] = value;
		}
	}

	public function getFlag(type:Int, index:Int):Int {
		return switch (type) {
			case 0: flags[index];
			case 1: menuFlags[index];
			case 2: LSB[index];
			case 3: LSW[index];
		};
	}

    public function getVal(index:Int) {
        if ((index & 0x8000) == 0x8000) {
            return this.getLSW(index & 0x7FFF);
        }
        return index;
    }

    public function getValR(index:Int) {
        if ((index & 0xC000) == 0xC000) {
            return Math.round(Math.random() * (index & 0x3FFF));
        }
        return this.getVal(index);
    }
	
	public function getLSW(index:Int):Int {
		return LSW[index & 0x7FFF];
	}
	
	public function setLSW(index:Int, value:Int):Void {
		LSW[index & 0x7FFF] = (value & 0xFFFF);
	}
}