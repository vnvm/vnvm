package com.vnvm.graphics

import com.vnvm.common.Disposable
import com.vnvm.common.IRectangle
import com.vnvm.common.async.Signal
import com.vnvm.common.image.BitmapData
import com.vnvm.common.image.Color

interface RenderContext : GraphicsContext {
	fun begin(): Unit
	fun save(): Unit
	fun restore(): Unit
	fun rotate(radians: Double): Unit
	fun translate(x: Double, y: Double): Unit
	fun scale(sx: Double, sy: Double = sx): Unit
	var color: Color
	fun quad(tex: TextureSlice, x:Double = 0.0, y:Double = 0.0, width: Double = tex.width.toDouble(), height: Double = tex.height.toDouble())
	fun end(): Unit
}

interface GraphicsContext {
	fun createTexture(data: BitmapData): TextureSlice
}

interface Event
interface MouseEvent : Event {
	var x: Double
	var y: Double
}

interface KeyEvent : Event {
	var code: Int
}

data class MouseMovedEvent(override var x: Double, override var y: Double) : MouseEvent
data class MouseClickEvent(override var x: Double, override var y: Double, var button: Int) : MouseEvent
data class KeyPressEvent(override var code: Int) : KeyEvent
data class KeyDownEvent(override var code: Int) : KeyEvent
data class KeyUpEvent(override var code: Int) : KeyEvent


object Keys {
	val INVALID = -1
	//val Control = 17
	val CONTROL_LEFT = 113
	val CONTROL_RIGHT = 114

	val UP = 19
	val DOWN = 20
	val LEFT = 21
	val RIGHT = 22
	/*
	val Backspace = 8
	val Tab = 9
	val Enter = 13
	val Shift = 16
	val CapsLock = 20
	val Esc = 27
	val Spacebar = 32
	val PageUp = 33
	val PageDown = 34
	val End = 35
	val Home = 36
	val Left = 37
	val Up = 38
	val Right = 39
	val Down = 40
	val Insert = 45
	val Delete = 46
	val NumLock = 144
	val ScrLk = 145
	val Pause_Break = 19

	val A = 65
	val B = 66
	val C = 67
	val D = 68
	val E = 69
	val F = 70
	val G = 71
	val H = 72
	val I = 73
	val J = 74
	val K = 75
	val L = 76
	val M = 77
	val N = 78
	val O = 79
	val P = 80
	val Q = 81
	val R = 82
	val S = 83
	val T = 84
	val U = 85
	val V = 86
	val W = 87
	val X = 88
	val Y = 89
	val Z = 90

	val _0 = 48
	val _1 = 49
	val _2 = 50
	val _3 = 51
	val _4 = 52
	val _5 = 53
	val _6 = 54
	val _7 = 55
	val _8 = 56
	val _9 = 57
	val F1 = 112
	val F2 = 113
	val F3 = 114
	val F4 = 115
	val F5 = 116
	val F6 = 117
	val F7 = 118
	val F8 = 119
	val F9 = 120
	val F10 = 121
	val F11 = 122
	val F12 = 123
	val F13 = 124
	val F14 = 125
	val F15 = 126
	val Numpad0 = 96
	val Numpad1 = 97
	val Numpad2 = 98
	val Numpad3 = 99
	val Numpad4 = 100
	val Numpad5 = 101
	val Numpad6 = 102
	val Numpad7 = 103
	val Numpad8 = 104
	val Numpad9 = 105
	val NumpadMultiply = 106
	val NumpadAdd = 107
	val NumpadEnter = 13
	val NumpadSubtract = 109
	val NumpadDecimal = 110
	val NumpadDivide = 111
	val SemicolonDoubleColon = 186
	val EqualPlus = 187
	val MinusUnderscore = 189
	val SlashQuestionMark = 191
	val Comma = 188
	val Dot = 190
	val Slash = 191
	val OpenBrackets = 219
	val VerticalBar = 220
	val CloseBrackets = 221
	val DquoteQuote = 222
	val Capo = 192
	*/

	// http://developer.android.com/reference/android/view/KeyEvent.html
	val RETURN = 66
	val ESC = 131
}

interface InputContext {
	val onEvent: Signal<Event>
}

interface Sound {
}

interface Music {
}

object DummySoundMusic : Sound, Music

interface AudioContext {
	fun getMusic(data: ByteArray, offset:Int = 0, size:Int = data.size): Music
	fun getSound(data: ByteArray, offset:Int = 0, size:Int = data.size): Sound
	fun play(sound: Sound): Unit
	fun play(sound: Music): Unit
	fun stop(sound: Sound): Unit
	fun stop(sound: Music): Unit
}

interface WindowContext {
	var title: String
}

interface Texture : Disposable {
	val width: Int
	val height: Int
}

data class TextureSlice(val texture: Texture, val rect: IRectangle = IRectangle(0, 0, texture.width, texture.height)) {
	val width = rect.width
	val height = rect.height
	val u1: Float = (rect.left).toFloat() / texture.width.toFloat()
	val v1: Float = (rect.top).toFloat() / texture.height.toFloat()
	val u2: Float = (rect.right).toFloat() / texture.width.toFloat()
	val v2: Float = (rect.bottom).toFloat() / texture.height.toFloat()

	fun slice(slice: IRectangle): TextureSlice {
		return TextureSlice(texture, slice.translate(this.rect.x, this.rect.y))
	}
}