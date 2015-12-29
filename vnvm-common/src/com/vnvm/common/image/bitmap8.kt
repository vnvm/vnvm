package com.vnvm.common.image

import com.vnvm.common.*
import com.vnvm.common.log.Log

class BitmapData8(val width: Int, val height: Int) {
	public var palette: Palette = Palette()
	public var data = ByteArray(width * height)
	public val rect = IRectangle(0, 0, width, height)

	companion object {
		fun createWithBitmapData(bitmapData32: BitmapData): BitmapData8 {
			var bitmapData8 = createNewWithSize(bitmapData32.width, bitmapData32.height)
			bitmapData8.palette.colors[0] = BmpColor(0xFF, 0xFF, 0xFF, 0x00)
			bitmapData8.palette.colors[1] = BmpColor(0xFF, 0xFF, 0xFF, 0xFF)
			for (y in 0 until bitmapData32.height) {
				for (x in 0 until bitmapData32.width) {
					if (bitmapData32.getPixel32(x, y) != 0) {
						bitmapData8.setPixel(x, y, 0)
					} else {
						bitmapData8.setPixel(x, y, 1)
					}
				}
			}
			return bitmapData8
		}

		fun createNewWithSize(width: Int, height: Int) = BitmapData8(width, height)

		fun createWithDataAndPalette(data: ByteArray, width: Int, height: Int, palette: Palette): BitmapData8 {
			var bitmapData: BitmapData8 = BitmapData8(width, height)
			System.arraycopy(data, 0, bitmapData.data, 0, width * height)
			bitmapData.palette.copy(palette)
			return bitmapData
		}

		fun copyRect(src: BitmapData8, srcRect: IRectangle, dst: BitmapData8, dstPoint: IPoint): Void {
			copyRectTransition(src, srcRect, dst, dstPoint, 1.0, 0)
		}

		private fun getMask(x: Int, y: Int, n: Int, effect: Int, step: Float): Boolean {
			return true
		}

		private var __randomData: DoubleArray? = null

		private fun getRandomData(): DoubleArray {
			if (__randomData == null) {
				__randomData = DoubleArray(1000)
				for (n in 0 until 1000) __randomData!![n] = Math.random()
			}
			return __randomData!!
		}

		private fun getMaskRandomPixels(mask: ByteArray, random: Array<Float>, w: Int, h: Int, step: Float): Void {
			var n = 0
			for (x in 0 until w) for (y in 0 until h) {
				mask.writeByte(if (step >= random[n % random.size]) 1 else 0)
				n++
			}
		}

		private fun getMaskRandomRows(mask: ByteArray, random: Array<Float>, w: Int, h: Int, step: Float): Void {
			for (x in 0 until w) for (y in 0 until h) {
				mask.writeByte(if (step >= random[y % random.size]) 1 else 0)
			}
		}

		private fun getMaskRandomColumns(mask: ByteArray, random: Array<Float>, w: Int, h: Int, step: Float): Void {
			for (x in 0 until w) for (y in 0 until h) {
				mask.writeByte(if (step >= random[x % random.size]) 1 else 0)
			}
		}

		public fun copyRectTransition(src: BitmapData8, srcRect: IRectangle, dst: BitmapData8, dstPoint: IPoint, step: Double, effect: Int, transparentColor: Int = -1): Void {
			dst.palette = src.palette

			var srcX = srcRect.x
			var srcY = srcRect.y
			var width = srcRect.width
			var height = srcRect.height

			var dstX = dstPoint.x
			var dstY = dstPoint.y

			var srcData = src.data
			var dstData = dst.data

			//Log.trace(Std.format("SRC($srcX, $srcY), DST($dstX, $dstY) | SIZE($width, $height)"))

			if (!src.inBounds(srcX, srcY)) Log.trace("BitmapData8.copyRect.Error [1]")
			if (!src.inBounds(srcX + width - 1, srcY + height - 1)) Log.trace("BitmapData8.copyRect.Error [2]")
			if (!dst.inBounds(dstX, dstY)) Log.trace("BitmapData8.copyRect.Error [3]")
			if (!dst.inBounds(dstX + width - 1, dstY + height - 1)) Log.trace("BitmapData8.copyRect.Error [4]")

			width = Std.int(MathEx.clamp(width, 0, dst.width - dstX))
			width = Std.int(MathEx.clamp(width, 0, src.width - srcX))

			height = Std.int(MathEx.clamp(height, 0, dst.height - dstY))
			height = Std.int(MathEx.clamp(height, 0, src.height - srcY))

			step = step.clamp01()

			var _srcData = srcData
			var _dstData = dstData

			if ((step >= 1) || (effect == 0)) {
				for (y in 0 until height) {
					var srcN: Int = src.getIndex(srcX + 0, srcY + y)
					var dstN: Int = dst.getIndex(dstX + 0, dstY + y)

					for (x in 0 until width) {
						var c = _srcData[srcN]
						if (c.toInt() != transparentColor) _dstData[dstN] = c
						dstN++
						srcN++
					}
					//dstData.blit(dstN, srcData, srcN, width)
				}
			} else {
				var checker: (Int, Int, Int, Int, Float) -> Boolean
				var mask = ByteArray()
				var _mask = mask
				var random: Array<Float> = getRandomData()

				getMaskRandomPixels(mask, random, width, height, step)

				var n: Int = 0
				for (y in 0 until height) {
					var srcN: Int = src.getIndex(srcX + 0, srcY + y)
					var dstN: Int = dst.getIndex(dstX + 0, dstY + y)

					for (x in 0 until width) {
						if (_mask.get(n) != 0) {
							var c: Int = _srcData[srcN]
							if (c != transparentColor) {
								_dstData[dstN] = c
							}
						}

						dstN++
						srcN++
						n++
					}
				}
			}
		}
	}

