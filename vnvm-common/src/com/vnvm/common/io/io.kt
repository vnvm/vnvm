package com.vnvm.common.io

import com.vnvm.common.async.Promise
import com.vnvm.common.error.noImpl
import java.io.File
import java.io.RandomAccessFile
import java.util.*

class BinBytes(val data: ByteArray) {
	var position: Int = 0
	val length: Int get() = data.size
	val eof: Boolean get() = noImpl
	fun readUTFBytes(count: Int): String = noImpl
	fun readUnsignedInt(): Int = noImpl
	fun readUnsignedShort(): Int = noImpl
	fun readShort(): Int = noImpl
	fun readByte(): Int = noImpl
	fun readStringz(): String {
		var chars = arrayListOf<Char>()
		while (!eof) {
			var b = readByte()
			if (b == 0) break
			chars.add(b.toChar())
		}
		return String(chars.toCharArray())
	}

	fun readUnsignedByte(): Int = readByte() and 0xFF

	fun readStream(i: Int): BinBytes {
		noImpl
	}
}

abstract class AsyncStream {
	var position: Long = 0L
	abstract val length: Long
	abstract fun readBytesAsync(position: Long, count: Int): Promise<ByteArray>
	fun readBytesAsync(count: Int): Promise<ByteArray> {
		val out = readBytesAsync(position, count)
		position += count
		return out
	}
}

fun AsyncStream.slice(start: Long, end: Long): AsyncStream {
	assert(start <= end)
	return SliceAsyncStream(this, start, end)
}

fun AsyncStream.sliceLength(pos: Long, size: Long): AsyncStream {
	assert(size >= 0)
	return this.slice(pos, pos + size)
}

class SliceAsyncStream(val parent: AsyncStream, val start: Long, val end: Long) : AsyncStream() {
	override val length: Long = end - start
	override fun readBytesAsync(position: Long, count: Int): Promise<ByteArray> {
		throw UnsupportedOperationException()
	}
}

class ByteArrayAsyncStream(val data: ByteArray) : AsyncStream() {
	override val length: Long = data.size.toLong()

	override fun readBytesAsync(position: Long, count: Int): Promise<ByteArray> {
		return Promise.resolved(Arrays.copyOfRange(data, position.toInt(), position.toInt() + count))
	}
}

class FileAsyncStream(val file: File) : AsyncStream() {
	override val length: Long = file.length()
	val s = RandomAccessFile(file, "r")

	override fun readBytesAsync(position: Long, count: Int): Promise<ByteArray> {
		s.seek(position)
		val out = ByteArray(count)
		s.read(out)
		return Promise.resolved(out)
	}
}

fun File.openAsync() = FileAsyncStream(this)