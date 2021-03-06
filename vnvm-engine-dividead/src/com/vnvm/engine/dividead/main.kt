package com.vnvm.engine.dividead

import com.vnvm.common.io.LocalVirtualFileSystem
import com.vnvm.common.io.VfsFile
import com.vnvm.common.view.Bitmap
import com.vnvm.common.view.Views
import com.vnvm.io.IsoFile

object DivideadEngine {
	fun runGame(views: Views, common: VfsFile, assets: VfsFile, scriptName: String = "aastart", scriptPos: Int = 0) {
		Game.newAsync(views, common, assets).then { game ->
			views.root.addChild(game.gameSprite)
			game.initAsync().pipe {
				game.showMainMenuAsync()
			}
		}
	}

	fun start(views: Views) {
		var fs = LocalVirtualFileSystem("assets")
		views.window.title = "DiviDead"

		IsoFile.openAsync(fs["dividead.iso"]).then { iso ->
			//runTest(views, it)
			//runGame(views, fs, iso, "aastart", 0) // start
			//runGame(views, fs, iso, "aastart", 0x089A) // options
			//runGame(views, fs, iso, "aastart", 0x1703) // ALARM: sound + wait
			runGame(views, fs, iso, "aastart", 0x1841) // characters
			//runGame(views, fs, iso, "aastart", 0x295B) // JUMP_IF
		}
	}

	fun runTest(views: Views, common: VfsFile, assets: VfsFile) {
		Game.newAsync(views, common, assets).then { game ->
			/*
			game.sg["I_87.BMP"].readAllAsync().then {
				File("I_87.BMP").writeBytes(LZ.decode(it))
			}
			*/

			game.getImageCachedAsync("I_87.BMP").then { bitmapData ->
				views.root.addChild(Bitmap(bitmapData))
				//bitmapData.map { x, y, n -> BitmapData.color(x, y, 0x00, 0xFF) }
				//File("temp.tga").writeBytes(TGA.encode(bitmapData))

			}
		}
	}
}