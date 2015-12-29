package com.vnvm.engine.dividead

import com.vnvm.common.*
import com.vnvm.common.async.Deferred
import com.vnvm.common.async.Promise
import com.vnvm.common.collection.xrange
import com.vnvm.common.error.InvalidOperationException
import com.vnvm.common.io.BinBytes
import com.vnvm.common.io.openAndReadAllAsync
import com.vnvm.common.script.Instruction2

class AB(public var game: Game) {
	public var scriptName: String = ""
	public var abOp: AB_OP = AB_OP(this)
	private var script: BinBytes = BinBytes(ByteArray(0))
	private var running: Boolean = true;
	public var throttle: Boolean = false

	fun loadScriptAsync(scriptName: String, scriptPos: Int = 0): Promise<Boolean> {
		return game.sg.openAndReadAllAsync("$scriptName.ab").then { script ->
			this.scriptName = scriptName;
			this.script = BinBytes(script);
			this.script.position = scriptPos;
			true
		}
	}

	fun parseParam(type: Char): Any? {
		return when (type) {
			'F' -> MathEx.clamp(script.readShort(), 0, 999).toInt();
			'2' -> script.readShort();
			'T', 'S', 's' -> script.readStringz();
			'P' -> script.readUnsignedInt();
			'c' -> script.readUnsignedByte();
			else -> throw InvalidOperationException("Invalid format type '$type'")
		}
	}

	private fun parseParams(format: String): List<Any?> {
		return format.map { parseParam(it) }
	}

	private fun executeSingleAsync(): Promise<Any> {
		var opcodePosition = this.script.position;
		var opcodeId = this.script.readUnsignedShort();
		var opcode = game.scriptOpcodes.getOpcodeWithId(opcodeId);

		var params = parseParams(opcode.format);
		var instruction = Instruction2(scriptName, opcode, params, opcodePosition, this.script.position - opcodePosition);
		var result = instruction.call(this.abOp);

		return Promise.returnPromiseOrResolvedPromise(result);
	}

	private fun hasMore() = this.script.position < this.script.length;

	/*
		public function execute():Void
		{
			while (running && hasMore())
			{
				if (executeSingleAsync(execute)) return;
			}
		}
		*/

	public fun executeAsync(e): Promise<Any> {
		var deferred = Deferred<Any>();
		fun executeStep() {
			executeSingleAsync().then { e ->
				executeStep();
			}
		}
		executeStep()
		return deferred.promise;
	}

	/*
		function getNameExt(name, ext) {
			return (split(name, ".")[0] + "." + ext).toupper();
		}
		*/

	public fun jump(offset: Int) {
		this.script.position = offset;
	}

	public fun end() {
		this.running = false;
	}

	public fun paintToColorAsync(color: List<Int>, time: TimeSpan): Promise<Any?> {
		var sprite = Sprite();
		GraphicUtils.drawSolidFilledRectWithBounds(sprite.graphics, 0, 0, 640, 480, 0x000000, 1.0);

		return game.gameSprite.animateAsync(time) { step ->
			game.front.copyPixels(game.back, game.back.rect, IPoint(0, 0))
			game.front.draw(sprite, null, new ColorTransform(1, 1, 1, step, 0, 0, 0, 0))
			if (step == 1) {
				game.back.copyPixels(game.front, game.back.rect, IPoint(0, 0))
			}
		});
	}

	public fun paintAsync(pos: Int, type: Int): Promise<Any> {
		if ((type == 0) || game.isSkipping()) {
			game.front.copyPixels(game.back, IRectangle(0, 0, 640, 480), IPoint(0, 0));
			return game.gameSprite.waitAsync(4.milliseconds);
		}

		val block_size = 16;
		val allRects = when (type) {
			4 -> (0 until block_size).map { n -> xrange(0, 640, block_size).map { x -> IRectangle(x + n, 0, 1, 480) } }
			2 -> (0 until block_size).map { n -> xrange(0, 480, block_size).map { IRectangle(0, it + n, 640, 1) } }
			3 -> xrange(0, 480, 4).map { y -> listOf(IRectangle(0, y, 640, 2), IRectangle(0, 480 - 2 - y, 640, 2)) }
			else -> listOf(listOf(IRectangle(0, 0, 640, 480)))
		}

		var lastExecutedRatio = 0.0;

		return game.gameSprite.animateAsync(if (game.isSkipping()) 0.03.seconds else 0.3.seconds) { ratio ->
			var _from = (allRects.size * lastExecutedRatio).toInt();
			var _to = (allRects.size * ratio).toInt();
			lastExecutedRatio = ratio;
			game.front.lock {
				for (index in _from until _to) {
					var rectangles = allRects[index];
					for (rectangle in rectangles) {
						game.front.copyPixels(game.back, rectangle, rectangle.topLeft);
					}
				}
			}
		}
	}
}
