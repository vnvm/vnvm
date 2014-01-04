package common.script;
import common.StringEx;
import haxe.Log;
import flash.errors.Error;

/**
 * ...
 * @author 
 */

class Instruction2
{
	public var script:String;
	public var opcode:Opcode;
	public var parameters:Array<Dynamic>;
	public var position:Int;
	public var size:Int;
	
	public function new(script:String, opcode:Opcode, parameters:Array<Dynamic>, position:Int = 0, size:Int = -1)
	{
		this.script = script;
		this.opcode = opcode;
		this.parameters = parameters;
		this.position = position;
		this.size = size;
	}
	
	public function call(object:Dynamic):Dynamic
	{
		if (opcode.unimplemented) {
			Log.trace('Unimplemented: $this');
		} else if (opcode.untested) {
			Log.trace('Untested... $this');
		} else if (!opcode.skipLog) {
			Log.trace('Executing... $this');
		}
		return Reflect.callMethod(object, Reflect.field(object, opcode.methodName), parameters);
	}
	
	public function toString():String
	{
		return StringEx.sprintf("%s:%04X(%d): %04X.%s %s", [script, position, size, opcode.opcodeId, opcode.methodName, parameters.join(', ')]);
	}
}