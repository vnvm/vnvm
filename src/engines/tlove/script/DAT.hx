package engines.tlove.script;
import common.ByteArrayUtils;
import common.script.Instruction;
import common.script.Opcode;
import common.StringEx;
import engines.tlove.Game;
import haxe.Log;
import nme.errors.Error;
import nme.utils.ByteArray;
import nme.utils.Endian;

typedef StackItem = { script:String, position:Int };

class DAT
{
	public var game:Game;
	public var scriptName:String;
	public var script:ByteArray;
	public var datOp:DAT_OP;
	public var labels:Array<Int>;
	public var callStack:Array<StackItem>;
	
	public function new(game:Game)
	{
		this.game = game;
		this.datOp = new DAT_OP(this);
		this.script = ByteArrayUtils.newByteArray(Endian.BIG_ENDIAN);
		this.callStack = [];
	}
	
	public function loadAsync(name:String, done:Void -> Void):Void {
		var data:ByteArray;
		game.date.getBytesAsync(Std.format("$name.DAT"), function(data:ByteArray):Void {
			this.scriptName = name;
			data.endian = Endian.BIG_ENDIAN;
			var scriptStart:Int = data.readUnsignedShort();
			var labelCount:Int = Std.int((scriptStart - 2) / 2);
			
			this.labels = [];
			for (n in 0 ... labelCount) this.labels.push(data.readUnsignedShort());

			data.position = scriptStart;
			this.script = ByteArrayUtils.readByteArray(data, data.length - scriptStart);
			this.script.endian = Endian.BIG_ENDIAN;
			
			done();
		});
	}

	public function callLabel(label:Int):Void
	{
		callStack.push({ script: scriptName, position : script.position });
		jumpLabel(label);
	}
	
	public function returnLabel():Void {
		var item:StackItem = callStack.pop();
		script.position = item.position;
	}
	
	public function jumpLabel(label)
	{
		script.position = labels[label];
	}

	public function set_script(name:String)
	{
		/*
		printf("SCRIPT: '%s'\n", name);
		if (script_name != name) {
			stream = ::pak_dat[script_name = name];
			local script_start = (stream.readn('b') << 8 | stream.readn('b'));
			local stream_ptr = stream.readslice(script_start - 2);
			labels = [];
			//labels.push(0);
			while (!stream_ptr.eos()) labels.push(stream_ptr.readn('b') << 8 | stream_ptr.readn('b'));
			stream.seek(script_start);
			script = stream.readslice(stream.len() - stream.tell());
		}
		jump(0);
		*/
	}
	
	public function execute():Void
	{
		while (script.position < script.length)
		{
			//Log.trace(StringEx.sprintf("Script.single : %08X, %08X", [script.position, script.length]));
			if (executeSingle(execute)) {
				//Log.trace("Script.waitAsync");
				return;
			}
		}
		
		//Log.trace(StringEx.sprintf("Script.done : %08X, %08X", [script.position, script.length]));
	}

	private function executeSingle(done:Void -> Void):Bool
	{
		var instruction:Instruction = readInstruction(done);
		instruction.call(this.datOp);
		return instruction.async;
	}

	private function readInstruction(done:Void -> Void):Instruction
	{
		var instructionPosition:Int = script.position;
		var opcodeId:Int = script.readUnsignedByte();
		var instructionDataLength:Int = script.readUnsignedByte();
		if ((instructionDataLength & 0x80) != 0) {
			var newByte:Int = script.readUnsignedByte();
			instructionDataLength = newByte | ((instructionDataLength & 0x7F) << 8);
		}
		var params:ByteArray = ByteArrayUtils.readByteArray(script, instructionDataLength);
		var opcode:Opcode = game.scriptOpcodes.getOpcodeWithId(opcodeId);
		var parameters:Array<Dynamic> = readParameters(params, opcode, done);
		var async:Bool = (opcode.format.indexOf('<') >= 0);
		return new Instruction(opcode, parameters, async, instructionPosition, params.length + 1);
	}
	
	private function readParameters(paramsByteArray:ByteArray, opcode:Opcode, done:Void -> Void):Array<Dynamic>
	{
		var format:String = opcode.format;
		var params:Array<Dynamic> = [];
		for (n in 0 ... format.length) {
			var type:String = format.charAt(n);
			
			if (paramsByteArray.position >= paramsByteArray.length) throw(new Error("No more parameters! '" + opcode + "'"));
			
			switch (type) {
				case '<': params.push(done);
				case 'b': params.push(paramsByteArray.readUnsignedByte() != 0);
				case '1': params.push(paramsByteArray.readUnsignedByte());
				case '2': params.push((paramsByteArray.readUnsignedByte() << 8) | paramsByteArray.readUnsignedByte());
				case 's': params.push(ByteArrayUtils.readStringz(paramsByteArray));
				case '?': params.push(paramsByteArray);
				default: throw(new Error(Std.format("Invalid format type '$type'")));
			}
		}
		return params;
	}
}
