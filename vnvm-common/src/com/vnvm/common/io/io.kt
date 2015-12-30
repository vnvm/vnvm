package com.vnvm.common.io

import com.vnvm.common.BitUtils
import com.vnvm.common.async.Promise
import com.vnvm.common.clamp
import java.io.File
import java.io.RandomAccessFile
import java.util.*

class BinBytes(val data: ByteArray, val offset: Int = 0, val length: Int = data.size) {
	var position: Int = 0
	val available: Int get() = length - position
	val eof: Boolean get() = (available <= 0)
	fun readUTFBytes(count: Int) = String(readBytes(count), "UTF-8")
	fun readUnsignedInt() = readInt()
	fun readUnsignedShort(): Int = readShort() and 0xFFFF
	fun readInt(): Int {
		val out = BitUtils.readIntLE(data, offset + position)
		position += 4
		return out.toInt()
	}

	fun readShort(): Int {
		val out = BitUtils.readShortLE(data, offset + position)
		position += 2
		return out.toInt()
	}

	fun readByte(): Int {
		val out = data[offset + position]
		position += 1
		return out.toInt()
	}

	fun readBytes(count: Int): ByteArray {
		val out = Arrays.copyOfRange(data, offset + position, offset + position + count)
		position += count
		return out
	}

	fun readStringz(): String {
		var chars = arrayListOf<Byte>()
		while (!eof) {
			var b = readByte()
			if (b == 0) break
			chars.add(b.toByte())
		}
		return String(chars.toByteArray(), "UTF-8")
	}

	fun readUnsignedByte(): Int = readByte() and 0xFF

	fun readStream(count: Int): BinBytes {
		val stream = BinBytes(data, offset + position, count)
		position += count
		return stream
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

	open fun close(): Unit {
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

fun AsyncStream.clone(): AsyncStream {
	return this.slice(position, length)
}

class SliceAsyncStream(val parent: AsyncStream, val start: Long, val end: Long) : AsyncStream() {
	override val length: Long = end - start
	override fun readBytesAsync(position: Long, count: Int): Promise<ByteArray> {
		val start1 = (start + position).clamp(start, end)
		val end1 = (start + position + count).clamp(start, end)
		return parent.readBytesAsync(start1, (end1 - start1).toInt())
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