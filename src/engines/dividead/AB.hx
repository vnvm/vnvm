package engines.dividead;
import common.Animation;
import common.ByteArrayUtils;
import common.IteratorUtilities;
import common.script.Instruction;
import common.script.Opcode;
import common.StringEx;
import haxe.Log;
import haxe.Timer;
import nme.display.BitmapInt32;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.utils.ByteArray;

class AB
{
	public var abOp:AB_OP;
	public var game:Game;
	private var script:ByteArray = null;
	private var running:Bool;
	
	public function new(game:Game)
	{
		this.game = game;
		this.script = null;
		this.abOp = new AB_OP(this);
		this.running = true;
	}
	
	public function loadScriptAsync(scriptName:String, done:Void -> Void):Void {
		game.sg.openAndReadAllAsync(Std.format("${scriptName}.ab"), function(script:ByteArray):Void {
			this.script = script;
			done();
		});
	}
	
	private function parseParam(continueCallback:Void -> Void, type:String):Dynamic {
		switch (type) {
			case '<': return continueCallback;
			case 'F', '2': return script.readShort();
			case 'T', 'S', 's': return ByteArrayUtils.readStringz(script);
			case 'P': return script.readUnsignedInt();
			case 'c': return script.readUnsignedByte();
			default: throw(Std.format("Invalid format type '$type'"));
		}
	}
		
	private function parseParams(continueCallback:Void -> Void, format:String):Array<Dynamic>
	{
		var params:Array<Dynamic> = [];
		for (n in 0 ... format.length) {
			var type:String = format.charAt(n);
			params.push(parseParam(continueCallback, type));
		}
		//Log.trace("Params: " + params);
		return params;
	}
	
	private function executeSingle(continueCallback:Void -> Void):Bool
	{
		var opcodeId:Int = script.readUnsignedShort();
		var opcode:Opcode = game.scriptOpcodes.getOpcodeWithId(opcodeId);
		
		var params:Array<Dynamic> = parseParams(continueCallback, opcode.format);
		var isAsync:Bool = (opcode.format.indexOf("<") != -1);
		var instruction:Instruction = new Instruction(opcode, params, isAsync);
		instruction.call(this.abOp);
		return isAsync;
	}
	
	private function hasMore():Bool {
		return script.position < script.length;
	}
	
	public function execute():Void
	{
		while (running && hasMore())
		{
			if (executeSingle(execute)) return;
		}
	}
	
	/*
	function getNameExt(name, ext) {
		return (split(name, ".")[0] + "." + ext).toupper();
	}
	*/
	
	public function jump(offset:Int)
	{
		this.script.position = offset;
	}
	
	public function end()
	{
		this.running = false;
	}
	
	public function paint_to_color(color, time)
	{
		/*
		if (throttle) return;

		var steps = 60.0;
		
		var screen2 = ::screen.dup();
		
		for (local n = 0; n < steps; n++) {
			::screen.clear(color);
			screen2.draw(screen, 0, 0, 1.0 - (n.tofloat() / steps));
			Screen.flip();
			Screen.frame(60);
		}
		
		::screen.clear(color);
		Screen.flip();
		Screen.frame(60);
		*/
	}
	
	public function paintAsync(pos:Int, type:Int, done:Void -> Void):Void
	{
		var allRects:Array<Array<Rectangle>> = [];

		function addFlipSet(action:Array<Rectangle> -> Void):Void {
			var rects:Array<Rectangle> = [];
			action(rects);
			allRects.push(rects);
		}
		
		switch (type) {
			default: {
				addFlipSet(function(rects:Array<Rectangle>) { rects.push(new Rectangle(0, 0, 640, 480)); } );
			}
			case 2: {
				var block_size:Int = 16;
				for (n in 0 ... block_size) {
					addFlipSet(function(rects:Array<Rectangle>) { 
						for (x in IteratorUtilities.xrange(0, 640, block_size)) {
							rects.push(new Rectangle(x + n, 0, 1, 480));
						}
					});
				}
			}
			case 3: {
				var block_size:Int = 16;
				for (n in 0 ... block_size) {
					addFlipSet(function(rects:Array<Rectangle>) { 
						for (y in IteratorUtilities.xrange(0, 480, block_size)) {
							rects.push(new Rectangle(0, y + n, 640, 1));
						}
					});
				}
			}
		}
		
		var step = null;
		
		step = function() {
			if (allRects.length > 0) {
				var rectangles:Array<Rectangle> = allRects.shift();
				
				game.front.lock();
				for (rectangle in rectangles) {
					game.front.copyPixels(game.back, rectangle, rectangle.topLeft);
				}
				game.front.unlock();
				
				Timer.delay(step, 20);
			} else {
				done();
			}
		};
		
		step();
		
		//Timer.delay(done, 1000);
		/*
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
		*/
	}
}
