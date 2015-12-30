package com.vnvm.common

object Memory {
	var defaultMem = ByteArray(0);
	var mem = defaultMem;

	@JvmStatic inline fun select(data: ByteArray, callback: () -> Unit) {
		val old = mem
		mem = data
		try {
			callback()
		} finally {
			mem = old
		}
	}

	@JvmStatic fun free(data: ByteArray) {

	}

	@JvmStatic fun memset8(offset: Int, length: Int, value: Int) {
		// @TODO: pack and set in blocks
		for (n in 0 until length) setI8(offset + n, value)
	}

	fun setI32(index: Int, value: Int): Unit {
		mem[index + 0] = (value ushr 0).toByte()
		mem[index + 1] = (value ushr 8).toByte()
		mem[index + 2] = (value ushr 16).toByte()
		mem[index + 3] = (value ushr 24).toByte()
	}

	fun setI8(index: Int, value: Int): Unit {
		mem[index + 0] = (value ushr 0).toByte()
	}

	fun getI32(index: Int): Int {
		return BitUtils.readIntLE(mem, index)
	}

	fun getI32(data: ByteArray, index: Int): Int {
		return BitUtils.readIntLE(data, index)
	}

	fun setI32(data: ByteArray, index: Int, value: Int): Unit {
		BitUtils.writeIntLE(data, index, value)
	}
}

object MemoryI {
	operator inline fun get(index: Int): Int = Memory.getI32(index shl 2)
	operator inline fun set(index: Int, value: Int): Unit {
		Memory.setI32(index shl 2, value)
	}
}

/*
object Memory {
	private var unsafe: Unsafe = Unit.let {
		val f = Unsafe::class.java.getDeclaredField("theUnsafe")
		f.isAccessible = true
		f.get(null) as Unsafe
	}

	var defaultMem = ByteArray(0);
	var mem = defaultMem;

	@JvmStatic inline fun select(data: ByteArray, callback: () -> Unit) {
		val old = mem
		mem = data
		try {
			callback()
		} finally {
			mem = old
		}
	}

	@JvmStatic fun free(data: ByteArray) {

	}

	@JvmStatic fun memset8(offset: Int, length: Int, value: Int) {
		//unsafe.setMemory(mem, offset.toLong(), length.toLong(), value.toByte())
		// @TODO: pack and set in blocks
		//for (n in 0 until length) setI8(offset + n, value)
	}

	@JvmStatic fun setI32(index: Int, value: Int): Unit {
		unsafe.putInt(mem, index.toLong(), value)
	}

	@JvmStatic fun setI8(index: Int, value: Int): Unit {
		unsafe.putByte(mem, index.toLong(), value.toByte())
	}

	@JvmStatic fun getI32(index: Int): Int {
		return unsafe.getInt(mem, index.toLong())
	}

	@JvmStatic fun getI32(data:ByteArray, index: Int): Int {
		return unsafe.getInt(data, index.toLong())
	}

	@JvmStatic fun setI32(data:ByteArray, index: Int, value:Int): Unit {
		unsafe.putInt(data, index.toLong(), value)
	}
}
*/