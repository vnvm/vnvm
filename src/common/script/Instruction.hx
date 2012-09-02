package common.script;
import common.StringEx;
import haxe.Log;
import nme.errors.Error;

/**
 * ...
 * @author 
 */

class Instruction {
	public var opcode:Opcode;
	public var parameters:Array<Dynamic>;
	public var async:Bool;
	public var position:Int;
	public var size:Int;
	
	public function new(opcode:Opcode, parameters:Array<Dynamic>, async:Bool, position:Int = 0, size:Int = -1) {
		this.opcode = opcode;
		this.parameters = parameters;
		this.async = async;
		this.position = position;
		this.size = size;
	}
	
	public function call(object:Dynamic):Dynamic {
		if (opcode.unimplemented) {
			Log.trace(Std.format("Unimplemented: $this"));
		} else {
			Log.trace(Std.format("Executing... $this"));
		}
		return Reflect.callMethod(object, Reflect.field(object, opcode.methodName), parameters);
	}
	
	public function toString():String {
		return StringEx.sprintf("%04X(%d): %04X.%s %s", [position, size, opcode.opcodeId, opcode.methodName, parameters.join(', ')]);
	}
}