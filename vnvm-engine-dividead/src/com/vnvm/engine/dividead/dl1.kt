package com.vnvm.engine.dividead

import com.vnvm.common.async.Promise
import com.vnvm.common.error.InvalidArgumentException
import com.vnvm.common.io.*
import com.vnvm.common.log.Log
import java.io.FileNotFoundException
import java.util.*

class DL1 : VirtualFileSystem {
	private var entries = LinkedHashMap<String, AsyncStream>();

	companion object {
		fun loadAsync(stream: AsyncStream): Promise<VfsFile> {
			var header: ByteArray;
			var entriesByteArray: ByteArray;
			val dl1 = DL1();

			// Read header
			return stream.readBytesAsync(0x10).pipe {
				val header = BinBytes(it)
				val magic = header.readUTFBytes(8).replace(String(charArrayOf(0.toChar())), "");
				val count = header.readUnsignedShort();
				val offset = header.readUnsignedInt();
				var pos = 0x10;

				Log.trace("Loading entries from DL1 $count: $offset");

				if (magic != ("DL1.0" + String(charArrayOf(0x1A.toChar())))) throw InvalidArgumentException("Invalid DL1 file. Magic : '$magic'");

				//Log.trace(Std.format("DL1: {offset=$offset, count=$count}"));

				// Read entries
				stream.position = offset.toLong();
				stream.readBytesAsync(16 * count).then {
					val entriesByteArray = BinBytes(it)
					for (n in 0 until count) {
						var name: String = entriesByteArray.readUTFBytes(12).replace(String(charArrayOf(0.toChar())), "");
						var size: Int = entriesByteArray.readUnsignedInt();
						dl1.entries[name.toUpperCase()] = stream.sliceLength(pos.toLong(), size.toLong());
						pos += size;
					}
				}
			}.then {
				dl1.root()
			}
		}
	}

	override public fun listAsync(path: String): Promise<List<VfsStat>> {
		return Promise.resolved(this.entries.map {
			val (name, info) = it
			VfsStat(VfsFile(this, name), info.length)
		}.filter { it.name.startsWith(path) })
	}

	override public fun statAsync(path: String): Promise<VfsStat> {
		return Promise.resolved(VfsStat(VfsFile(this, path), getEntry(path).length))
	}

	public fun listFiles(): Iterable<String> {
		return this.entries.keys
	}

	private fun getEntry(name:String):AsyncStream {
		val name = name.toUpperCase().trimStart('/');
		if (name !in entries) throw FileNotFoundException("Can't find '$name'")
		return entries[name]!!
	}

	override public fun openAsync(name: String): Promise<AsyncStream> {
		return Promise.resolved(getEntry(name).clone())
	}
}
