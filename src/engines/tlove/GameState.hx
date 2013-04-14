package engines.tlove;
import common.LangUtils;
import haxe.Log;

/**
 * ...
 * @author soywiz
 */

class GameState 
{
	public var textVisible:Bool = true;

	private var flags:Array<Int>;
	private var sysflags:Array<Int>;
	private var menuFlags:Array<Int>;
	private var LSB:Array<Int>;
	private var LSW:Array<Int>;
	private var names:Array<String>;

	public function new() {
		this.flags = LangUtils.createArray(function() { return 0x00; }, 0x1000);
		this.sysflags = LangUtils.createArray(function() { return 0x00; }, 0x1000);
		this.menuFlags = LangUtils.createArray(function() { return 0x00; }, 0x100);
		this.LSB = LangUtils.createArray(function() { return 0; }, 0x8000);
		this.LSW = LangUtils.createArray(function() { return 0; }, 0x8000);
		this.names = LangUtils.createArray(function() { return ""; }, 0x100);
	}

	public function setFlag(type:Int, index:Int, value:Int):Void {
		switch (type) {
			case 0: setNormalFlag(index, value);
			case 1: setMenuFlag(index, value);
			case 2: setLSB(index, value);
			case 3: setLSW(index, value);
		}
	}

	public function getFlag(type:Int, index:Int):Int {
		return switch (type) {
			case 0: getNormalFlag(index);
			case 1: getMenuFlag(index);
			case 2: getLSB(index);
			case 3: getLSW(index);
		};
	}

    public function getVal(v:Int) {
        if ((v & 0x8000) == 0x8000) return this.getLSW(v);
        return v;
    }

    public function getValR(v:Int) {
        if ((v & 0xC000) == 0xC000) return Math.round(Math.random() * (v & 0x3FFF));
        return this.getVal(v);
    }
	
	public function getLSW(index:Int):Int {
		return LSW[index & 0x7FFF];
	}
	
	public function setLSW(index:Int, value:Int):Void {
		if (value != 0) Log.trace("LSW[" + index + "]=" + value + " : " + (value & 0xFFFF));
		LSW[index & 0x7FFF] = (value & 0xFFFF);
	}

	public function getLSB(index:Int):Int {
		return LSB[index & 0x7FFF];
	}
	
	public function setLSB(index:Int, value:Int):Void {
		if (value != 0) Log.trace("LSB[" + index + "]=" + value + " : " + (value & 0xFF));
		LSB[index & 0x7FFF] = (value & 0xFF);
	}

	public function getNormalFlag(index:Int):Int {
		return flags[index & 0x7FF];
	}
	
	public function setNormalFlag(index:Int, value:Int):Void {
		if (value != 0) Log.trace("FLAG[" + index + "]=" + value);
		flags[index & 0x7FF] = value;
	}

	public function getMenuFlag(index:Int):Int {
		return menuFlags[index & 0xFF];
	}
	
	public function setMenuFlag(index:Int, value:Int):Void {
		if (value != 0) Log.trace("MENUFLAG[" + index + "]=" + value);
		menuFlags[index & 0xFF] = value;
	}
	
	public function getSysFlag(index:Int) {
		return this.sysflags[index];
	}

	public function setSysFlag(index:Int, value:Int) {
		if (value != 0) Log.trace("SYS_FLAG[" + index + "]=" + value);
		this.sysflags[index] = value;
	}
	
	public function getName(index:Int) {
		return this.names[index];
	}

	public function setName(index:Int, value:String) {
		if (value != "") Log.trace("NAMES[" + index + "]=" + value);
		this.names[index] = value;
	}
}