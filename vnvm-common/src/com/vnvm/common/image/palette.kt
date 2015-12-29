package com.vnvm.common.image

class Palette {
	public val colors = (0 until 0x100).map { BmpColor(0, 0, 0, 0xFF) }.toArrayList()

	public fun equals(dst: Palette) = this.colors == dst.colors

	public fun interpolate(left: Palette, right: Palette, step: Float) {
		for (n in 0 until Std.int(Math.min(this.colors.length, Math.min(left.colors.length, right.colors.length)))) {
			this.colors[n] = BmpColor.interpolate(left.colors[n], right.colors[n], step);
		}
	}

	public fun clone(): Palette {
		var that = Palette();
		copy(this, that);
		return that;
	}

	public fun copy(src: Palette, dst: Palette) {
		for (n in 0 until Std.int(Math.min(src.colors.length, dst.colors.length))) {
			dst.colors[n] = src.colors[n];
		}
	}
}