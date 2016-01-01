package com.vnvm.common.image

import com.vnvm.common.IRectangle
import com.vnvm.common.async.Promise
import com.vnvm.common.image.format.Imaging
import com.vnvm.common.io.VfsFile
import com.vnvm.common.view.Views
import com.vnvm.graphics.RenderContext
import com.vnvm.graphics.TextureSlice

class BitmapFont(
	val views: Views,
	val fnt: String,
	val bitmap: BitmapData
) {
	val texture = views.graphics.createTexture(bitmap)
	var size = 10
	val glyphs = hashMapOf<Int, Glyph>()
	val kernings = hashMapOf<Pair<Int, Int>, Kerning>()

	data class Kerning(val first: Int, val second: Int, val amount: Int)

	data class Glyph(
		val id: Int,
		val rect: IRectangle,
		val xoffset: Int,
		val yoffset: Int,
		val xadvance: Int,
		val page: Int,
		val chnl: Int,
		val texture: TextureSlice
	)

	init {
		for (line in fnt.split("\n")) {
			val line = line.trim()
			val parts = line.split(' ')
			if (parts.isEmpty()) continue

			val map = parts.drop(1).flatMap {
				val parts = it.split('=', limit = 2)
				if (parts.size >= 2) listOf(Pair(parts[0], parts[1])) else listOf()
			}.toMap()

			fun int(name: String, default: Int = 0): Int {
				return try {
					map[name]?.toInt() ?: default
				} catch (e: Throwable) {
					println("Can't parse to int : " + map[name])
					e.printStackTrace()
					default
				}
			}

			when (parts.first()) {
				"info" -> {
					this.size = Math.abs(int("size", 10))
				}
				"common" -> {

				}
				"page" -> {

				}
				"char" -> {
					val id = int("id")
					val rect = IRectangle(
						x = int("x"),
						y = int("y"),
						width = int("width"),
						height = int("height")
					)
					glyphs[id] = Glyph(
						id = id,
						rect = rect,
						xoffset = int("xoffset"),
						yoffset = int("yoffset"),
						xadvance = int("xadvance"),
						page = int("page"),
						chnl = int("chnl"),
						texture = texture.slice(rect)
					)
				}
				"kerning" -> {
					val first = int("first")
					val second = int("second")
					val amount = int("amount")
					kernings[Pair(first, second)] = Kerning(first, second, amount)
				}
			}
		}
	}

	fun render(context: RenderContext, color:Color, text: String, fontSize: Double, x: Int = 0, y: Int = 0) {
		context.save()
		context.scale(fontSize / this.size.toDouble())
		val oldColor = context.color
		context.color = color
		var x = x.toDouble()
		var y = y.toDouble()
		for (c in text) {
			val glyph = glyphs[c.toInt()]
			if (glyph != null) {
				context.quad(glyph.texture, x + glyph.xoffset, y + glyph.yoffset)
				x += glyph.xadvance.toDouble()
			}
		}
		context.color = oldColor
		context.restore()
	}

	companion object {
		fun openAsync(views: Views, fnt: VfsFile, image: VfsFile): Promise<BitmapFont> {
			return fnt.readAllAsync().pipe { fnt ->
				image.readAllAsync().then { image ->
					BitmapFont(views, String(fnt, "UTF-8"), Imaging.load(image))
				}
			}
		}
	}
}