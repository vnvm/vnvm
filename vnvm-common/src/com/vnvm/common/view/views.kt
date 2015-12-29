package com.vnvm.common.view

import com.vnvm.common.async.Signal
import com.vnvm.common.error.noImpl
import com.vnvm.common.image.BitmapData

open class DisplayObject {
	var x: Double = 0.0
	var y: Double = 0.0
}

open class Sprite : DisplayObject() {
	fun addChild(child: DisplayObject): Unit {
		noImpl
	}

	fun removeChildren(): Unit {
		noImpl
	}
}

enum class PixelSnapping { AUTO }

class Bitmap(val data: BitmapData, val snapping: PixelSnapping = PixelSnapping.AUTO, val smooth: Boolean = true) : DisplayObject() {

}

open class TextField : DisplayObject() {
	var defaultTextFormat: TextFormat = TextFormat("Arial", 10, -1)
	var width: Double = 100.0
	var height: Double = 100.0
	var text: String = ""
	var selectable: Boolean = false
	var textColor: Int = -1
}

enum class Keys {
	Control
}

object GameInput {
	val onClick: Signal<Unit> get() = noImpl
	val onKeyPress: Signal<Keys> get() = noImpl

	fun isPressing(key: Keys): Boolean = noImpl
}

data class TextFormat(val face: String, val size: Int, val color: Int) {

}