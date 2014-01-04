package engines.ethornell;
import vfs.SliceStream;
import vfs.Stream;
import vfs.VirtualFileSystem;
import lang.StringEx;
import engines.brave.cgdb.CgDbEntry;
import flash.errors.Error;
import flash.utils.ByteArray;

/**
 * Class to have read access to ARC files.
 * 
 * @author soywiz
 */
class ARC
{
	public var baseStream:Stream;
	public var fileStream:Stream;
	public var table:Array<Entry>;
	public var tableLookup:Map<String, Entry>;

	private function new(s:Stream)
	{
		this.baseStream = s;
		this.table = new Array<Entry>();
		this.tableLookup = new Map<String, Entry>();
	}

	static public function openAsyncFromFileSystem(fs:VirtualFileSystem, fileName:String, done:ARC -> Void):Void
	{
		var stream:Stream;
		fs.openAsync(fileName).then(function(stream:Stream):Void {
			openAsync(stream, done, fileName);
		});
	}

	/**
	 * Open a ARC using an stream.
	 * 
	 * @param	s
	 * @param	name
	 */
	static public function openAsync(stream:Stream, done:ARC -> Void, name:String = "unknwon")
	{
		var arc:ARC = new ARC(stream);
		var ba:ByteArray;
		// 12 + 4
		
		stream.position = 0;
		stream.readBytesAsync(12 + 4).then(function(ba:ByteArray):Void {
			var magic:String = ba.readUTFBytes(12);
			var tableLength:Int = ba.readUnsignedInt();
			if (magic != "PackFile    ") throw(new Error('It doesn\'t seems to be an ARC file (\'$name\')'));
		
			arc.fileStream = SliceStream.fromBounds(
				arc.baseStream,
				arc.baseStream.position + (0x20 * tableLength),
				arc.baseStream.length
			);
			
			stream.readBytesAsync(0x20 * tableLength).then(function(ba:ByteArray):Void {
				for (n in 0 ... tableLength) {
					var entry:Entry = Entry.createFromArcAndByteArray(arc, ba);
					arc.table.push(entry);
					arc.tableLookup.set(entry.name, entry);
				}
				done(arc);
			});
		});
	}
}

private class Entry {
	/**
	 * Stringz with the name of the file.
	 */
	public var name:String;
	
	/**
	 * Start position of the content. (Slice of the file).
	 */
	public var offset:Int;
	
	/**
	 * Length of the file contents. (Slice of the file).
	 */
	public var length:Int;
	
	/**
	 * Unused area 0
	 */
	public var _pad0:Int;
	
	/**
	 * Unused area 1
	 */
	public var _pad1:Int;
	
	/**
	 * 
	 */
	public var arc:ARC;
	
	/**
	 * 
	 * @param	arc
	 */
	private function new(arc:ARC) {
		this.arc = arc;
	}
	
	static public function createFromArcAndByteArray(arc:ARC, data:ByteArray):Entry {
		var entry:Entry = new Entry(arc);
		entry.readFromByteArray(data);
		return entry;
	}
	
	/**
	 * 
	 * @param	ba
	 */
	private function readFromByteArray(data:ByteArray):Void {
		name = StringEx.trimEnd(data.readUTFBytes(0x10), String.fromCharCode(0));
		offset = data.readUnsignedInt();
		length = data.readUnsignedInt();
		_pad0 = data.readUnsignedInt();
		_pad1 = data.readUnsignedInt();
	}
	
	public function toString():String {
		return StringEx.sprintf("'%s' (%08X-%08X)", [name, offset, length]);
	}
	
	public function readAsync(done:ByteArray -> Void):Void {
		//throw(new Error("Not implemented ARC.Entry.readAsync"));
		SliceStream.fromLength(arc.fileStream, this.offset, this.length
		).readAllBytesAsync().then(function(byteArray:ByteArray) {
			done(byteArray);
		});
	}	
}