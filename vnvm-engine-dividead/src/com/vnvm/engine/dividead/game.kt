package com.vnvm.engine.dividead

import com.vnvm.common.IRectangle
import com.vnvm.common.MusicChannel
import com.vnvm.common.SoundChannel
import com.vnvm.common.async.Promise
import com.vnvm.common.async.unit
import com.vnvm.common.async.waitOneAsync
import com.vnvm.common.collection.Stack
import com.vnvm.common.image.*
import com.vnvm.common.io.VfsFile
import com.vnvm.common.script.ScriptOpcodes
import com.vnvm.common.seconds
import com.vnvm.common.view.*
import com.vnvm.engine.dividead.scene.ExtraScene
import com.vnvm.engine.dividead.scene.IngameScene
import com.vnvm.engine.dividead.scene.MainMenuScene
import com.vnvm.graphics.Keys
import com.vnvm.graphics.Music
import com.vnvm.graphics.Sound

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
					imageCache[imageName] = color.applyMask(mask)
					imageCache[imageName]!!
				}
			}
		}
	}

	public fun getSoundAsync(soundName: String): Promise<Sound> = getSoundMusicAsync("wav", wv, soundName, music = false).then { it as Sound }
	public fun getMusicAsync(musicName: String): Promise<Music> = getSoundMusicAsync("mid", mid, musicName, music = true).then { it as Music }

	private fun getSoundMusicAsync(extension: String, vfs: VfsFile, name: String, music: Boolean): Promise<Any> {
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
	val ui: DivideadUi
) {
	// @TODO: Migrate
	val sg = resources.sg
	val fnt = resources.fnt

	public var scriptOpcodes = ScriptOpcodes.createWithClass(AB_OP::class.java)
	public var state = GameState();
	public var back = BitmapData(640, 480, Colors.BLACK);
	public var front = BitmapData(640, 480, Colors.BLACK);
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
	public var optionList = OptionList<GameState.Option>(fnt, IRectangle(108, 402, 428, 60), 3, 2)
	public val mainMenu = MainMenuScene(this)
	val extraScene = ExtraScene(this)
	var ingameScene = IngameScene(this)

	public var gameSprite = Sprite().apply {
		addChild(Bitmap(front));
		addChild(textField);
		addChild(optionList.sprite);
		addChild(overlaySprite);
		addChild(extraScene.view)
		addChild(mainMenu.view)
	}

	//val mainSceneContainer = SceneContainer(gameSprite)

	init {
		gameSprite.keys.onKeyDown.add {
			if (it.code == Keys.ESC) {
				showMainMenuAsync()
			}
		}
	}

	public fun isSkipping() = views.isPressing(Keys.CONTROL_LEFT);

	companion object {
		fun addExtensionsWhenRequired(name: String, expectedExtension: String): String {
			return if (name.indexOf(".") >= 0) name else name + "." + expectedExtension
		}

		fun newAsync(views: Views, commonVfs: VfsFile, gameVfs: VfsFile): Promise<Game> {
			return getDl1Async(gameVfs["SG.DL1"]).pipe { sg ->
				getDl1Async(gameVfs["WV.DL1"]).pipe { wv ->
					BitmapFont.openAsync(views, commonVfs["arial-15.fnt"], commonVfs["arial-15.png"]).pipe { fnt ->
						val resources = GameResources(views, gameVfs, sg, wv, fnt)
						DivideadUi.initAsync(resources).then { ifc ->
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

	fun startGame(name: String, offset: Int = 0) {
		ingameScene.loadScriptAsync(name, offset).then { success ->
			ingameScene.executeAsync()
		}
	}

	fun initAsync(): Promise<Unit> {
		return setFrameAsync("WAKU_A1").pipe {
			setBackgroundAsync("TITLE").pipe {
				ingameScene.paintAsync(pos = 0, type = 2)
			}
		}
	}

	fun showMainMenuAsync(): Promise<Unit> {
		return mainMenu.showAsync(listOf(
			MainMenuScene.Option("START") {
				//addChild(new GameScalerSprite(640, 480, game.gameSprite));
				startGame("aastart", 0)
			},
			MainMenuScene.Option("LOAD") {

			},
			MainMenuScene.Option("OPTION") {
				showExtraAsync()
			},
			MainMenuScene.Option("EXIT") {
				ingameScene.paintToColorAsync(Colors.BLACK, 1.seconds).then {
					System.exit(0)
				}
			}
		))
	}

	fun showExtraAsync(): Promise<Unit> {
		//mainSceneContainer.changeTo(extraScene)
		return extraScene.showAsync()
	}

	fun setBackgroundAsync(name: String): Promise<Unit> {
		state.background = name;
		return getImageCachedAsync(name).then { bitmapData ->
			back.draw(bitmapData.applyChroma(Colors.GREEN), 32, 8);
		}
	}

	fun setFrameAsync(name: String): Promise<Unit> {
		return getImageCachedAsync(name).then { bitmapData ->
			back.draw(bitmapData, 0, 0);
		}
	}
}

class SceneContainer(parent: Sprite) {
	val view = Sprite()
	val stack = Stack<Scene>()
	var current:Scene = EmptyScene()

	init {
		parent.addChild(view)
	}

	fun push(scene: Scene) {
		stack.push(current)
		current = scene
		changeTo(current)
	}

	fun pop() {
		current = stack.pop()
		changeTo(current)
	}

	fun changeTo(scene: Scene) {
		view.removeChildren()
		view.addChild(scene.view)
	}
}

open class Scene {
	val view = Sprite()
}

class EmptyScene : Scene() {

}