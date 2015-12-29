package com.vnvm.common

data class TimeSpan(val ms:Int)

val Double.milliseconds: TimeSpan get() = TimeSpan(this.toInt())
val Double.seconds: TimeSpan get() = TimeSpan((this * 1000).toInt())

val Int.milliseconds: TimeSpan get() = TimeSpan(this.toInt())
val Int.seconds: TimeSpan get() = TimeSpan((this * 1000).toInt())