package com.vnvm.common.image

import com.vnvm.common.MathEx
import com.vnvm.common.Std

class BmpColor(r: Int, g: Int, b: Int, a: Int) {
	var r: Int = r and 0xFF
	var g: Int = g and 0xFF
	var b: Int = b and 0xFF
	var a: Int = a and 0xFF

	public fun getV(): Int = ((r shl 0) or(g shl 8) or(b shl 16) or(a shl 24));
	public fun getARGB(): Int = ((a shl 0) or(r shl 8) or(g shl 16) or(b shl 24))

	public fun getPixel32(): Int {
		//#if flash
		return (
			((a and 0xFF) shl 24) or
				((r and 0xFF) shl 16) or
				((g and 0xFF) shl  8) or
				((b and 0xFF) shl  0)
			);
		//#else
		//return (
		//	((b and 0xFF) shl 24) or
		//		((g and 0xFF) shl 16) or
		//		((r and 0xFF) shl  8) or
		//		((a and 0xFF) shl  0)
		//	);
		//#end
	}

	companion object {
		fun add(left: BmpColor, right: BmpColor): BmpColor {
			return BmpColor(
				(left.r + right.r) and 0xFF,
				(left.g + right.g) and 0xFF,
				(left.b + right.b) and 0xFF,
				(left.a + right.a) and 0xFF
			);
		}

		fun interpolate(left: BmpColor, right: BmpColor, step: Double): BmpColor {
			var step_l = MathEx.clamp(step, 0.0, 1.0);
			var step_r = 1.0 - step_l;
			return BmpColor(
				(Std.int(left.r * step_l + right.r * step_r)) and 0xFF,
				(Std.int(left.g * step_l + right.g * step_r)) and 0xFF,
				(Std.int(left.b * step_l + right.b * step_r)) and 0xFF,
				(Std.int(left.a * step_l + right.a * step_r)) and 0xFF
			);
		}

		fun avg(left: BmpColor, right: BmpColor): BmpColor {
			return BmpColor(
				((left.r + right.r) ushr 1) and 0xFF,
				((left.g + right.g) ushr 1) and 0xFF,
				((left.b + right.b) ushr 1) and 0xFF,
				((left.a + right.a) ushr 1) and 0xFF
			);
		}

		fun fromV(v: Int): BmpColor {
			return BmpColor(
				(v ushr 0) and 0xFF,
				(v ushr 8) and 0xFF,
				(v ushr 16) and 0xFF,
				(v ushr 24) and 0xFF
			);
		}


		private fun fromColors(v: Int, r: Int, g: Int, b: Int, a: Int): BmpColor {
			return BmpColor(
				(v ushr r) and 0xFF,
				(v ushr g) and 0xFF,
				(v ushr b) and 0xFF,
				(v ushr a) and 0xFF
			);
		}

		fun fromARGB(v: Int): BmpColor {
			return fromColors(v, 8, 16, 24, 0);
		}

	}

	override public fun toString(): String {
		return "BmpColor($r,$g,$b,$a)";
	}
}
