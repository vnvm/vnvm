package com.vnvm.engine.dividead

import com.vnvm.common.async.EventLoop
import com.vnvm.common.error.ignoreerror
import com.vnvm.common.io.LocalVirtualFileSystem
import com.vnvm.io.IsoFile
import java.io.File

fun main(args: Array<String>) {
	EventLoop.runAndWait {
		val assets = LocalVirtualFileSystem("assets")
		IsoFile.openAsync(assets["dividead.iso"]).then { fs ->
			fun listDl1() {
				DL1.loadAsync(fs["SG.DL1"]).pipe { dl1 ->
					dl1.listAsync().then { list ->
						println(dl1)
						for (file in list) {
							println(file.name + " : " + file.size)
						}
					}
				}
			}

			fun extractAllFiles() {
				val out = File("out")
				ignoreerror { out.mkdirs() }
				DL1.loadAsync(fs["SG.DL1"]).pipe { dl1 ->
					dl1.listAsync().then { list ->
						for (file in list) {
							file.file.readAllAsync().then {
								val it2 = when (file.extension.toLowerCase()) {
									"bmp" -> LZ.decode(it)
									else -> it
								}
								File(out.absolutePath + "/" + file.name).writeBytes(it2)
							}
						}
					}
				}
			}

			//listDl1()
			extractAllFiles()
		}
	}
}