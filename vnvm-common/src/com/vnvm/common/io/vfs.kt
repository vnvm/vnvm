package com.vnvm.common.io

import com.vnvm.common.async.Promise
import com.vnvm.common.error.noImpl

class VfsFile(val vfs:VirtualFileSystem, val path:String) {
	fun openAsync(): Promise<AsyncStream> = vfs.openAsync(path)
	fun access(subpath: String) = VfsFile(vfs, "$path/$subpath") // @TODO: Security!
}

interface VirtualFileSystem {
	fun openAsync(name: String): Promise<AsyncStream>
}

fun VirtualFileSystem.openAndReadAllAsync(path: String): Promise<ByteArray> = noImpl