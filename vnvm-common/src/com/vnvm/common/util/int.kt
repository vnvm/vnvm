package com.vnvm.common.util

fun Int.hasBit(offset:Int):Boolean = (this and (1 shl offset)) != 0
fun Byte.hasBit(offset:Int):Boolean = (this.toInt() and (1 shl offset)) != 0

fun Long.reverseBytes():Long = java.lang.Long.reverseBytes(this)
fun Int.reverseBytes():Int = java.lang.Integer.reverseBytes(this)
fun Short.reverseBytes():Short = java.lang.Short.reverseBytes(this)
fun Byte.toUint():Int = this.toInt() and 0xFF

fun String.toInt(default:Int):Int = try { this.toInt() } catch (e:Throwable) { default }
