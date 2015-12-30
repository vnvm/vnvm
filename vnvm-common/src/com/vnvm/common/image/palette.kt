package com.vnvm.common.image

class Palette(
	val colors: List<BmpColor> = (0 until 0x100).map { BmpColor(0, 0, 0, 0xFF) }.toArrayList()
) {
	public fun equals(dst: Palette) = this.colors == dst.colors

	public fun interpolate(left: Palette, right: Palette, step: Double) {
		for (n in 0 until Math.min(this.colors.size, Math.min(left.colors.size, right.colors.size))) {
			this.colors[n].set(BmpColor.interpolate(left.colors[n], right.colors[n], step))
		}
	}

	public fun clone(): Palette {
		var that = Palette();
		copy(this, that);
		return that;
	}

	companion object {
		public fun copy(src: Palette, dst: Palette) {
			for (n in 0 until Math.min(src.colors.size, dst.colors.size)) {
				dst.colors[n].set(src.colors[n])
			}
		}
	}
}