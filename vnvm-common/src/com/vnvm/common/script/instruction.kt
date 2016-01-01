package com.vnvm.common.script

import com.vnvm.common.error.InvalidOperationException
import com.vnvm.common.log.Log
import java.lang.reflect.Method

data class Instruction2(
	val script: String,
	val opcode: OpcodeInfo,
	val parameters: Array<Any>,
	val position: Int = 0,
	val size: Int = -1
) {
	val method = opcode.method
	public fun call(obj: Any): Any? {
		if (opcode.info.unimplemented) {
			Log.trace("Unimplemented: $this");
		} else if (opcode.info.untested) {
			Log.trace("Untested... $this");
		} else if (!opcode.info.skipLog) {
			Log.trace("Executing... $this");
		}
		try {
			return method(obj, *parameters);
		} catch (e:Throwable) {
			val paramcount = parameters.size
			println("FAILED: this=$this : obj=$obj : method=${opcode.method} : paramcount=$paramcount, parameters=${parameters.toList()} : e=$e")
			throw e
		}
	}

	override public fun toString(): String {
		return "%s:%04X(%d): %04X.%s %s".format(script, position, size, opcode.info.id, opcode.method.name, parameters.joinToString(", "))
	}
}

data class OpcodeInfo(
	val method: Method,
	val info: Opcode
)

annotation class Opcode(
	val id: Int,
	val format: String,
	val description: String = "",
	val unimplemented: Boolean = false,
	val savepoint: Boolean = false,
	val untested: Boolean = false,
	val skipLog: Boolean = false
)


data class ScriptOpcodes private constructor(
	val opcodesById: Map<Int, OpcodeInfo>
) {
	companion object {
		fun createWithClass(opcodesClass: Class<*>): ScriptOpcodes {
			return ScriptOpcodes(opcodesClass.methods.flatMap { method ->
				val annotation = method.annotations.filterIsInstance<Opcode>().firstOrNull()
				if (annotation != null) listOf(Pair(annotation.id, OpcodeInfo(method, annotation))) else listOf()
			}.toMap())
		}
	}

	operator public fun get(id: Int): OpcodeInfo {
		return opcodesById[id] ?: throw InvalidOperationException("Unknown opcode ${id}")
	}
}
