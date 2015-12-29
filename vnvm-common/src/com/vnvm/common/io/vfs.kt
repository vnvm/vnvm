package com.vnvm.common.io

import com.vnvm.common.async.Promise
import java.io.File

class VfsFile(val vfs: VirtualFileSystem, val path: String) {
	fun openAsync(): Promise<AsyncStream> = vfs.openAsync(path)
	fun access(subpath: String) = VfsFile(vfs, "$path/$subpath") // @TODO: Security!
}

data class VfsStat(
	val file: VfsFile, val size: Long
) {
	val name:String = file.path

}

interface VirtualFileSystem {
	fun openAsync(name: String): Promise<AsyncStream>
	fun listFilesAsync(): Promise<List<VfsStat>>
}

fun VirtualFileSystem.readAllAsync(path: String): Promise<ByteArray> {
	return openAsync(path).pipe { stream ->
		stream.readBytesAsync(stream.length.toInt()).then {
			stream.close()
			it
		}
	}
}

class LocalVirtualFileSystem(val basepath:String) : VirtualFileSystem {
	val absolutePath = File(basepath).absolutePath

	override fun listFilesAsync(): Promise<List<VfsStat>> {
		return Promise.resolved(File(absolutePath).listFiles().map {
			VfsStat(VfsFile(this, it.name), it.length())
		})
	}

	override fun openAsync(name: String): Promise<AsyncStream> {
		return Promise.resolved(FileAsyncStream(File(absolutePath + "/" + name)))
	}
}