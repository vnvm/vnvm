package com.vnvm.common.view

import com.vnvm.common.TimeSpan
import com.vnvm.common.async.EventLoop
import com.vnvm.common.async.Promise
import com.vnvm.common.async.Signal
import com.vnvm.common.clamp
import com.vnvm.common.clamp01
import com.vnvm.common.image.BitmapData
import com.vnvm.graphics.*

interface Updatable {
	fun update(dt: Int): Unit
}

class Views(val graphics: GraphicsContext, val input: InputContext, val window: WindowContext) : Updatable {
	public val root = Sprite()
	val usedBitmapDatas = hashSetOf<BitmapData>()
	val lastFrameBitmapDatas = hashSetOf<BitmapData>()

	var frames = 0

	fun render(context: RenderContext) {
		if (frames++ == 0) {
			usedBitmapDatas.clear()
		}
		context.begin()
		root.render(this, context)
		context.end()
		lastFrameBitmapDatas.addAll(usedBitmapDatas)
		if (frames >= 60) {
			frames = 0
			val texturesToRemove = lastFrameBitmapDatas.subtract(usedBitmapDatas)
			if (texturesToRemove.isNotEmpty()) {
				println("textures to remove!")
				for (tex in texturesToRemove) {
					tex.texture?.texture?.dispose()
					tex.texture = null
				}
				lastFrameBitmapDatas.clear()
			}
		}
		input.onEvent.add { root.onEvent(it) }
	}

	private var lastTime: Long = System.currentTimeMillis()
	fun frame() {
		val currentTime = System.currentTimeMillis()
		val elapsed = (currentTime - lastTime).toInt()
		val elapsedNormalized = elapsed.clamp(0, 40)
		update(elapsedNormalized)
		EventLoop.frame()
		lastTime = currentTime
	}

	override fun update(dt: Int) {
		root.update(dt)
	}

	fun isPressing(key: Int): Boolean {
		return false
	}

	init {
		root.keys.onKeyDown.add {
			when (it.code.toChar()) {
				'd' -> root.dump()
			}
		}
	}
}

class UpdatableGroup : Updatable {
	private val items = arrayListOf<Updatable>()

	fun add(updatable: Updatable) {
		items.add(updatable)
	}

	fun remove(updatable: Updatable) {
		items.remove(updatable)
	}

	override fun update(dt: Int) {
		for (n in 0 until items.size) items[n].update(dt)
	}
}


class Timers : Updatable {
	private val group = UpdatableGroup()


	override fun update(dt: Int) {
		group.update(dt)
	}

	fun waitAsync(time: TimeSpan): Promise<Unit> {
		val deferred = Promise.Deferred<Unit>()
		val totalTime = time.milliseconds
		var item: Updatable? = null
		item = object : Updatable {
			var elapsedTime = 0
			override fun update(dt: Int) {
				elapsedTime += dt
				if (elapsedTime >= totalTime) {
					group.remove(item!!)
					deferred.resolve(Unit)
				}
			}
		}
		group.add(item)
		return deferred.promise
	}
}

class Tweens : Updatable {
	private val group = UpdatableGroup()

	override fun update(dt: Int) {
		group.update(dt)
	}

	fun animateAsync(time: TimeSpan, step: (ratio: Double) -> Unit): Promise<Unit> {
		val deferred = Promise.Deferred<Unit>()
		val totalTime = time.milliseconds
		var item: Updatable? = null
		step(0.0)
		item = object : Updatable {
			var elapsedTime = 0
			override fun update(dt: Int) {
				elapsedTime += dt
				val ratio = (elapsedTime.toDouble() / totalTime.toDouble()).clamp01()
				step(ratio)
				if (ratio >= 1.0) {
					group.remove(item!!)
					deferred.resolve(Unit)
				}
			}
		}
		group.add(item)
		return deferred.promise
	}
}

class Mice {
	val onMouseClick = Signal<MouseClickEvent>()

	fun onEvent(event: MouseEvent) {
		when (event) {
			is MouseClickEvent -> onMouseClick.dispatch(event)
		}
	}
}

class KeyHandler {
	val onKeyDown = Signal<KeyDownEvent>()
	val onKeyPress = Signal<KeyPressEvent>()
	val onKeyUp = Signal<KeyUpEvent>()

