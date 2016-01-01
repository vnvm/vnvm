package com.vnvm.engine.dividead

import com.vnvm.common.IRectangle
import com.vnvm.common.async.Promise
import com.vnvm.common.image.BitmapData
import com.vnvm.common.image.BitmapDataSlice
import com.vnvm.common.image.BitmapDataUtils
import com.vnvm.common.image.slice

class DivideadInterface(val waku_p: BitmapData, val waku_a1: BitmapData, val title: BitmapData) {
	// WAKU_A1.BMP <- Full screen background
	// TITLE.BMP <- Title background
	// WAKU_P.BMP <- Frame/Interface

	val PAGES = (0 until 9).map {
		//BitmapDataSlice(waku_p.slice(IRectangle(18 * it, 144, 18, 18)))
		BitmapDataSlice(waku_p, IRectangle(18 * it, 144, 18, 18))
	}

	companion object {
		fun initAsync(game: GameResources): Promise<DivideadInterface> {
			return game.getImageCachedAsync("waku_p").pipe { waku_p ->
				game.getImageCachedAsync("title").pipe { title ->
					game.getImageCachedAsync("waku_a1").pipe { waku_a1 ->
						Promise.resolved(DivideadInterface(waku_p, waku_a1, title))
					}
				}
			}
		}
	}
}