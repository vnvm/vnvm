package com.vnvm.engine.dividead.scene

import com.vnvm.common.IRectangle
import com.vnvm.common.async.Promise
import com.vnvm.common.async.waitOneAsync
import com.vnvm.common.view.OptionList
import com.vnvm.common.view.Sprite
import com.vnvm.engine.dividead.Game
import com.vnvm.engine.dividead.Scene

class ExtraScene(val game: Game) : Scene() {
	class Option(override val text: String, val id: Int) : OptionList.Item

	val bgpages = (0 until 6).map { "CGMODE_${('A' + it).toChar()}" }
	val FLIST = game.ui.FLIST
	val options = (0 until 25).map { Option("$it", it) }
	var selectedOption = options.first()

	fun showImageAsync(id: Int): Promise<Unit> {
		view.removeChildren()

		val m = Sprite()
		view.addChild(m)

		val base = FLIST[id]
		var filesToTry = arrayListOf(base, "${base}A", "${base}B", "${base}C", "${base}D", "${base}E")

		fun showOneAsync(): Promise<Unit> {
			val file = filesToTry.removeAt(0) + ".BMP"
			return game.sg[file].existsAsync().pipe { exists ->
				if (exists) {
					game.setBackgroundAsync(file).pipe {
						game.ingameScene.paintAsync(0, 4).pipe {
							m.keys.onKeyDown.waitOneAsync().pipe {
								showOneAsync()
							}
						}
					}
				} else {
					view.removeChildren()
					Promise.resolved(Unit)
				}
			}
		}

		//game.sg.statAsync()

		return showOneAsync()
	}

	fun setPageAsync(page: Int): Promise<Unit> {
		view.removeChildren()

		val firstPage = (page == 0)
		val lastPage = (page == bgpages.size - 1)

		val offset = page * 25
		return game.setFrameAsync("WAKU_A1").pipe {
			view.visible = true
			game.setBackgroundAsync(bgpages[page]).pipe {
				game.ingameScene.paintAsync(0, 3).pipe {
					val test = OptionList<Option>(game.fnt, IRectangle(0, 0, 560, 370), 5, 5)
					test.sprite.apply {
						x = 40.0
						y = 16.0
					}
					view.addChild(test.sprite)
					test.showAsync(options, selectedOption).pipe {
						selectedOption = it
						view.removeChildren()
						val flagId = offset + it.id
						if (!firstPage && it.id == 0) {
							// PREV PAGE
							setPageAsync(page - 1)
						} else if (!lastPage && it.id == 24) {
							// NEXT PAGE
							setPageAsync(page + 1)
						} else {
							//if (game.state.flags[flagId] != 0) {
							if (true) {
								showImageAsync(flagId).pipe {
									setPageAsync(page)
								}
							} else {
								setPageAsync(page)
							}
						}
					}
				}
			}
		}
	}

	//val CGMODE_1.BMP
	fun showAsync(): Promise<Unit> {
		return setPageAsync(0)
	}
}