package com.vnvm.common.async

import com.vnvm.common.error.noImpl

class Promise<T> {
	fun <U> then(callback: (v:T) -> U): Promise<U> = noImpl
	fun <U> pipe(callback: (v:T) -> Promise<U>): Promise<U> = noImpl

	companion object {
		@Deprecated("", ReplaceWith("Promise.resolved(value)"))
		fun <T> createResolved(value:T): Promise<T> = resolved(value)
		fun <T> resolved(value:T): Promise<T> = noImpl
		fun <T> whenAll(vararg promises: Promise<T>): Promise<Array<T>> = noImpl
		val unit: Promise<Unit> get() = resolved(Unit)
	}
}

class Deferred<T> {
	val promise: Promise<T> get() = noImpl
}

class Signal<T> {

}