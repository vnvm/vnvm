package com.vnvm.engine.dividead

import com.vnvm.common.*
import com.vnvm.common.async.Promise
import com.vnvm.common.collection.xrange
import com.vnvm.common.error.InvalidOperationException
import com.vnvm.common.image.BColor
import com.vnvm.common.image.BitmapData
import com.vnvm.common.image.toInt
import com.vnvm.common.io.BinBytes
import com.vnvm.common.script.Instruction2

class AB(public var game: Game) {
	public var scriptName = ""
	public var abOp = AB_OP(this)
	private var script = BinBytes(ByteArray(0))
	private var running = true
	public var throttle = false

	fun loadScriptAsync(scriptName: String, scriptPos: Int = 0): Promise<Boolean> {
		return game.sg["$scriptName.ab"].readAllAsync().then { script ->
			this.scriptName = scriptName
			this.script = BinBytes(script)
			this.script.position = scriptPos
			true
		}
	}

	fun parseParam(type: Char): Any {
		return when (type) {
			'F' -> script.readShort().clamp(0, 999)
			'2' -> script.readShort()
			'T', 'S', 's' -> script.readStringz()
			'P' -> script.readUnsignedInt()
			'c' -> script.readUnsignedByte()
			else -> throw InvalidOperationException("Invalid format type '$type'")
		}
	}

	private fun parseParams(format: String): List<Any> {
		return format.map { parseParam(it) }
	}

	private fun executeSingleAsync(): Promise<Any> {
		var opcodePosition = this.script.position
		var opcodeId = this.script.readUnsignedShort()
		var opcode = game.scriptOpcodes[opcodeId]

		var params = parseParams(opcode.info.format).toTypedArray()
		var instruction = Instruction2(scriptName, opcode, params, opcodePosition, this.script.position - opcodePosition)
		var result = instruction.call(this.abOp)

		return Promise.resolved(result ?: Unit)
	}

	private fun hasMore() = this.script.position < this.script.length

	/*
	public function execute():Void {
		while (running && hasMore()) {
			if (executeSingleAsync(execute)) return
		}
	}
	*/

	public fun executeAsync(): Promise<Any> {
		var deferred = Promise.Deferred<Any>()
		fun executeStep() {
			executeSingleAsync().then { e ->
				executeStep()
			}
		}
		executeStep()
		return deferred.promise
	}

	/*
	function getNameExt(name, ext) {
		return (split(name, ".")[0] + "." + ext).toupper()
	}
	*/

	public fun jump(offset: Int) {
		this.script.position = offset
	}

	public fun end() {
		this.running = false
	}

	public fun paintToColorAsync(color: BColor, time: TimeSpan): Promise<Unit> {
		val blackSprite = BitmapData(640, 480, true, color.toInt())

		return game.gameSprite.tweens.animateAsync(time) { step ->
			game.front.copyPixels(game.back, game.back.rect, IPoint(0, 0))
			game.front.draw(blackSprite, blackSprite.rect, 0, 0, step)
			if (step == 1.0) {
				game.back.copyPixels(game.front, game.back.rect, IPoint(0, 0))
			}
		}
	}

	public fun paintAsync(pos: Int, type: Int): Promise<Unit> {
		//game.front.copyPixels(game.back, game.back.rect, IPoint(0, 0))
		//return Promise.unit

		if ((type == 0) || game.isSkipping()) {
			game.front.copyPixels(game.back, game.back.rect, IPoint(0, 0))
			return game.gameSprite.timers.waitAsync(4.milliseconds)
		}

		val blockSize = 16
		val allRects = when (type) {
			4 -> (0 until blockSize).map { n -> xrange(0, 640, blockSize).map { x -> IRectangle(x + n, 0, 1, 480) } }
			2 -> (0 until blockSize).map { n -> xrange(0, 480, blockSize).map { IRectangle(0, it + n, 640, 1) } }
			3 -> xrange(0, 480, 4).map { y -> listOf(IRectangle(0, y, 640, 2), IRectangle(0, 480 - 2 - y, 640, 2)) }
			else -> listOf(listOf(IRectangle(0, 0, 640, 480)))
		}

		var lastExecutedRatio = 0.0

		return game.gameSprite.tweens.animateAsync(if (game.isSkipping()) 0.03.seconds else 0.3.seconds) { ratio ->
			var _from = (allRects.size * lastExecutedRatio).toInt()
			var _to = (allRects.size * ratio).toInt()
			lastExecutedRatio = ratio
			game.front.lock {
				for (index in _from until _to) {
					var rectangles = allRects[index]
					for (rectangle in rectangles) {
						game.front.copyPixels(game.back, rectangle, rectangle.topLeft)
					}
				}
			}
		}
	}
}
