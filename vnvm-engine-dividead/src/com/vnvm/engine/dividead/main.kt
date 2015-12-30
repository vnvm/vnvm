package com.vnvm.engine.dividead

import com.vnvm.common.io.LocalVirtualFileSystem
import com.vnvm.common.view.Views

object DivideadEngine {
	fun start(views: Views) {
		/*
		var fs = LocalVirtualFileSystem("assets")
		val scriptName = "aastart"
		val scriptPos = 0
		Game.newAsync(fs["dividead"]).then { game ->
			game.getImageCachedAsync("WAKU_C1.BMP").then { bitmapData ->
				val texture = views.graphics.createTexture(bitmapData)
				views.root.addChild(Image(texture))
				//bitmapData.map { x, y, n -> BitmapData.color(x, y, 0x00, 0xFF) }
				File("temp.tga").writeBytes(TGA.encode(bitmapData))

			}
		}
		*/
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
}