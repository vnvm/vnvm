package common.io;
import common.ByteUtils;
import haxe.io.Bytes;
import nme.errors.Error;
import nme.utils.ByteArray;
import sys.FileStat;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileSeek;

/**
 * ...
 * @author soywiz
 */

class FileStream extends Stream
{
	var fileStat:FileStat;
	var fileInput:FileInput;

	public function new(name:String) 
	{
		if (!FileSystem.exists(name)) throw(new Error(Std.format("File '$name' doesn't exist")));
		this.fileInput = File.read(name);
		this.position = 0;
		this.fileStat = FileSystem.stat(name);
		this.length = fileStat.size;
	}
	
	override public function readBytesAsync(length:Int, done:ByteArray -> Void):Void 
	{
		fileInput.seek(position, FileSeek.SeekBegin);
		
		var bytes:Bytes = fileInput.read(length);
		
		position += bytes.length;
		
		done(ByteUtils.BytesToByteArray(bytes));
	}
	
}