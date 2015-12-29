package com.vnvm.common.io

import com.vnvm.common.async.Promise
import java.io.File

class VfsFile(val vfs: VirtualFileSystem, val path: String) {
	fun openAsync(): Promise<AsyncStream> = vfs.openAsync(path)
	fun listAsync(): Promise<List<VfsStat>> = vfs.listAsync(path)
	fun statAsync(): Promise<VfsStat> = vfs.statAsync(path)
	fun readAllAsync(): Promise<ByteArray> = vfs.readAllAsync(path)
	operator fun get(subpath: String) = VfsFile(vfs, "$path/$subpath") // @TODO: Security!
}

data class VfsStat(
	val file: VfsFile, val size: Long
) {
	val name:String = file.path

}

interface VirtualFileSystem {
	fun openAsync(name: String): Promise<AsyncStream>
	fun statAsync(name: String): Promise<VfsStat>
	fun listAsync(name: String): Promise<List<VfsStat>>
}

fun VirtualFileSystem.root():VfsFile {
	return VfsFile(this, "")
}

fun VirtualFileSystem.readAllAsync(path: String): Promise<ByteArray> {
	return openAsync(path).pipe { stream ->
		stream.readBytesAsync(stream.length.toInt()).then {
			stream.close()
			it
		}
	}
}

private class _LocalVirtualFileSystem(val basepath:String) : VirtualFileSystem {
	val absolutePath = File(basepath).absolutePath

	override fun listAsync(path:String): Promise<List<VfsStat>> {
		return Promise.resolved(File(absolutePath).listFiles().map { getStat(it) })
	}

	override fun statAsync(path:String): Promise<VfsStat> {
		return Promise.resolved(getStat(resolveFile(path)))
	}

	override fun openAsync(path: String): Promise<AsyncStream> {
		return Promise.resolved(FileAsyncStream(resolveFile(path)))
	}

	private fun getStat(file:File):VfsStat {
		return VfsStat(VfsFile(this, file.name), file.length())
	}

	private fun resolveFile(path:String):File {
		return File(absolutePath + "/" + path)
	}
}

fun LocalVirtualFileSystem(basepath: String): VfsFile {
	return _LocalVirtualFileSystem(basepath).root()
}