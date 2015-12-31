package com.vnvm.common.async

import com.vnvm.common.DateTime
import com.vnvm.common.Disposable
import com.vnvm.common.DisposableGroup
import com.vnvm.common.TimeSpan
import com.vnvm.common.collection.Queue
import com.vnvm.common.collection.isEmpty
import com.vnvm.common.collection.isNotEmpty
import com.vnvm.common.error.TimeoutException
import com.vnvm.common.log.Log
import java.util.*

class Promise<T : Any>(var parent: Promise<*>?) {
	private var resolved: Boolean = false
	private var resolvedValue: T? = null
	private var resolvedException: Throwable? = null
	private val callbacks = Queue<(T) -> Any>()
	private val failcallbacks = Queue<(Throwable) -> Any>()


	private constructor(parent: Promise<*>?, value: Throwable) : this(null) {
		resolved = true
		resolvedException = value
	}

	class Deferred<T : Any> {
		public val promise: Promise<T> = Promise<T>(null)

		public fun resolve(value: T) {
			this.promise.resolve(value)
		}

		public fun progress(value: Double) {
			this.promise.progress(value)
		}

		public fun reject(value: Throwable) {
			this.promise.reject(value);
		}
	}

	companion object {
		fun <T : Any> invoke(callback: (resolve: (value: T) -> Unit, reject: (error: Throwable) -> Unit) -> Unit): Promise<T> {
			val deferred = Deferred<T>()
			callback({ deferred.resolve(it) }, { deferred.reject(it) })
			return deferred.promise
		}

		fun <T : Any> create(callback: (resolve: (value: T) -> Unit, reject: (error: Throwable) -> Unit) -> Unit): Promise<T> {
			val deferred = Deferred<T>()
			callback({ deferred.resolve(it) }, { deferred.reject(it) })
			return deferred.promise
		}

		fun <T : Any> sequence(vararg promises: () -> Promise<T>): Promise<List<T>> {
			return sequence(promises.toList())
		}

		fun <T : Any> sequence(promises: Iterable<() -> Promise<T>>): Promise<List<T>> {
			val items = promises.toCollection(LinkedList())
			if (items.size == 0) return Promise.resolved(listOf<T>())
			val out = ArrayList<T>(items.size)
			val deferred = Deferred<List<T>>()
			fun step() {
				if (items.isEmpty()) {
					deferred.resolve(out)
				} else {
					val promiseGenerator = items.removeFirst()
					val promise = promiseGenerator()
					promise.then {
						out.add(it)
						step()
					}.fail {
						deferred.reject(it)
					}
				}
			}
			EventLoop.queue { step() }
			return deferred.promise
		}

		fun chain(): Promise<Unit> = resolved(Unit)

		@Deprecated("Use resolved", ReplaceWith("this.resolved(Unit)"))
		fun resolve() = Promise.resolved(Unit)

		fun <T : Any> resolved(value: T): Promise<T> {
			if (value is Promise<*>) {
				return value as Promise<T>
			} else {
				val deferred = Deferred<T>()
				deferred.resolve(value)
				return deferred.promise
			}
		}

		fun <T : Any> rejected(value: Throwable): Promise<T> {
			return Promise(null, value);
		}

		fun <T : Any> all(vararg promises: Promise<T>): Promise<List<T>> {
			return all(promises.toList())
		}

		fun <T : Any> all(promises: Iterable<Promise<T>>): Promise<List<T>> {
			val promiseList = promises.toList()
			var count = 0
			val total = promiseList.size

			val out = arrayListOf<T?>()
			val deferred = Deferred<List<T>>()
			for (n in 0..total - 1) out.add(null)

			fun checkDone() {
				if (count >= total) {
					deferred.resolve(out.map { it!! })
				}
			}

			promiseList.indices.forEach {
				val index = it
				val promise = promiseList[index]
				promise.then {
					out[index] = it
					count++
					checkDone()
				}
			}

			checkDone()

			return deferred.promise
		}

		/*
		fun create<T>(callback: (resolve: (value:T) -> Unit, reject:(exception:Throwable) -> Unit) -> Unit):Promise<T> {
			val deferred = Deferred<T>()
			return deferred.promise
		}
		*/
		fun <T : Any> forever(): Promise<T> {
			return Deferred<T>().promise
		}

		fun <T : Any> any(vararg promises: Promise<T>): Promise<T> {
			val deferred = Promise.Deferred<T>()
			for (promise in promises) {
				promise.then { deferred.resolve(it) }.fail { deferred.reject(it) }
			}
			return deferred.promise
		}
	}

