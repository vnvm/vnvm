package common.script;
import haxe.Log;
import haxe.rtti.Meta;
import flash.errors.Error;

/**
 * ...
 * @author 
 */

class ScriptOpcodes 
{
	private var opcodesById:Map<Int, Opcode>;
	
	public function new():Void
	{
		opcodesById = new Map<Int, Opcode>();
	}
	
	static public function createWithClass(opcodesClass:Class<Dynamic>):ScriptOpcodes {
		var scriptOpcodes:ScriptOpcodes = new ScriptOpcodes();
		scriptOpcodes.initializeOpcodesById(opcodesClass);
		return scriptOpcodes;
	}
	
	private function initializeOpcodesById(opcodesClass:Class<Dynamic>) {
		var metas = Meta.getFields(opcodesClass);
		//BraveLog.trace(metas.JUMP_IF);
		
		for (key in Reflect.fields(metas)) {
			var metas:Dynamic = Reflect.getProperty(metas, key);
			var opcodeAttribute:Dynamic = metas.Opcode;
			var unimplemented:Bool = Reflect.hasField(metas, "Unimplemented");
			var untested:Bool = Reflect.hasField(metas, "Untested");
			
			//Log.trace(unimplemented);
			if (opcodeAttribute != null) {
				var id:Int = -1;
				var format:String = "";
				var description:String = "";
				
				// Format with object
				if (Reflect.isObject(opcodeAttribute[0])) {
					id = opcodeAttribute[0].id;
					format = opcodeAttribute[0].format;
					description = opcodeAttribute[0].description;
				}
				// Format with array
				else {
					id = opcodeAttribute[0];
					format = opcodeAttribute[Std.int(opcodeAttribute.length - 1)];
				}

				var opcode:Opcode = new Opcode(key, id, format, description, unimplemented, untested);
				//Log.trace(opcodeAttribute);
				//Log.trace(opcode);
				opcodesById.set(id, opcode);
			}
		}
	}

	public function getOpcodeWithId(id:Int) 
	{
		var opcode = opcodesById.get(id);
		if (opcode == null) throw(new Error('Unknown opcode ${id}'));
		return opcode;
	}
	
}