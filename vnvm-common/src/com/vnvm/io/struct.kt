package com.vnvm.io

import com.vnvm.common.error.InvalidOperationException
import com.vnvm.common.io.BinBytes
import com.vnvm.common.util.reverseBytes
import java.util.*

object Struct {
	inline fun <reified T : Any> read(i: BinBytes): T = read(T::class.java, i)

	fun <T : Any> read(clazz: Class<T>, i: BinBytes): T {
		return _read(clazz, i) as T
	}

	inline fun <reified T : Any> size():Int = _read(T::class.java, null) as Int

	fun <T> _read(clazz: Class<T>, i: BinBytes?): Any? {
		val DEBUG = false
		val debug = DEBUG && i != null
		if (debug) println("Reading class: $clazz {")
		val constructor = clazz.declaredConstructors.firstOrNull() ?: throw InvalidOperationException("Class $clazz doesn't have constructors")
		var count = 0
		val params: List<Any?> = constructor.parameters.map { param ->
			val name = param.name
			val type = param.type
			//val hasLittleEndian = param.annotations.any { it is LittleEndian }
			val hasBigEndian = param.annotations.any { it is BigEndian }
			val isLittleEndian = !hasBigEndian
			val isBigEndian = hasBigEndian
			if (type.isPrimitive) {
				count += when (type.name) {
					"byte" -> 1
					"short" -> 2
					"int" -> 4
					"long" -> 8
					else -> throw UnsupportedOperationException("primitive ${type.name}")
				}
				val result:Any? = when (type.name) {
					"byte" -> i?.readByte()?.toByte()
					"short" -> if (isLittleEndian) i?.readShort()?.toShort() else i?.readShort()?.toShort()?.reverseBytes()
					"int" -> if (isLittleEndian) i?.readInt() else i?.readInt()?.reverseBytes()
					"long" -> if (isLittleEndian) i?.readLong() else i?.readLong()?.reverseBytes()
					else -> throw UnsupportedOperationException("primitive ${type.name}")
				}
				if (debug) println("prim($name): $result")
				result
			} else if (type.isArray) {
				val info = param.annotations.filterIsInstance<ArraySize>().firstOrNull()
					?: throw InvalidOperationException("Param: ($name: $type) in $clazz doesn't have info")
				val zcount = info.value
				count += zcount * when (type.name) {
					"[B" -> 1
					//"[J" -> 8
					else -> throw UnsupportedOperationException("Unsupported array type ${type.name}")
				}
				val result:Any? = when (type.name) {
					"[B" -> i?.readBytes(info.value)
					//"[J" -> if (i != null) (0 until zcount).map { i.readLong() }.toTypedArray() else null
					else -> throw UnsupportedOperationException("Unsupported array type ${type.name}")
				}
				if (debug) println("array($name): $result")
				result
			} else if (type.name == "java.lang.String") {
				val info = param.annotations.filterIsInstance<ArraySize>().firstOrNull()
					?: throw InvalidOperationException("Param: ($name: $type) in $clazz doesn't have info")
				val encodingInfo = param.annotations.filterIsInstance<Encoding>().firstOrNull()
				val trimEndInfo = param.annotations.filterIsInstance<TrimEnd>().firstOrNull()
				val size = info.value
				val trimEnd = trimEndInfo?.chars ?: charArrayOf(0.toChar())
				//val encoding = info.encoding
				val encoding = encodingInfo?.value ?: "UTF-8"
				count += size
				val bytes = i?.readBytes(size)
				val result = bytes?.toString(encoding)?.trimEnd(*trimEnd)
				if (debug) println("string($name): '$result'")
				result
			} /*else if (type.isEnum) {
				println(type.constructors)
				println("--------")
				Enum
			}*/ else {
				val result = _read(type, i)
				if (i == null) {
					count += result as Int
				}
				if (debug) println("struct($name): $result")
				result
			}
		}
		if (i != null) {
			if (debug) {
				println("}")
				println(constructor.declaringClass.toString() + " : " + params.toList())
				println(constructor.parameters.size)
				println(params.size)
				for (arg in constructor.parameters.zip(params)) {
					println("${arg.first}: ${arg.second}")
				}
			}
			return constructor.newInstance(*params.toTypedArray()) as T
		} else {
			return count
		}
	}
}

inline fun <reified T : Any> BinBytes.readStruct(): T = Struct.read<T>(this)

annotation class StructLayout(
	val pack: Int
)

annotation class ArraySize(val value: Int)
annotation class Encoding(val value: String)
annotation class LittleEndian()
annotation class BigEndian()
annotation class TrimEnd(vararg val chars: Char)
//annotation class NoTrimZero()
//annotation class TypeString(val size: Int = -1, val encoding: String = "UTF-8", val stripZero:Boolean = true)
