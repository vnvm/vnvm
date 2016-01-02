package com.vnvm.common.collection

import java.util.*

fun xrange(min: Int, max: Int, step: Int): Iterable<Int> {
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

inline fun foreach(width: Int, height: Int, callback: (x: Int, y: Int, n: Int) -> Unit) {
	var n = 0
	for (y in 0 until height) for (x in 0 until width) {
		callback(x, y, n)
		n++
	}
}


data class ByteArraySlice(val data: ByteArray, val pos: Int = 0, val length: Int = data.size) {
	fun copy() = Arrays.copyOfRange(data, pos, pos + length)
}


interface CollectionSize {
	val size: Int
}

fun CollectionSize.isEmpty() = this.size == 0
fun CollectionSize.isNotEmpty() = this.size != 0

class Stack<T> : CollectionSize, Iterable<T> {
	override fun iterator(): Iterator<T> = list.iterator()
	private val list = LinkedList<T>()
	fun push(v: T) = list.addLast(v)
	fun pop(): T = list.removeLast()
	fun clear() = list.clear()
	override val size: Int get() = list.size
}

class Queue<T> : CollectionSize, Iterable<T> {
	override fun iterator(): Iterator<T> = list.iterator()
	private val list = LinkedList<T>()
	fun queue(v: T) = list.addFirst(v)
	fun dequeue(): T = list.removeLast()
	fun clear() = list.clear()
	override val size: Int get() = list.size
}

fun ByteArray.sub(offset: Int, count: Int): ByteArray {
	return Arrays.copyOfRange(this, offset, offset + count)
}

inline fun ByteArray.getu(offset: Int): Int {
	return this[offset].toInt() and 0xFF
}

class Array2 {
	companion object {
		fun range(width: Int, height: Int): List<Pair<Int, Int>> {
			val rows = (0 until height).toList()
			val columns = (0 until width).toList()
			return rows.flatMap { y -> columns.map { x -> Pair(x, y) } }
		}
	}
}

fun <T : Any> Iterable<T>.without(item:T):List<T> {
	return this.filter { it != item }
}