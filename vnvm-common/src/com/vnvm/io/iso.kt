package com.vnvm.io

import com.vnvm.common.async.Promise
import com.vnvm.common.async.unit
import com.vnvm.common.io.*
import com.vnvm.common.util.hasBit
import com.vnvm.common.util.substr
import com.vnvm.common.util.toInt
import com.vnvm.common.util.toUint
import java.util.*
import kotlin.properties.Delegates

private val SECTOR_SIZE = 0x800

class IsoFile private constructor(
	val s: AsyncStream,
	val pvd: PrimaryVolumeDescriptor
) : VirtualFileSystem {
	var root by Delegates.notNull<IsoNode>()

	companion object {
		fun openAsync(isoFile: VfsFile): Promise<VfsFile> {
			return isoFile.openAsync().pipe { openAsync(it) }
		}
		fun openAsync(s: AsyncStream): Promise<VfsFile> {
			s.position = SECTOR_SIZE.toLong() * 0x10
			return s.readBytesAsync(Struct.size<PrimaryVolumeDescriptor>()).pipe {
				val pvd = BinBytes(it).readStruct<PrimaryVolumeDescriptor>()
				//println(pvd.directoryRecord)
				val iso = IsoFile(s, pvd)
				val root = IsoNode(iso, pvd.directoryRecord);
				iso.root = root
				iso.processDirectoryRecordAsync(root).then {
					iso.root()
				}
			}
		}
	}

	private fun processDirectoryRecordAsync(parentNode: IsoNode): Promise<Unit> {
		val directoryStart = parentNode.dr.extent.value.toLong() * SECTOR_SIZE
		val directoryLength = parentNode.dr.size.value
		val directoryStream = this.s.sliceLength(directoryStart, directoryLength.toLong())

		val DirectoryRecordStructSize = Struct.size<DirectoryRecord>()

		println("Read stream: $directoryStart, $directoryLength")
		return directoryStream.readBytesAsync(directoryStream.length.toInt()).pipe { bytes ->
			val ds = BinBytes(bytes)

			while (!ds.eof) {
				//println("" + ds.position + "; " + ds.available)
				//writefln("%08X : %08X : %08X", directoryStream.position, directoryStart, directoryLength);
				var DirectoryRecordSize = ds.readUnsignedByte()

				// Even if a directory spans multiple sectors, the directory entries are not permitted to cross the sector boundary (unlike the path table).
				// Where there is not enough space to record an entire directory entry at the end of a sector, that sector is zero-padded and the next
				// consecutive sector is used.
				if (DirectoryRecordSize == 0) {
					//println("skip sector!")
					ds.position = (ds.position + 0x800) and (0x7FF.inv())
					//Console.WriteLine("AlignedTo: {0:X}", DirectoryStream.Position);
					continue;
				}

				ds.position -= 1

				//Console.WriteLine("[{0}:{1:X}-{2:X}]", DirectoryRecordSize, DirectoryStream.Position, DirectoryStream.Position + DirectoryRecordSize);

				val DirectoryRecordBytes = ds.readBytes(DirectoryRecordSize)
				var DirectoryRecord = BinBytes(DirectoryRecordBytes).readStruct<DirectoryRecord>()

				val name2 = String(DirectoryRecordBytes.copyOfRange(DirectoryRecordStructSize, DirectoryRecordStructSize + DirectoryRecord.nameLength), "UTF-8");

				// @TODO: Get long name
				val name = name2.split(';').first()

				//println(name)

				if (name == "\u0000" || name == "\u0001") continue;

				//writefln("   %s", name);

				var childIsoNode = IsoNode(this, DirectoryRecord, name, parentNode);
				parentNode.children.add(childIsoNode);
			}

			Promise.all(parentNode.children.filter { it.isDirectory }.map {
				processDirectoryRecordAsync(it)
			}).unit
		}
	}

	fun locateNode(path:String):IsoNode = root[path]

	override fun openAsync(path: String) = Promise.resolved(locateNode(path).openAsync())
	override fun statAsync(path: String) = Promise.resolved(try {
		locateNode(path).vfsStat
	} catch (t:Throwable) {
		VfsStat(VfsFile(this, path), 0L, false)
	})
	override fun listAsync(path: String) = Promise.resolved(locateNode(path).children.map { it.vfsStat })
}

public class IsoNode(
	val iso: IsoFile,
	val dr: DirectoryRecord,
	val name: String = "",
	val parent: IsoNode? = null
) {
	val path: String = if (parent != null) "${parent.path}/$name" else "$name"
	val isDirectory = dr.flags.isDirectory
	val children = arrayListOf<IsoNode>()
	val tree: List<IsoNode> by lazy {
		listOf(this) + this.children.flatMap { it.tree }
	}
	fun openAsync():AsyncStream {
		return iso.s.sliceLength(dr.offset, dr.size.value.toLong())
	}

	val vfsStat: VfsStat get() = VfsStat(VfsFile(iso, path), dr.size.value.toLong(), true)

	override fun toString() = "IsoNode($path)"

	operator fun get(path:String):IsoNode = get(path.split('/'))

	private fun get(chunks:List<String>):IsoNode {
		if (chunks.size == 0) return this
		val tail = chunks.drop(1)
		val head = chunks.first()
		return when (head) {
			"", "." ->  this
			".." -> parent ?: this
			else -> children.first { it.name.toUpperCase() == head.toUpperCase() }
		}.get(tail)
	}
}

