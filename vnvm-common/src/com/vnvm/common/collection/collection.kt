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

data class ByteArraySlice(val data:ByteArray, val pos:Int = 0, val length:Int = data.size) {
	fun copy() = Arrays.copyOfRange(data, pos, pos + length)
}