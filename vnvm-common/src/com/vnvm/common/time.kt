package com.vnvm.common

import java.util.*

data class TimeSpan(val ms: Int) {
	val milliseconds:Int get() = ms
	val seconds:Double get() = ms.toDouble() / 1000.0
}
data class DateTime(val date: Date) {
	companion object {
		fun nowMillis():Long = System.currentTimeMillis()
	}
}

val Double.milliseconds: TimeSpan get() = TimeSpan(this.toInt())
val Double.seconds: TimeSpan get() = TimeSpan((this * 1000).toInt())

val Int.milliseconds: TimeSpan get() = TimeSpan(this.toInt())
val Int.seconds: TimeSpan get() = TimeSpan((this * 1000).toInt())

inline fun <T> measure(callback: () -> T): T {
	return callback()
}