package engines.will;

import common.script.Instruction2;
import haxe.Json;
import common.script.Opcode;
import lang.exceptions.NotImplementedException;
import promhx.Promise;
import haxe.Log;
import common.script.ScriptOpcodes;
import engines.will.script.RIO_OP;
import engines.will.script.RIO_OP_PW;
import common.ByteArrayUtils;
import flash.utils.ByteArray;

class RIO implements IScript
{
	private var willResourceManager:WillResourceManager;
	private var gameState:GameState;
	private var scriptName:String;
	private var scriptBytes:ByteArray;
	private var opcodes:RIO_OP_PW;
	private var scriptOpcodes:ScriptOpcodes;
	private var opcodeReader:OpcodeReader;

	public function new(scene:IScene, willResourceManager:WillResourceManager)
	{
		this.gameState = new GameState();
		this.willResourceManager = willResourceManager;
		this.opcodes = new RIO_OP_PW(scene, gameState, this);
		this.scriptOpcodes = ScriptOpcodes.createWithClass(RIO_OP_PW);
		this.opcodeReader = new OpcodeReader();
	}

	public function executeAsync(?e):Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		function executeStep() {
			executeSingleAsync().then(function(?e) {
				executeStep();
			});
		}
		executeStep();
		return promise;
	}

	public function executeSingleAsync():Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		var opcodePosition = this.scriptBytes.position;
		var opcodeId = this.scriptBytes.readUnsignedByte();
		var opcode = scriptOpcodes.getOpcodeWithId(opcodeId);
		Log.trace('*************************************');
		Log.trace(opcode);
		var params = this.opcodeReader.read(opcode.format, scriptBytes);
		var opcodeLength = this.scriptBytes.position - opcodePosition;
		Log.trace(params);
		var instruction = new Instruction2(scriptName, opcode, params, opcodePosition, opcodeLength);
		Log.trace(instruction);
		var result = instruction.call(opcodes);
		Log.trace(result);
		if (Std.is(result, Promise))
		{
			result.then(function(e)
			{
				promise.resolve(null);
			});
		}
		else
		{
			promise.resolve(null);
		}
		return promise;
	}

	public function loadFromByteArray(encryptedScript:ByteArray, name:String)
	{
		this.scriptName = name;
		this.scriptBytes = ByteArrayUtils.rotateBytesRight(encryptedScript, 2);
		this.scriptBytes.position = 0;
	}

	public function loadAsync(name:String):Promise<Dynamic>
	{
		return willResourceManager.readAllBytesAsync('$name.WSC').then(function(data:ByteArray) {
			loadFromByteArray(data, name);
		});
	}

	public function jumpRelative(offset:Int):Void
	{
		this.scriptBytes.position += offset;
	}
}

interface INode
{
	function read(data:ByteArray, state:NodeState):Void;
}

class NodeState
{
	public var result:Array<Dynamic>;
	public var lastKind:Int = 0;

	public function new()
	{
		result = new Array<Dynamic>();
	}
}

class NodeContainer implements INode
{
	private var childs:Array<INode>;

	public function new()
	{
		childs = new Array<INode>();
	}

	public function addChild(node:INode)
	{
		childs.push(node);
	}

	public function read(data:ByteArray, state:NodeState)
	{
		for (child in childs) child.read(data, state);
	}
}

class NodeItem implements INode
{
	private var char:String;

	public function new(char:String)
	{
		this.char = char;
	}

	public function read(data:ByteArray, state:NodeState):Void
	{
		switch (this.char)
		{
			case '.': if (data.readUnsignedByte() != 0) throw("WARNING: ignored parameter has a value different than zero!");
			case '1': state.result.push(data.readUnsignedByte());
			case '2': state.result.push(data.readShort());
			case 'f': state.result.push(data.readUnsignedShort());
			case 'l': state.result.push(data.readInt());
			case 'o': state.result.push(data.readUnsignedByte()); // SET_OP
			case 's': state.result.push(ByteArrayUtils.readStringz(data));
			case 't': state.result.push(ByteArrayUtils.readStringz(data));
			case 'k':
			{
				var value = data.readUnsignedByte();
				state.result.push(value);
				state.lastKind = value;
			}
			case 'F':
				if (state.lastKind != 0) {
					state.result.push(data.readUnsignedShort());
				} else {
					state.result.push(data.readUnsignedShort());
				}
			case 'O':
			{
				var value = data.readUnsignedByte();
				state.result.push(value);
				state.lastKind = value >> 4;
			}
			default: throw(new NotImplementedException('Not implemented ${this.char}'));
		}
	}
}

class NodeRepeat extends NodeContainer
{
	override public function read(data:ByteArray, state:NodeState):Void
	{
		throw(new NotImplementedException());
		//for (n in 0 ... 2) super.read(data, state);
	}
}

class OpcodeReader
{
	public function new()
	{

	}

	public function read(format:String, data:ByteArray):Array<Dynamic>
	{
		var state = new NodeState();
		formatToAst(format).read(data, state);
		return state.result;
	}

	public function formatToAst(format:String):INode
	{
		var node = new NodeContainer();
		var nodeStack = new Array<NodeContainer>();

		for (char in format.split(''))
		{
			switch (char)
			{
				case '[':
					nodeStack.push(node);
					node = new NodeRepeat();
				case ']':
					node = nodeStack.pop();
				default:
					node.addChild(new NodeItem(char));
			}
		}

		return node;
	}
}