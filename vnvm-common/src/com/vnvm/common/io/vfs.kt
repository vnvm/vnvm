package com.vnvm.common.io

import com.vnvm.common.async.Promise
import java.io.File

class VfsFile(val vfs: VirtualFileSystem, val path: String) {
	fun openAsync(): Promise<AsyncStream> = vfs.openAsync(path)
	fun listAsync(): Promise<List<VfsStat>> = vfs.listAsync(path)
	fun statAsync(): Promise<VfsStat> = vfs.statAsync(path)
	fun existsAsync(): Promise<Boolean> = this.statAsync().then { it.exists }
	fun readAllAsync(): Promise<ByteArray> = vfs.readAllAsync(path)
	fun jail(): VfsFile = JailVirtualFileSystem(this).root()
	operator fun get(subpath: String) = VfsFile(vfs, "$path/$subpath".trimStart('/')) // @TODO: Security!
	override public fun toString() = "VfsFile($path)"
}

data class VfsStat(
	val file: VfsFile,
	val size: Long,
    val exists:Boolean
) {
	val name:String = file.path

	val extension:String = File(name).extension
}

interface VirtualFileSystem {
	fun openAsync(path: String): Promise<AsyncStream>
	fun statAsync(path: String): Promise<VfsStat>
	fun listAsync(path: String): Promise<List<VfsStat>>
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

private class JailVirtualFileSystem(val file: VfsFile) : VirtualFileSystem {
	private fun getJailedPath(path:String): String {
		// @TODO: Security! expand ".."
		return (this.file.path + "/" + path).trimStart('/')
	}

	override fun openAsync(path: String): Promise<AsyncStream> {
		return file.vfs.openAsync(getJailedPath(path))
	}

	override fun statAsync(path: String): Promise<VfsStat> {
		return file.vfs.statAsync(getJailedPath(path))
	}

	override fun listAsync(path: String): Promise<List<VfsStat>> {
		return file.vfs.listAsync(getJailedPath(path))
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
		try {
			return VfsStat(VfsFile(this, file.name), file.length(), true)
		} catch (e:Throwable) {
			return VfsStat(VfsFile(this, file.name), 0L, false)
		}
	}

	private fun resolveFile(path:String):File {
		return File(absolutePath + "/" + path)
	}
}

fun LocalVirtualFileSystem(basepath: String): VfsFile {
	return _LocalVirtualFileSystem(basepath).root()
}