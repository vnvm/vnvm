package com.vnvm.engine.dividead

import com.vnvm.common.*
import com.vnvm.common.async.Promise
import com.vnvm.common.error.InvalidOperationException
import com.vnvm.common.image.BitmapData
import com.vnvm.common.image.BitmapDataUtils
import com.vnvm.common.image.BitmapFont
import com.vnvm.common.image.Colors
import com.vnvm.common.io.VfsFile
import com.vnvm.common.script.ScriptOpcodes
import com.vnvm.common.view.*
import com.vnvm.graphics.Keys
import com.vnvm.graphics.Music
import com.vnvm.graphics.Sound
import com.vnvm.ui.SpatialMenu

class GameResources(
	val views: Views,
	val fileSystem: VfsFile,
	val sg: VfsFile,
	val wv: VfsFile,
    val fnt: BitmapFont
) {
	public var mid = fileSystem["MID"]

	private var imageCache = hashMapOf<String, BitmapData>();

	public fun getImageCachedAsync(imageName: String): Promise<BitmapData> {
		val imageName = Game.addExtensionsWhenRequired(imageName, "bmp").toUpperCase();

		return if (imageName in imageCache) {
			Promise.resolved(imageCache[imageName]!!);
		} else {
			sg[imageName].readAllAsync().then { byteArray ->
				imageCache[imageName] = SG.getImage(byteArray);
				imageCache[imageName]!!;
			}
		}
	}

	fun getImageMaskCachedAsync(imageNameColor: String, imageNameMask: String): Promise<BitmapData> {
		var imageName: String = "$imageNameColor$imageNameMask"

		return if (imageName in imageCache) {
			Promise.resolved(imageCache[imageName]!!)
		} else {
			getImageCachedAsync(imageNameColor).pipe { color ->
				getImageCachedAsync(imageNameMask).then { mask ->
					imageCache[imageName] = BitmapDataUtils.combineColorMask(color, mask)
					imageCache[imageName]!!
				}
			}
		}
	}

	public fun getSoundAsync(soundName: String): Promise<Sound> = getSoundMusicAsync("wav", wv, soundName, music = false).then { it as Sound }
	public fun getMusicAsync(musicName: String): Promise<Music> = getSoundMusicAsync("mid", mid, musicName, music = true).then { it as Music }

	private fun getSoundMusicAsync(extension: String, vfs: VfsFile, name: String, music:Boolean): Promise<Any> {
		val name = Game.addExtensionsWhenRequired(name, extension).toUpperCase();
		return vfs[name].readAllAsync().then { byteArray ->
			if (music) {
				views.audio.getMusic(byteArray, 0, byteArray.size)
			} else {
				views.audio.getSound(byteArray, 0, byteArray.size)
			}
		}
	}
}

class Game(
	val views: Views,
	val resources: GameResources,
    val ifc: DivideadInterface
) {
	// @TODO: Migrate
	val sg = resources.sg
	val fnt = resources.fnt

	public var scriptOpcodes = ScriptOpcodes.createWithClass(AB_OP::class.java)
	public var state = GameState();
	public var back = BitmapData(640, 480, false, 0xFF000000.toInt());
	public var front = BitmapData(640, 480, false, 0xFF000000.toInt());
	public var textField = TextField(fnt).apply {
		selectable = false;
		x = 110.0;
		y = 400.0;
		width = 420.0;
		height = 60.0;
		text = "";
		textColor = Colors.WHITE
	}
	public var overlaySprite = Sprite()

	public var voiceChannel = SoundChannel(views)
	public var effectChannel = SoundChannel(views)
	public var musicChannel = MusicChannel(views)
	public var optionList = OptionList<GameState.Option>(fnt, IRectangle(108, 402, 428, 60), 3, 2, true)

	public var gameSprite = Sprite().apply {
		addChild(Bitmap(front));
		addChild(textField);
		addChild(optionList.sprite);
		addChild(overlaySprite);
	}

	public fun isSkipping() = views.isPressing(Keys.CONTROL_LEFT);

	companion object {
		fun addExtensionsWhenRequired(name: String, expectedExtension: String): String {
			return if (name.indexOf(".") >= 0) name else name + "." + expectedExtension
		}

		fun newAsync(views: Views, commonVfs:VfsFile, gameVfs: VfsFile): Promise<Game> {
			return getDl1Async(gameVfs["SG.DL1"]).pipe { sg ->
				getDl1Async(gameVfs["WV.DL1"]).pipe { wv ->
					BitmapFont.openAsync(views, commonVfs["arial-15.fnt"], commonVfs["arial-15.png"]).pipe { fnt ->
						val resources = GameResources(views, gameVfs, sg, wv, fnt)
						DivideadInterface.initAsync(resources).then { ifc ->
							Game(views, resources, ifc)
						}
					}
				}
			}
		}

		private fun getDl1Async(file: VfsFile): Promise<VfsFile> {
			return file.openAsync().pipe { DL1.loadAsync(it) }
		}
	}

	// @TODO: Migrate
	fun getImageCachedAsync(imageName: String) = resources.getImageCachedAsync(imageName)
	fun getImageMaskCachedAsync(imageNameColor: String, imageNameMask: String) = resources.getImageMaskCachedAsync(imageNameColor, imageNameMask)
	fun getSoundAsync(soundName: String) = resources.getSoundAsync(soundName)
	fun getMusicAsync(musicName: String) = resources.getMusicAsync(musicName)
}

class OptionList<TOption : OptionList.Item>(
	val font: BitmapFont,
	val rect: IRectangle,
	val rows: Int,
	val columns: Int,
	val something: Boolean
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
			println("$posX, $posY : $tx, $ty")
			sprite.addChild(optionTextFields[it]!!.apply {
				text = item.text
				x = tx
				y = ty
			})
		}

		sprite.addChild(Sprite().apply {
			keys.onKeyDown.add {
				println("keyDown: ${it.code}")
				val prevSel = selectedOption
				when (it.code) {
					Keys.LEFT -> selectedOption = SpatialMenu.moveLeft(options, selectedOption)
					Keys.RIGHT -> selectedOption = SpatialMenu.moveRight(options, selectedOption)
					Keys.UP -> selectedOption = SpatialMenu.moveUp(options, selectedOption)
					Keys.DOWN -> selectedOption = SpatialMenu.moveDown(options, selectedOption)
					Keys.Return -> deferred.resolve(selectedOption.option)
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

