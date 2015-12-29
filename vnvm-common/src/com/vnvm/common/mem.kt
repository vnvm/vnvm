package com.vnvm.common

import com.vnvm.common.error.noImpl

object Memory {
	var defaultMem = ByteArray(0);
	var mem = defaultMem;

	@JvmStatic inline fun select(data: ByteArray, callback: () -> Unit) {
		val old = mem
		try {
			callback()
		} finally {
			mem = old
		}
	}

	@JvmStatic fun free(data: ByteArray) {

	}

	@JvmStatic fun memset8(offset:Int, length:Int, value:Int) {
		// @TODO: pack and set in blocks
		for (n in 0 until length) setI8(offset + n, value)
	}

	fun setI32(index: Int, value: Int): Unit = noImpl
	fun setI8(index: Int, value: Int): Unit = noImpl
}