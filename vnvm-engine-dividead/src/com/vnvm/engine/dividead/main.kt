package com.vnvm.engine.dividead

import com.vnvm.common.io.LocalVirtualFileSystem
import com.vnvm.common.view.Image
import com.vnvm.common.view.Views
import java.io.File

object DivideadEngine {
	fun start1(views:Views) {
		///*
		var fs = LocalVirtualFileSystem("assets")
		val scriptName = "aastart"
		val scriptPos = 0
		Game.newAsync(views, fs["dividead"]).then { game ->
			/*
			game.sg["I_87.BMP"].readAllAsync().then {
				File("I_87.BMP").writeBytes(LZ.decode(it))
			}
			*/

			game.getImageCachedAsync("I_87.BMP").then { bitmapData ->
				val texture = views.graphics.createTexture(bitmapData)
				views.root.addChild(Image(texture))
				//bitmapData.map { x, y, n -> BitmapData.color(x, y, 0x00, 0xFF) }
				//File("temp.tga").writeBytes(TGA.encode(bitmapData))

			}
		}

	}
	fun start2(views:Views) {
		var fs = LocalVirtualFileSystem("assets")
		val scriptName = "aastart"
		val scriptPos = 0
		Game.newAsync(views, fs["dividead"]).then { game ->
			views.root.addChild(game.gameSprite)

			var ab = AB(game)
			//addChild(new GameScalerSprite(640, 480, game.gameSprite));
			ab.loadScriptAsync(scriptName, scriptPos).then { success ->
				ab.executeAsync()
			}
		}
	}
	fun start(views: Views) {
		//start1(views)
		start2(views)
	}
}