	internal fun resolve(value: T) {
		if (resolved) return;
		resolved = true
		resolvedValue = value
		parent = null
		flush();
	}

	internal fun reject(value: Throwable) {
		if (resolved) return;
		resolved = true
		resolvedException = value
		parent = null

		// @TODO: Check why this fails!
		if (failcallbacks.isEmpty() && callbacks.isEmpty()) {
			Log.trace("Promise.reject(): Not capturated: $value")
			throw value
		}

		flush();
	}

	internal fun progress(value: Double) {

	}

	private fun flush() {
		if (!resolved || (callbacks.isEmpty() && failcallbacks.isEmpty())) return

		val resolvedValue = this.resolvedValue
		if (resolvedValue != null) {
			while (callbacks.isNotEmpty()) {
				val callback = callbacks.dequeue();
				EventLoop.queue({
					callback(resolvedValue)
				})
			}
		} else if (resolvedException != null) {
			while (failcallbacks.isNotEmpty()) {
				val failcallback = failcallbacks.dequeue();
				EventLoop.queue({
					failcallback(resolvedException!!)
				})
			}
		}
	}

	fun cancel() {
		parent?.cancel()
		parent = null
		cancelledHandlers.dispatch()
	}

	private var cancelledHandlers = Signal<Unit>()

	public fun cancelled(handler: () -> Unit): Promise<T> {
		cancelledHandlers.once { handler() }
		return this;
	}

	public fun <T2 : Any> pipe(callback: (value: T) -> Promise<T2>): Promise<T2> {
		try {
			val out = Promise<T2>(this)
			this.failcallbacks.queue {
				out.reject(it)
			}
			this.callbacks.queue({
				callback(it)
					.then { out.resolve(it) }
					.fail { out.fail { it } }
			})
			return out
		} finally {
			flush()
		}
	}

	public fun <T2 : Any> then(callback: (value: T) -> T2): Promise<T2> {
		try {
			val out = Promise<T2>(this)
			this.failcallbacks.queue {
				out.reject(it)
			}
			this.callbacks.queue {
				try {
					out.resolve(callback(it))
				} catch (t: Throwable) {
					Log.trace("then catch:$t")
					t.printStackTrace()
					out.reject(t)
				}
			}
			return out
		} finally {
			flush()
		}
	}

	public fun <T2 : Any> fail(failcallback: (throwable: Throwable) -> T2): Promise<T2> {
		try {
			val out = Promise<T2>(this)
			this.failcallbacks.queue {
				try {
					out.resolve(failcallback(it))
				} catch (t: Throwable) {
					Log.trace("fail catch:$t")
					t.printStackTrace()
					out.reject(t)
				}
			}
			return out
		} finally {
			flush()
		}
	}

	public fun timeout(time: TimeSpan): Promise<T> {
		return Promise.create<T> { resolve, reject ->
			EventLoop.setTimeout(time) { reject(TimeoutException()) }

			this.then { resolve(it) }.fail { reject(it) }
		}
	}

	fun always(callback: () -> Unit): Promise<T> {
		then { callback() }.fail { callback() }
		return this
	}
}

val Promise.Companion.unit: Promise<Unit> get() = Promise.resolved(Unit)

val <T : Any> Promise<T>.unit: Promise<Unit> get() = then { Unit }

// @TODO: Improve performance using two lists and swapping, instead of cloning callbacks list each dispatch!
class Signal<T : Any> {
	private val callbacks = arrayListOf<(value: T) -> Unit>()

	private class SignalDisposable<T : Any>(val signal: Signal<T>, val callback: (value: T) -> Unit) : Disposable {
		override fun dispose() {
			signal.remove(callback)
		}
	}

