package engines.dividead;
import nme.display.BitmapInt32;
import nme.utils.ByteArray;

class AB
{
	static ops = { };

	var gameState:GameState;
	var script:ByteArray = null;
	var flags:Array = [];
	var options:Array = [];
	var map_options:Array = [];
	var running:Bool = true;
	var vfs = null;
	var name:String = null;
	var title:String = "";
	var throttle:Bool = false;
	
	public function new(gameState:GameState)
	{
		this.gameState = gameState;
		this.flags = [];
		for (n in 0 ... 1000) flags.push(0);
		this.script = null;
	}
	
	public function loadScriptAsync(scriptName:String, done:Void -> Void):Void {
		gameState.sg.openAndReadAllAsync(scriptName, function(script:ByteArray):Void {
			this.script = script;
			done();
		});
	}
		
	private function parseParams(continueCallback:Void -> Void, format:String):Array<Dynamic>
	{
		var params:Array<Dynamic> = [];
		for (m in 0 ... format.length) {
			var type:String = format.charAt(n);
			switch (type) {
				case '<': params.push(continueCallback);
				case 'F': case '2': params.push(script.readn('w'));
				case 'T': case 'S': case 's': params.push(script.readstringz(-1));
				case 'P': params.push(script.readn('i'));
				case 'c': params.push(script.readn('c'));
				default: throw(Std.format("Invalid format type '$type'"));
			}
		}
		return params;
	}
	
	private function executeSingle(continueCallback:Void -> Void):Bool
	{
		var op:Int = script.readUnsignedShort();
		if (!(op in AB.ops)) throw(::format("Unknown OP 0x%02X", op));
		local cop = AB.ops[op];
		local params = parseParams(continueCallback, cop.format);
		//printf("Executing... %s\n", cop.name);
		if (cop.name in AB_OP) {
			params.insert(0, this);
			AB_OP[cop.name].acall(params);
		} else {
			printf("Not implemented AB_OP.'%s'\n", cop.name);
		}
	}
	
	private function hasMore():Bool {
		return script.position < script.length;
	}
	
	public function execute()
	{
		while (hasMore())
		{
			if (!executeSingle(execute)) return;
		}
	}
	
	function getNameExt(name, ext) {
		return (split(name, ".")[0] + "." + ext).toupper();
	}
	
	public function jump(offset:Int)
	{
		this.script.position = offset;
	}
	
	public function end()
	{
		running = false;
	}
	
	public function paint_to_color(color, time)
	{
		if (throttle) return;

		local steps = 60.0;
		
		local screen2 = ::screen.dup();
		
		for (local n = 0; n < steps; n++) {
			::screen.clear(color);
			screen2.draw(screen, 0, 0, 1.0 - (n.tofloat() / steps));
			Screen.flip();
			Screen.frame(60);
		}
		
		::screen.clear(color);
		Screen.flip();
		Screen.frame(60);
	}
	
	public function paint(pos, type)
	{
		if (throttle) type = 0;
		
		local clips = [];
		
		local draw_row = function(clips, y) { clips.push([0, y, 640, 1]); };
		local draw_col = function(clips, x) { clips.push([x, 0, 1, 480]); };
		local flip = function(clips, fps) {
			Screen.flip(clips);
			Screen.frame(fps);
			clips.clear();
		}
		switch (type) {
			case 0:
				flip(clips, 10000);
			break;
			case 0:
			case 2:
				local block_size = 16;
				for (local n = 0; n < block_size; n++) {
					for (local x = 0; x < 640; x += block_size) draw_col(clips, x + n);
					flip(clips, 60);
				}
			break;
			case 3:
				for (local y = 0; y < 240; y++) {
					draw_row(clips, y * 2);
					draw_row(clips, 480 - y * 2 - 1);
					if (y % 8 == 0) flip(clips, 60);
				}
			break;
			case 1:
				flip(clips, 10000);
			break;
			default:
				printf("Unknown paint type %d\n", type);
				flip(clips, 10000);
			break;
		}
	}
}