data class u16b(@LittleEndian val l: Short, @BigEndian val b: Short) {
	val value = l
}

data class u32b(@LittleEndian val l: Int, @BigEndian val b: Int) {
	val value = l
}

public data class VolumeDescriptorHeader(
	val type: TypeEnum,
	@ArraySize(5) val id: String,
	val version: Byte
) {
	public data class TypeEnum(val value: Byte) {
		val isBootRecord = value.toInt() == 0x00
		val isVolumePartitionSetTerminator = value.toInt() == 0xFF.toInt()
		val isPrimaryVolumeDescriptor = value.toInt() == 0x01.toInt()
		val isSupplementaryVolumeDescriptor = value.toInt() == 0x02.toInt()
		val isVolumePartitionDescriptor = value.toInt() == 0x03.toInt()
	}
}

public data class DirectoryRecord(
	val length: Byte,
	val extendedAttributeLength: Byte,
	val extent: u32b,
	val size: u32b,
	val date: DateStruct,
	val flags: FlagsEnum,
	val fileUnitSize: Byte,
	val interleave: Byte,
	val volumeSequenceNumber: u16b,
	val nameLength: Byte
) {
	public data class DateStruct(
		val year: Byte,
		val month: Byte,
		val day: Byte,
		val hour: Byte,
		val minute: Byte,
		val second: Byte,
		val offset: Byte
	) {
		val fullYear = 1900 + year.toUint()
	}

	public data class FlagsEnum(val v: Byte) {
		//val Unknown1 = v.hasBit(0)
		val isDirectory = v.hasBit(1)
		//val Unknown2 = v.hasBit(2)
		//val Unknown3 = v.hasBit(3)
		//val Unknown4 = v.hasBit(4)
		//val Unknown5 = v.hasBit(5)
	}

	val offset: Long = extent.l.toLong() * SECTOR_SIZE
}

@StructLayout(pack = 1)
public data class PrimaryVolumeDescriptor(
	val volumeDescriptorHeader: VolumeDescriptorHeader,
	val pad1: Byte,
	@ArraySize(0x20) val systemId: String,
	@ArraySize(0x20) val volumeId: String,
	val pad2: Long,
	val volumeSpaceSize: u32b,
	@ArraySize(4 * 8) val pad3: ByteArray,
	val volumeSetSize: Int,
	val volumeSequenceNumber: Int,
	val logicalBlockSize: u16b,
	val pathTableSize: u32b,
	val TypeLPathTable: Int,
	val OptType1PathTable: Int,
	val TypeMPathTable: Int,
	val OptTypeMPathTable: Int,
	val directoryRecord: DirectoryRecord,
	val pad4: Byte,
	@ArraySize(0x80) @TrimEnd(' ', 0.toChar()) val volumeSetId: String,
	@ArraySize(0x80) @TrimEnd(' ', 0.toChar()) val publisherId: String,
	@ArraySize(0x80) @TrimEnd(' ', 0.toChar()) val preparerId: String,
	@ArraySize(0x80) @TrimEnd(' ', 0.toChar()) val applicationId: String,
	@ArraySize(37) @TrimEnd(' ', 0.toChar()) val copyrightFileId: String,
	@ArraySize(37) @TrimEnd(' ', 0.toChar()) val abstractFileId: String,
	@ArraySize(37) @TrimEnd(' ', 0.toChar()) val bibliographicFileId: String,
	val creationDate: IsoDate,
	val modificationDate: IsoDate,
	val expirationDate: IsoDate,
	val effectiveDate: IsoDate,
	val fileStructureVersion: Byte,
	val pad5: Byte,
	@ArraySize(0x200) val applicationData: ByteArray,
	@ArraySize(653) val pad6: ByteArray
)

@StructLayout(pack = 1)
public class IsoDate(
	@ArraySize(17) @Encoding("UTF-8") val data: String
) {
	val year = data.substr(0, 4).toInt(1989)
	val month = data.substr(4, 2).toInt(1)
	val day = data.substr(6, 2).toInt(1)
	val hour = data.substr(8, 2).toInt(0)
	val minute = data.substr(10, 2).toInt(0)
	val second = data.substr(12, 2).toInt(0)
	val hsecond = data.substr(14, 2).toInt(0)
	val offset = data.substr(16, 1).toInt(0)
	val date = Date(year, month, day, hour, minute, second)
}
