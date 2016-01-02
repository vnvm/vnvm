package com.vnvm.common.view

import com.vnvm.common.IPoint
import com.vnvm.common.IRectangle
import com.vnvm.common.Point
import com.vnvm.common.async.Promise
import com.vnvm.common.error.InvalidOperationException
import com.vnvm.common.image.BitmapFont
import com.vnvm.common.image.Colors
import com.vnvm.graphics.Keys
import com.vnvm.ui.SpatialMenu

class OptionList<TOption : OptionList.Item>(
	val font: BitmapFont,
	val rect: IRectangle,
	val rows: Int,
	val columns: Int
) {
	interface Item {
		val text: String
	}

	val sprite = Sprite().apply {
		visible = false
		x = rect.x.toDouble()
		y = rect.y.toDouble()
	}
	val elementSize = IPoint(rect.width / columns, rect.height / rows)

	fun showAsync(items: List<TOption>): Promise<TOption> {
		if (items.size == 0) return Promise.rejected(InvalidOperationException("No items to select!"))
		val deferred = Promise.Deferred<TOption>()
		sprite.removeChildren()

		println(columns)
		println(rows)
		println(Point.range(columns, rows))

		val options = items.zip(Point.range(columns, rows)).map {
			val option = it.first
			val pos = it.second
			SpatialMenu.Item(pos, option)
		}
		var selectedOption = options.first()
		val optionTextFields = options.map {
			Pair(it, TextField(font))
		}.toMap()

		fun updateTextFields() {
			for (tf in optionTextFields.values) tf.textColor = Colors.WHITE
			optionTextFields[selectedOption]!!.textColor = Colors.RED
		}

		options.forEach {
			val item = it.option
			val pos = it.pos
			val (posX, posY) = pos
			val tx = posX.toDouble() * elementSize.x
			val ty = posY.toDouble() * elementSize.y
			println(pos)
			println("$posX, $posY : $tx, $ty")
			sprite.addChild(optionTextFields[it]!!.apply {
				text = item.text
				x = tx
				y = ty
			})
		}

		sprite.addChild(Sprite().apply {
			//keys.onKeyDown.add {
			keys.onKeyDown.add {
				println("keyDown: ${it.code}")
				val prevSel = selectedOption
				when (it.code) {
					Keys.LEFT -> selectedOption = SpatialMenu.moveLeft(options, selectedOption)
					Keys.RIGHT -> selectedOption = SpatialMenu.moveRight(options, selectedOption)
					Keys.UP -> selectedOption = SpatialMenu.moveUp(options, selectedOption)
					Keys.DOWN -> selectedOption = SpatialMenu.moveDown(options, selectedOption)
					Keys.RETURN -> deferred.resolve(selectedOption.option)
					else -> Unit
				}
				updateTextFields()
				//println("$prevSel -> $selectedOption")
			}
		})

		updateTextFields()

		sprite.visible = true
		return deferred.promise
	}

	fun hide() {
		sprite.visible = false
	}

}

