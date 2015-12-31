package com.vnvm.common

interface Disposable {
	fun dispose(): Unit
}

class DisposableGroup : Disposable {
	private val items = arrayListOf<Disposable>()
	fun add(disposable:Disposable):Disposable {
		items.add(disposable)
		return disposable
	}
	fun remove(disposable:Disposable):Disposable {
		items.remove(disposable)
		return disposable
	}

	override fun dispose() {
		for (item in items) item.dispose()
		items.clear()
	}
}