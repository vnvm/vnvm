package engines.dividead;
import common.Animation;
import common.ByteArrayUtils;
import common.GraphicUtils;
import common.IteratorUtilities;
import common.Log2;
import common.MathEx;
import common.script.Instruction;
import common.script.Opcode;
import common.StringEx;
import haxe.Log;
import haxe.Timer;
import nme.display.BitmapInt32;
import nme.display.Sprite;
import nme.geom.ColorTransform;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.utils.ByteArray;

class AB
{
	public var abOp:AB_OP;
	public var game:Game;
	private var script:ByteArray = null;
	private var running:Bool;
	public var throttle:Bool;
	
	public function new(game:Game)
	{
		this.game = game;
		this.script = null;
		this.abOp = new AB_OP(this);
		this.running = true;
	}
	
	public function loadScriptAsync(scriptName:String, scriptPos:Int = 0, done:Void -> Void):Void {
		game.sg.openAndReadAllAsync(Std.format("${scriptName}.ab"), function(script:ByteArray):Void {
			this.script = script;
			this.script.position = scriptPos;
			done();
		});
	}
	
	private function parseParam(continueCallback:Void -> Void, type:String):Dynamic {
		switch (type) {
			case '<': return continueCallback;
			case 'F': return Std.int(MathEx.clamp(script.readShort(), 0, 999));
			case '2': return script.readShort();
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
		var opcodePosition:Int = script.position;
		var opcodeId:Int = script.readUnsignedShort();
		var opcode:Opcode = game.scriptOpcodes.getOpcodeWithId(opcodeId);
		
		var params:Array<Dynamic> = parseParams(continueCallback, opcode.format);
		var isAsync:Bool = (opcode.format.indexOf("<") != -1);
		var instruction:Instruction = new Instruction(opcode, params, isAsync, opcodePosition, script.position - opcodePosition);
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
	
	public function paintToColorAsync(color:Array<Int>, time:Float, done:Void -> Void):Void
	{
		var sprite:Sprite = new Sprite();
		GraphicUtils.drawSolidFilledRectWithBounds(sprite.graphics, 0, 0, 640, 480, 0x000000, 1.0);
		
		Animation.animate(done, time, { }, { }, Animation.Linear, function(step:Float):Void {
			game.front.copyPixels(game.back, game.back.rect, new Point(0, 0));
			//sprite.alpha = step;
			game.front.draw(sprite, null, new ColorTransform(1, 1, 1, step, 0, 0, 0, 0));
		});
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
		
		if ((type == 0) || game.isSkipping()) {
			game.front.copyPixels(game.back, new Rectangle(0, 0, 640, 480), new Point(0, 0));
			Timer.delay(done, 4);
			return;
		}

		function addFlipSet(action:Array<Rectangle> -> Void):Void {
			var rects:Array<Rectangle> = [];
			action(rects);
			allRects.push(rects);
		}
		
		switch (type) {
			default: {
				addFlipSet(function(rects:Array<Rectangle>) { rects.push(new Rectangle(0, 0, 640, 480)); } );
			}
			case 4: { // Rows
				var block_size:Int = 16;
				for (n in 0 ... block_size) {
					addFlipSet(function(rects:Array<Rectangle>) { 
						for (x in IteratorUtilities.xrange(0, 640, block_size)) {
							rects.push(new Rectangle(x + n, 0, 1, 480));
						}
					});
				}
			}
			case 2: { // Columns
				var block_size:Int = 16;
				for (n in 0 ... block_size) {
					addFlipSet(function(rects:Array<Rectangle>) { 
						for (y in IteratorUtilities.xrange(0, 480, block_size)) {
							rects.push(new Rectangle(0, y + n, 640, 1));
						}
					});
				}
			}
			case 3: { // Courtine
				for (y in IteratorUtilities.xrange(0, 480, 4)) {
					addFlipSet(function(rects:Array<Rectangle>) { 
						rects.push(new Rectangle(0, y, 640, 2));
						rects.push(new Rectangle(0, 480 - 2 - y, 640, 2));
					});
				}
			}
		}
		
		var step = null;
		
		var frameTime:Int = MathEx.int_div(300, allRects.length);
		
		step = function() {
			if (allRects.length > 0) {
				var rectangles:Array<Rectangle> = allRects.shift();
				
				game.front.lock();
				for (rectangle in rectangles) {
					/*
					var pixels:ByteArray = game.back.getPixels(rectangle);
					pixels.position = 0;
					game.front.setPixels(rectangle, pixels);
					*/
					//Log.trace(Std.format("(${rectangle.x},${rectangle.y})-(${rectangle.width},${rectangle.height})"));
					game.front.copyPixels(game.back, rectangle, rectangle.topLeft);
				}
				game.front.unlock();
				
				Timer.delay(step, frameTime);
			} else {
				done();
			}
		};
		
		step();
	}
}
