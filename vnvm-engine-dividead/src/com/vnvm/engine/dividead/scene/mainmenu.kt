package com.vnvm.engine.dividead.scene

import com.vnvm.common.IRectangle
import com.vnvm.common.async.Promise
import com.vnvm.common.view.Bitmap
import com.vnvm.common.view.OptionList
import com.vnvm.engine.dividead.Game
import com.vnvm.engine.dividead.Scene

class MainMenuScene(val game: Game) : Scene() {
	init {
		view.apply {
			x = 48.0
			y = 16.0
			visible = false
		}
	}

	class Option(
		override val text: String,
		val callback: () -> Unit
	) : OptionList.Item

	fun showAsync(options: List<Option>): Promise<Unit> {
		var py = 0
		view.visible = true

		view.removeChildren()
		view.addChild(Bitmap(game.ui.MENU_HEAD).apply { y = py.toDouble() })
		py += 40
		for (option in options) {
			view.addChild(Bitmap(game.ui.MENU_ROW).apply { y = py.toDouble() })
			py += 16
		}
		view.addChild(Bitmap(game.ui.MENU_FOOT).apply { y = py.toDouble() })
		val test = OptionList<Option>(game.fnt, IRectangle(16, 40, 240, 16 * options.size), options.size, 1)
		view.addChild(test.sprite)
		return test.showAsync(options).then {
			view.visible = false
			it.callback()
			Unit
		}
	}
}

