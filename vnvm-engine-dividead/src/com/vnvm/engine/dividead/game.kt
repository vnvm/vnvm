package com.vnvm.engine.dividead

import com.vnvm.common.*
import com.vnvm.common.async.Promise
import com.vnvm.common.async.Signal
import com.vnvm.common.collection.Array2
import com.vnvm.common.collection.without
import com.vnvm.common.error.InvalidOperationException
import com.vnvm.common.image.BitmapData
import com.vnvm.common.image.BitmapDataUtils
import com.vnvm.common.image.Colors
import com.vnvm.common.io.VfsFile
import com.vnvm.common.log.Log
import com.vnvm.common.script.ScriptOpcodes
import com.vnvm.common.view.*
import com.vnvm.graphics.Keys
import com.vnvm.ui.SpatialMenu

class Game(
	val views: Views,
	val fileSystem: VfsFile,
	val sg: VfsFile,
	val wv: VfsFile
) {
	private var imageCache = hashMapOf<String, BitmapData>();

	public var mid = fileSystem["MID"]
	public var scriptOpcodes = ScriptOpcodes.createWithClass(AB_OP::class.java)
	public var state = GameState();
	public var back = BitmapData(640, 480, false, 0xFF000000.toInt());
	public var front = BitmapData(640, 480, false, 0xFF000000.toInt());
	public var textField = TextField().apply {
		defaultTextFormat = TextFormat("Arial", 12, 0xFFFFFF);
		selectable = false;
		x = 110.0;
		y = 400.0;
		width = 420.0;
		height = 60.0;
		text = "";
		textColor = Colors.WHITE
	}
	public var overlaySprite = Sprite()

	public var voiceChannel = SoundChannel()
	public var effectChannel = SoundChannel()
	public var musicChannel = SoundChannel()
	public var optionList = OptionList<GameState.Option>(IRectangle(108, 402, 428, 60), 3, 2, true)

	public var gameSprite = Sprite().apply {
		addChild(Bitmap(front, PixelSnapping.AUTO, true));
		addChild(textField);
		addChild(optionList.sprite);
		addChild(overlaySprite);
	}

	public fun isSkipping() = views.isPressing(Keys.CONTROL_LEFT);

	companion object {
		private fun addExtensionsWhenRequired(name: String, expectedExtension: String): String {
			return if (name.indexOf(".") >= 0) name else name + "." + expectedExtension
		}

		fun newAsync(views: Views, fileSystem: VfsFile): Promise<Game> {
			return getDl1Async(fileSystem["SG.DL1"]).pipe { sg ->
				getDl1Async(fileSystem["WV.DL1"]).then { wv ->
					Game(views, fileSystem, sg, wv);
				}
			}
		}

		private fun getDl1Async(file: VfsFile): Promise<VfsFile> {
			return file.openAsync().pipe { DL1.loadAsync(it) }
		}
	}

	public fun getImageCachedAsync(imageName: String): Promise<BitmapData> {
		val imageName = addExtensionsWhenRequired(imageName, "bmp").toUpperCase();

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

	public fun getSoundAsync(soundName: String): Promise<Sound> = getSoundMusicAsync("wav", wv, soundName);
	public fun getMusicAsync(musicName: String): Promise<Sound> = getSoundMusicAsync("mid", mid, musicName);

	private fun getSoundMusicAsync(extension: String, vfs: VfsFile, name: String): Promise<Sound> {
		val name = addExtensionsWhenRequired(name, extension).toUpperCase();

		return vfs[name].readAllAsync().then { byteArray ->
			var sound = Sound()
			try {
				sound.loadCompressedDataFromByteArray(byteArray, byteArray.size);
			} catch (e: Throwable) {
				Log.trace("Error: $e");
			}
			sound
		}
	}
}

class OptionList<TOption : OptionList.Item>(
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

	fun showAsync(items: List<TOption>):Promise<TOption> {
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
			Pair(it, TextField())
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

