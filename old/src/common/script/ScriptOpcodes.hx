package common.script;
import haxe.rtti.Meta;
import flash.errors.Error;

class ScriptOpcodes {
    private var opcodesById = new Map<Int, Opcode>();

    public function new():Void { }

    static public function createWithClass(opcodesClass:Class<Dynamic>):ScriptOpcodes {
        var scriptOpcodes:ScriptOpcodes = new ScriptOpcodes();
        scriptOpcodes.initializeOpcodesById(opcodesClass);
        return scriptOpcodes;
    }

    private function initializeOpcodesById(opcodesClass:Class<Dynamic>):Void {
        if (Type.getSuperClass(opcodesClass) != null) initializeOpcodesById(Type.getSuperClass(opcodesClass));

        var metas = Meta.getFields(opcodesClass);

//BraveLog.trace(metas.JUMP_IF);

//Log.trace(Reflect.fields(metas));
//Log.trace(Type.getInstanceFields(opcodesClass));

        for (key in Reflect.fields(metas)) {
            var metas:Dynamic = Reflect.getProperty(metas, key);
            var opcodeAttribute:Dynamic = metas.Opcode;
            var unimplemented:Bool = Reflect.hasField(metas, "Unimplemented");
            var untested:Bool = Reflect.hasField(metas, "Untested");
            var skipLog:Bool = Reflect.hasField(metas, "SkipLog");

            if (opcodeAttribute != null) {
                var id:Int = -1;
                var format:String = "";
                var description:String = "";

                if (Reflect.isObject(opcodeAttribute[0])) {
                    id = opcodeAttribute[0].id;
                    format = opcodeAttribute[0].format;
                    description = opcodeAttribute[0].description;
                }
                else {
                    id = opcodeAttribute[0];
                    format = opcodeAttribute[Std.int(opcodeAttribute.length - 1)];
                }

                var opcode:Opcode = new Opcode(key, id, format, description, unimplemented, untested, skipLog);
                opcodesById.set(id, opcode);
            }
        }
    }

    public function getOpcodeWithId(id:Int):Opcode {
        var opcode = opcodesById.get(id);
        if (opcode == null) throw(new Error('Unknown opcode ${id}'));
        return opcode;
    }

}