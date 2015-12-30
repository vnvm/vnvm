package com.vnvm.graphics

import com.vnvm.common.Disposable
import com.vnvm.common.image.BitmapData

interface RenderContext : GraphicsContext {
	fun begin(): Unit
	fun save(): Unit
	fun restore(): Unit
	fun rotate(radians: Double): Unit
	fun translate(x: Double, y: Double): Unit
	fun scale(sx: Double, sy: Double): Unit
	fun quad(tex: TextureSlice, width:Double = tex.width, height:Double = tex.height)
	fun end(): Unit
	fun text(text:String, x:Double = 0.0, y:Double = 0.0)
}

interface GraphicsContext {
	fun createTexture(data: BitmapData): TextureSlice
}

interface Texture : Disposable {
	val width: Int
	val height: Int
}

class TextureSlice(
	val texture:Texture,
    val u1: Float = 0f,
	val v1: Float = 0f,
	val u2: Float = 1f,
	val v2: Float = 1f,
    val width: Double = texture.width.toDouble(),
	val height: Double = texture.height.toDouble()
) {

}