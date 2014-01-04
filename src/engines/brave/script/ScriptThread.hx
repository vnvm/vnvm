package engines.brave.script;
import promhx.Promise;
import common.PromiseUtils;
import engines.brave.GameState;
import engines.brave.GameThreadState;
import haxe.Log;

/**
 * ...
 * @author 
 */

class ScriptThread implements IScriptThread
{
	public var gameState:GameState;
	public var gameThreadState:GameThreadState;
	private var scriptReader:ScriptReader;
	private var scriptInstructions:ScriptInstructions;

	public function new(gameState:GameState) 
	{
		this.gameState = gameState;
		this.gameThreadState = new GameThreadState();
		this.scriptInstructions = new ScriptInstructions(this);
	}
	
	public function setScript(script:Script):Void {
		clearStack();
		this.scriptReader = new ScriptReader(script, this.gameState.scriptOpcodes);
		this.scriptReader.position = 8;
		this.gameThreadState.eventId = 0;
	}

	/*
	public function execute():Void {
		//if (!executing || waitingAsync)
		//BraveLog.trace(Std.format("execute at ${scriptReader.position}"));
		{
			while (scriptReader.hasMoreInstructions()) {
				executing = true;
				waitingAsync = false;
				
				switch (executeNextInstruction()) {
					case -2:
						executing = false;
						//BraveLog.trace("/execute(-2)");
						return;
					case -3:
						waitingAsync = true;
						//BraveLog.trace("/execute(-3)");
						return;
				}
			}
			
			executing = false;
			waitingAsync = false;
		}
		//BraveLog.trace("/execute(0)");
	}
	*/
	public function executeAsync():Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		function executeStep() {
			if (scriptReader.hasMoreInstructions())
			{
				executeSingleAsync().then(function(?e) {
					executeStep();
				});
			}
			else
			{
				promise.resolve(null);
			}
		}
		executeStep();
		return promise;
	}

	private function executeSingleAsync():Promise<Dynamic>
	{
		var instruction = scriptReader.readInstruction(this);
		var result:Dynamic = instruction.call(scriptInstructions);
		return PromiseUtils.returnPromiseOrResolvedPromise(result);

		/*
		// End Script
		if (result == -1) {
			BraveLog.trace("End Executing");
			this.scriptReader.position = 8;
			return -1;
		}
		
		// Enable play
		if (result == -2) {
			BraveLog.trace("Enable play");
			return -2;
		}
		
		return instruction.async ? -3 : 0;
		*/
	}

	public function enablePlay()
	{

	}
	
	var stack:Array<Int>;
	
	public function pushStack(value:Int):Void { stack.push(value); }
	public function popStack():Int { return stack.pop(); }
	public function clearStack():Void { stack = []; }
	public function jump(offset:Int):Void { scriptReader.position = offset; }
	public function getVariable(index:Int):Variable { return gameState.variables[index]; }
	
	public function getSpecial(index:Int):Dynamic {
		//return new SpecialValue(index);
		//throw(new Error("Unimplemented"));
		switch (index) {
			case 0: return gameThreadState.eventId;
			//case 4: return 1;
			case 4: return 0;
			default:
				BraveLog.trace('getSpecial($index)');
				return 0;
		}
	}
}