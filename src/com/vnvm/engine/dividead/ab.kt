package com.vnvm.engine.dividead

class AB {
	public var scriptName: String;
	public var abOp: AB_OP;
	public var game: Game;
	private var script: ByteArray = null;
	private var running: Bool;
	public var throttle: Bool;

	public function new(game:Game)
	{
		this.game = game;
		this.script = null;
		this.abOp = new AB_OP(this);
		this.running = true;
	}

	fun loadScriptAsync(scriptName: String, scriptPos: Int = 0): IPromise<Bool> {
		return game.sg.openAndReadAllAsync('${scriptName}.ab').then(function(script:ByteArray):Bool {
			this.scriptName = scriptName;
			this.script = script;
			this.script.position = scriptPos;
			return true;
		});
	}

	fun parseParam(type: Char): Any? {
		return when (type) {
			'F' -> Std.int(MathEx.clamp(script.readShort(), 0, 999));
			'2' -> script.readShort();
			'T', 'S', 's' -> ByteArrayUtils.readStringz(script);
			'P' -> script.readUnsignedInt();
			'c' -> script.readUnsignedByte();
			else -> throw('Invalid format type \'$type\'');
		}
	}

	private fun parseParams(format: String): Array<Any?> {
		var params: Array<Dynamic> = [];
		for (n in 0 ... format.length) {
			var type: String = format.charAt(n);
			params.push(parseParam(type));
		}
		//Log.trace("Params: " + params);
		return params;
	}

	private fun executeSingleAsync(): IPromise<Dynamic> {
		var opcodePosition = this.script.position;
		var opcodeId = this.script.readUnsignedShort();
		var opcode = game.scriptOpcodes.getOpcodeWithId(opcodeId);

		var params: Array<Dynamic> = parseParams(opcode.format);
		var instruction = new Instruction2(scriptName, opcode, params, opcodePosition, this.script.position-opcodePosition);
		var result = instruction.call(this.abOp);

		return Promise.returnPromiseOrResolvedPromise(result);
	}

	private fun hasMore(): Boolean {
		return this.script.position < this.script.length;
	}

	/*
		public function execute():Void
		{
			while (running && hasMore())
			{
				if (executeSingleAsync(execute)) return;
			}
		}
		*/

	public function executeAsync(?e):IPromise<Dynamic>
	{
		var deferred = new Deferred<Dynamic>();
		function executeStep() {
			executeSingleAsync().then(function(?e) {
				executeStep();
			});
		}
		executeStep();
		return deferred.promise;
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

	public function paintToColorAsync(color:Array<Int>, time:Seconds):IPromise<Dynamic>
	{
		var sprite: Sprite = new Sprite();
		GraphicUtils.drawSolidFilledRectWithBounds(sprite.graphics, 0, 0, 640, 480, 0x000000, 1.0);

		return game.gameSprite.animateAsync(time, function(step:Float) {
			game.front.copyPixels(game.back, game.back.rect, new Point(0, 0));
			game.front.draw(sprite, null, new ColorTransform(1, 1, 1, step, 0, 0, 0, 0));
			if (step == 1) {
				game.back.copyPixels(game.front, game.back.rect, new Point(0, 0));
			}
		});
	}

	public function paintAsync(pos:Int, type:Int):IPromise<Dynamic>
	{
		var allRects: Array<Array<Rectangle>> = [];

		if ((type == 0) || game.isSkipping()) {
			game.front.copyPixels(game.back, new Rectangle(0, 0, 640, 480), new Point(0, 0));
			return game.gameSprite.waitAsync(new Milliseconds(4));
		}

		function addFlipSet(action:Array<Rectangle> -> Void):Void {
		var rects: Array<Rectangle> = [];
		action(rects);
		allRects.push(rects);
	}

		switch (type) {
			case 4: // Rows
			{
				var block_size: Int = 16;
				for (n in 0 ... block_size) {
				addFlipSet(function(rects:Array<Rectangle>) {
					for (x in IteratorUtilities.xrange(0, 640, block_size)) {
						rects.push(new Rectangle(x + n, 0, 1, 480));
					}
				});
			}
			}
			case 2: { // Columns
			var block_size: Int = 16;
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
			default:
			addFlipSet(function(rects:Array<Rectangle>) { rects.push(new Rectangle(0, 0, 640, 480)); });
		}

		var lastExecutedRatio = 0.0;

		return game.gameSprite.animateAsync(new Seconds(game.isSkipping() ? 0.03 : 0.3), function(ratio:Float) {
		var _from = Std.int(allRects.length * lastExecutedRatio);
		var _to = Std.int(allRects.length * ratio);
		lastExecutedRatio = ratio;
		game.front.lock();
		for (index in _from ... _to) {
		var rectangles = allRects[index];

		if (rectangles != null) {
			for (rectangle in rectangles) {
				game.front.copyPixels(game.back, rectangle, rectangle.topLeft);
			}
		}
	}
		game.front.unlock();
	});
	}
}
