package com.vnvm.common.error

class NotImplementedException(val msg: String = "Not implemented") : Exception(msg)
class InvalidArgumentException(val msg: String = "Invalid argument") : Exception(msg)
class InvalidOperationException(val msg: String = "Invalid operation") : Exception(msg)
class OutOfBoundsException(val msg: String = "Out of bounds") : Exception(msg)
class TimeoutException(val msg: String = "Out of bounds") : Exception(msg)

val noImpl: Nothing get() = throw NotImplementedException()

inline fun ignoreerror(callback: () -> Unit): Unit {
	try {
		callback()
	} catch (e: Throwable) {
	}
}