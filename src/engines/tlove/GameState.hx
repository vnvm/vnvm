package engines.tlove;
import common.LangUtils;
import flash.errors.Error;
import flash.geom.Rectangle;
import haxe.Log;

/**
 * ...
 * @author soywiz
 */

class GameState 
{
	public var textVisible:Bool = true;
	public var textRectangle:Rectangle;

	private var flags:Array<Int>;
	private var sysflags:Array<Int>;
	private var menuFlags:Array<Int>;
	private var LSB:Array<Int>;
	private var LSW:Array<Int>;
	private var settings:Array<Int>;
	private var names:Array<String>;

	public function new() {
		this.flags = LangUtils.createArray(function() { return 0x00; }, 0x1000);
		this.sysflags = LangUtils.createArray(function() { return 0x00; }, 0x1000);
		this.menuFlags = LangUtils.createArray(function() { return 0x00; }, 0x100);
		this.LSB = LangUtils.createArray(function() { return 0; }, 0x8000);
		this.LSW = LangUtils.createArray(function() { return 0; }, 0x8000);
		this.settings = LangUtils.createArray(function() { return 0; }, 0x100);
		this.names = LangUtils.createArray(function() { return ""; }, 0x100);
		this.textRectangle = new Rectangle(0, 0, 640, 480);
	}
	
	//(this.sysflags, 'SYSFLAGS');
	//(this.globalVar.flags, 'FLAGS');
	//(this.globalVar.menuvar, 'MENUVAR');
	//(this.globalVar.lsb, 'LSB');
	//(this.globalVar.lsw, 'LSW');
	//(this.globalVar.settings, 'SETTINGS');
	//(this.localVar.seq, 'CHAINS');
	//(this.globalVar.calls, 'CALLS')
	
	public function setSettings(index:Int, value:Int) {
		this.settings[index] = value & 0xFF;
	}

	public function getBitSet(flagType:Int, flagNum:Int):Bool {
		if (flagType == 0) return getNormalFlagBit(flagNum);
		return getMVBit(flagNum);
	}

	public function setFlag(type:Int, index:Int, value:Int):Void {
		switch (type) {
			case 0: setNormalFlag(index, value);
			case 1: setMV(index, value);
			case 2: setLSB(index, value);
			case 3: setLSW(index, value);
		}
	}

	public function getFlag(type:Int, index:Int):Int {
		return switch (type) {
			case 0: getNormalFlag(index);
			case 1: getMV(index);
			case 2: getLSB(index);
			case 3: getLSW(index);
			default: throw(new Error('Invalid type'));
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

	public function getNormalFlagBit(index:Int):Bool {
		var byteOffset:Int = index >> 3;
		var bitOffset:Int = index & 7;
		return (getNormalFlag(byteOffset) & (1 << bitOffset)) != 0;
	}

	public function getNormalFlag(index:Int):Int {
		return flags[index & 0x7FF];
	}
	
	public function setNormalFlag(index:Int, value:Int):Void {
		if (value != 0) Log.trace("FLAG[" + index + "]=" + value);
		flags[index & 0x7FF] = value;
	}
	
	public function getMVBit(index:Int) {
		var byteOffset:Int = index >> 3;
		var bitOffset:Int = index & 7;
		return (getMV(byteOffset) & (1 << bitOffset)) != 0;
	}

	public function getMV(index:Int):Int {
		return menuFlags[index & 0xFF];
	}
	
	public function setMV(index:Int, value:Int):Void {
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