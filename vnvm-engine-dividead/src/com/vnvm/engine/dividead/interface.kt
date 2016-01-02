package com.vnvm.engine.dividead

import com.vnvm.common.IRectangle
import com.vnvm.common.async.Promise
import com.vnvm.common.image.*

class DivideadUi(val waku_p: BitmapData, val FLIST:List<String>) {
	// FLIST <- List of images
	// WAKU_A1.BMP <- Full screen background
	// TITLE.BMP <- Title background
	// WAKU_P.BMP <- Frame/Interface

	val MENU_HEAD = BitmapDataSlice(waku_p, IRectangle(0, 0, 240, 40))
	val MENU_ROW  = BitmapDataSlice(waku_p, IRectangle(0, 40, 240, 16))
	val MENU_FOOT = BitmapDataSlice(waku_p, IRectangle(0, 56, 240, 24))

	val PAGES = (0 until 9).map {
		//BitmapDataSlice(waku_p.slice(IRectangle(18 * it, 144, 18, 18)))
		BitmapDataSlice(waku_p, IRectangle(18 * it, 144, 18, 18))
	}

	companion object {
		fun initAsync(game: GameResources): Promise<DivideadUi> {
			return game.getImageCachedAsync("waku_p").pipe { waku_p ->
				game.sg["FLIST"].readAllAsync().then { String(it, "UTF-8").split('\n').map { it.trim() } }.pipe { flist ->
					Promise.resolved(DivideadUi(waku_p.applyChroma(Colors.GREEN), flist))
				}
			}
		}
	}
}