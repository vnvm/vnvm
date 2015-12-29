package com.vnvm.engine.dividead

import com.vnvm.common.async.EventLoop
import com.vnvm.common.io.LocalVirtualFileSystem

fun main(args: Array<String>) {
	fun listDl1() {
		var fs = LocalVirtualFileSystem("assets")

		fs["dividead/SG.DL1"].openAsync()
		fs["dividead/SG.DL1"].openAsync().pipe {
			DL1.loadAsync(it)
		}.pipe { dl1 ->
			dl1.listAsync().then { list ->
				println(dl1)
				for (file in list) {
					println(file.name + " : " + file.size)
				}
			}
		}
	}

	EventLoop.runAndWait {
		listDl1();
	}
}