	public fun getBimapData32(): BitmapData {
		var bmp: BitmapData = BitmapData(width, height)
		drawToBitmapData(bmp, bmp.rect)
		return bmp
	}

	public fun drawToBitmapData(bmp: BitmapData, rect: IRectangle) {
		this.drawToBitmapDataWithPalette(bmp, this.palette, rect)
	}

	public fun drawToBitmapDataWithPalette(bmp: BitmapData, palette: Palette, rect: IRectangle) {
		var rectX: Int = rect.x
		var rectY: Int = rect.y
		var rectW: Int = rect.width
		var rectH: Int = rect.height
		var temp = ByteArray(rectW * rectH * 4)
		var colorsPalette = palette.colors.map { it.getPixel32() }.toIntArray()

		Memory.select(temp) {
			var dstPos: Int
			var srcPos: Int
			var _data = data
			for (y in 0 until rectH) {
				dstPos = y * rectW * 4
				srcPos = getIndex(rectX + 0, rectY + y)

				//Log.trace(Std.format("($srcPos, $dstPos) :: ($rectX, $rectY, $rectW, $rectH)"))

				for (x in 0 until rectW) {
					Memory.setI32(dstPos, colorsPalette[_data[srcPos].toInt()])
					dstPos += 4
					srcPos += 1
				}
			}
			bmp.setPixels(rect, temp)
		}

		Memory.free(temp)
	}

	public fun getIndex(x: Int, y: Int): Int = y * width + x
	public fun getPixel(x: Int, y: Int): Int = data[getIndex(x, y)].toInt()
	public fun setPixel(x: Int, y: Int, colorIndex: Int) {
		data[getIndex(x, y)] = colorIndex.toByte()
	}

	public fun drawToBitmapData8(dst: BitmapData8, px: Int, py: Int) {
		copyRect(this, rect, dst, IPoint(px, py))
	}

	public fun fillRect(color: Int, rect: IRectangle) {
		var rectX: Int = (rect.x)
		var rectY: Int = (rect.y)
		var rectW: Int = (rect.width)
		var rectH: Int = (rect.height)
		rectX = rectX.clamp(0, this.width - 1)
		rectY = rectY.clamp(0, this.height - 1)
		rectW = rectW.clamp(0, this.width - 1 - rectX)
		rectH = rectH.clamp(0, this.height - 1 - rectY)

		Memory.select(data) {
			for (y in 0 until rectH) {
				var n: Int = getIndex(rectX + 0, rectY + y)
				Memory.memset8(n, rectW, color)
			}
		}
	}

	public fun inBounds(x: Int, y: Int): Boolean = (x >= 0 && y >= 0 && x < width && y < height)
}
