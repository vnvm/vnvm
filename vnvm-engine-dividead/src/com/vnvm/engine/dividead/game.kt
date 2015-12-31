package com.vnvm.engine.dividead

import com.vnvm.common.IPoint
import com.vnvm.common.IRectangle
import com.vnvm.common.Sound
import com.vnvm.common.SoundChannel
import com.vnvm.common.async.Promise
import com.vnvm.common.async.Signal
import com.vnvm.common.collection.Array2
import com.vnvm.common.image.BitmapData
import com.vnvm.common.image.BitmapDataUtils
import com.vnvm.common.io.VfsFile
import com.vnvm.common.log.Log
import com.vnvm.common.script.ScriptOpcodes
import com.vnvm.common.view.*
import com.vnvm.graphics.Keys

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
		textColor = 0xFFFFFF;
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

	public fun isSkipping() = views.isPressing(Keys.Control);

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

class OptionList<TOption : Any>(
	val rect: IRectangle,
	val rows: Int,
	val columns: Int,
	val something: Boolean
) {
	val onSelected = Signal<TOption>()
	val sprite = Sprite().apply {
		visible = false
		x = rect.x.toDouble()
		y = rect.y.toDouble()
	}
	val elementSize = IPoint(rect.width / columns, rect.height / rows)

	fun show(items: List<Pair<String, TOption>>) {
		sprite.removeChildren()
		items.zip(Array2.range(columns, rows)).forEach {
			val (item, pos) = it
			val (posX, posY) = pos
			val (itemText, itemOption) = item
			val tx = posX.toDouble() * elementSize.x
			val ty = posY.toDouble() * elementSize.y
			println("$posX, $posY : $tx, $ty")
			sprite.addChild(TextField().apply {
				text = itemText
				x = tx
				y = ty
			})
		}
		sprite.visible = true
	}

	fun hide() {
		sprite.visible = false
	}
}