	fun onEvent(event: KeyEvent) {
		when (event) {
			is KeyDownEvent -> onKeyDown.dispatch(event)
			is KeyPressEvent -> onKeyPress.dispatch(event)
			is KeyUpEvent -> onKeyUp.dispatch(event)
		}
	}
}

open class DisplayObject {
	var x = 0.0
	var y = 0.0
	var alpha = 1.0
	var speed = 1.0
	var scaleX = 1.0
	var scaleY = 1.0
	var rotation = 0.0
	var visible = true
	private var updatables = arrayListOf<Updatable>()
	val timers: Timers by lazy { addUpdatable(Timers()) }
	val tweens: Tweens by lazy { addUpdatable(Tweens()) }
	val mice: Mice by lazy { Mice() }
	val keys: KeyHandler by lazy { KeyHandler() }

	fun <T : Updatable> addUpdatable(updatable: T): T {
		updatables.add(updatable)
		return updatable
	}

	fun addUpdatable(updatable: (dt: Int) -> Unit) = addUpdatable(object : Updatable {
		override fun update(dt: Int) = updatable(dt)
	})

	fun update(dt: Int): Unit {
		if (visible == false) return
		val dt = (dt * speed).toInt()
		updateInternal(dt)
		for (n in 0 until updatables.size) updatables[n].update(dt)
	}

	fun render(views: Views, context: RenderContext): Unit {
		context.save()
		if (x != 0.0 || y != 0.0) context.translate(x, y)
		if (scaleX != 1.0 || scaleY != 1.0) context.scale(scaleX, scaleY)
		if (rotation != 0.0) context.rotate(rotation)
		renderInternal(views, context)
		context.restore()
	}

	open fun renderInternal(views: Views, context: RenderContext): Unit {
	}

	open protected fun updateInternal(dt: Int) {
	}

	fun onEvent(event: Event) {
		if (visible == false) return
		if (event is MouseEvent) mice.onEvent(event)
		if (event is KeyEvent) keys.onEvent(event)
		onEventInternal(event)
	}

	open fun onEventInternal(event: Event) {
	}

	override fun toString():String {
		var out = this.javaClass.simpleName
		if (x != 0.0 || y != 0.0) out += " XY($x, $y)"
		if (scaleX != 1.0 || scaleY != 1.0) out += " SXY($scaleX, $scaleY)"
		if (rotation != 0.0) out += " ROT($rotation)"
		return out
	}
}

open class Sprite : DisplayObject() {
	internal val children = arrayListOf<DisplayObject>()

	fun addChild(child: DisplayObject): Unit {
		children.add(child)
	}

	fun removeChildren(): Unit {
		children.clear()
	}

	override fun renderInternal(views: Views, context: RenderContext): Unit {
		for (n in 0 until children.size) children[n].render(views, context)
	}

	override protected fun updateInternal(dt: Int) {
		for (n in 0 until children.size) children[n].update(dt)
	}

	override fun onEventInternal(event: Event) {
		for (n in 0 until children.size) children[n].onEvent(event)
	}
}

enum class PixelSnapping { AUTO }

class Bitmap(val data: BitmapData, val snapping: PixelSnapping = PixelSnapping.AUTO, val smooth: Boolean = true) : DisplayObject() {
	var width = data.width
	var height = data.height

	override fun renderInternal(views: Views, context: RenderContext) {
		views.usedBitmapDatas.add(data)
		if (data.texture == null) {
			data.texture = context.createTexture(data)
		}
		context.quad(data.texture!!, width.toDouble(), height.toDouble())
	}
}

open class TextField : DisplayObject() {
	var defaultTextFormat: TextFormat = TextFormat("Arial", 10, -1)
	var width: Double = 100.0
	var height: Double = 100.0
	var text: String = ""
	var selectable: Boolean = false
	var textColor: Int = -1

	override fun renderInternal(views: Views, context: RenderContext) {
		context.text(text)
	}
}

data class TextFormat(val face: String, val size: Int, val color: Int) {

}

fun DisplayObject.dump(pre: String = "") {
	when (this) {
		is Sprite -> {
			println("$pre$this {")
			for (child in this.children) child.dump("$pre  ")
			println("$pre}")
		}
		else -> println("$pre$this")
	}
}