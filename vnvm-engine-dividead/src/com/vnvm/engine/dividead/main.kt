package com.vnvm.engine.dividead

import com.vnvm.common.io.LocalVirtualFileSystem
import com.vnvm.common.io.VfsFile
import com.vnvm.common.view.Bitmap
import com.vnvm.common.view.Views
import com.vnvm.io.IsoFile

object DivideadEngine {
	fun runTest(views: Views, assets: VfsFile) {
		Game.newAsync(views, assets).then { game ->
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

	fun runGame(views: Views, assets: VfsFile) {
		val scriptName = "aastart"
		val scriptPos = 0
		Game.newAsync(views, assets).then { game ->
			views.root.addChild(game.gameSprite)

			var ab = AB(game)
			//addChild(new GameScalerSprite(640, 480, game.gameSprite));
			ab.loadScriptAsync(scriptName, scriptPos).then { success ->
				ab.executeAsync()
			}
		}
	}

	fun start(views: Views) {
		var fs = LocalVirtualFileSystem("assets")
		views.window.title = "DiviDead"

		IsoFile.openAsync(fs["dividead.iso"]).then {
			//runTest(views, it)
			runGame(views, it)
		}
	}
}