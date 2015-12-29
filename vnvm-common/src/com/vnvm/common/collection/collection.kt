package com.vnvm.common.collection

import java.util.*

fun xrange(min:Int, max:Int, step:Int): Iterable<Int> {
	return object : Iterable<Int> {
		override fun iterator(): Iterator<Int> {
			return object : IntIterator() {
				var cur = min

				override fun nextInt(): Int {
					cur += step
					return cur - step
				}

				override fun hasNext(): Boolean {
					return cur < max
				}
			}
		}
	}
}

inline fun foreach(width:Int, height:Int, callback: (x:Int, y:Int, n:Int) -> Unit) {
	var n = 0
	for (x in 0 until width) for (y in 0 until height) {
		callback(x, y, n)
		n++
	}
}


data class ByteArraySlice(val data:ByteArray, val pos:Int = 0, val length:Int = data.size) {
	fun copy() = Arrays.copyOfRange(data, pos, pos + length)
}