	fun removeAll() {
		callbacks.clear()
	}

	private fun remove(callback: (value: T) -> Unit) {
		callbacks.remove(callback)
	}

	fun add(callback: (value: T) -> Unit): Disposable {
		callbacks.add(callback)
		return SignalDisposable(this, callback)
	}

	fun once(callback: (value: T) -> Unit): Disposable {
		var handler: (T) -> Unit = {}
		handler = { value: T ->
			remove(handler)
			callback(value)
		}
		add(handler)
		return SignalDisposable(this, handler)
	}

	fun dispatch(value: T) {
		for (c in callbacks.toList()) c(value)
	}

	operator fun invoke(value: T) = dispatch(value)
}

fun Signal<Unit>.dispatch() {
	return this.dispatch(Unit)
}

fun <T : Any> Signal<T>.pipeTo(that: Signal<T>) {
	this.add { that.dispatch(it) }
}

fun Promise.Companion.waitOneAsync(vararg signals: Signal<*>):Promise<Unit> {
	val deferred = Promise.Deferred<Unit>()
	val disposableGroup = DisposableGroup()
	for (signal in signals) {
		disposableGroup.add(signal.once { disposableGroup.dispose(); deferred.resolve(Unit) })
	}
	return deferred.promise
}

fun <T : Any> List<Signal<T>>.waitOneAsync(): Promise<T> {
	val deferred = Promise.Deferred<T>()
	val disposableGroup = DisposableGroup()
	for (signal in this) {
		disposableGroup.add(signal.once { disposableGroup.dispose(); deferred.resolve(it) })
	}
	return deferred.promise
}

fun <T : Any> Signal<T>.waitOneAsync(): Promise<T> {
	return listOf(this).waitOneAsync()
}

class PromiseQueue() {
	private var promise: Promise<Any> = Promise.resolved(Unit);

	public fun cancel() {
		promise.cancel()
		promise = Promise.resolved(Unit);
	}

	public fun <T> add(func: () -> T): PromiseQueue {
		async2 {
			val result = func()
			if (result is Promise<*>) {
				result as Promise<Any>
			} else {
				Promise.resolved<Any>(Unit)
			}
		}

		return this
	}

	private fun async2(func: () -> Promise<Any>): Promise<Any> {
		promise = promise.pipe { func() }
		return promise
	}

	private fun sync(func: () -> Unit): Promise<Any> {
		promise = promise.then { func() }
		return promise
	}

	val lastPromise: Promise<Any> get() = promise
}

object EventLoop {
	private val items = Queue<() -> Unit>()
	var executing = false

	fun queue(callback: () -> Unit) {
		items.queue(callback)
	}

	fun setTimeout(time: TimeSpan, callback: () -> Unit) = setTimeout(time.milliseconds, callback)

	fun waitAsync(time: TimeSpan): Promise<Unit> {
		return Promise.create { resolve, reject ->
			setTimeout(time) {
				resolve(Unit)
			}
		}
	}

	private val timers = arrayListOf<Pair<Long, () -> Unit>>()
	fun setTimeout(ms: Int, callback: () -> Unit) {
		timers.add(Pair(DateTime.nowMillis() + ms, callback))
	}

	fun process(): Int {
		if (executing) return 0
		var processed = 0

		executing = true
		try {
			while (items.isNotEmpty()) {
				val callback = items.dequeue()
				callback()
				processed++
			}
		} finally {
			executing = false
		}
		return processed
	}

	fun frame(): Int {
		val now = DateTime.nowMillis()
		var processed = 0

		var removeList = listOf<Pair<Long, () -> Unit>>()
		for (timer in timers) {
			if (now >= timer.first) {
				timer.second()
				processed++
				removeList += timer
			}
		}
		timers.removeAll(removeList)

		processed += process()
		return processed
	}

	fun waitAllEvents() {
		while (frame() > 0) Thread.sleep(1L)
	}

	inline fun runAndWait(callback: () -> Unit) {
		callback()
		waitAllEvents()
	}
}
