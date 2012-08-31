package common.io;
import common.ByteUtils;
import haxe.io.Bytes;
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
		this.fileInput = File.read(name);
		this.position = 0;
		this.fileStat = FileSystem.stat(name);
		this.length = fileStat.size;
	}
	
	override public function readBytesAsync(length:Int, done:ByteArray -> Void):Void 
	{
		fileInput.seek(position, FileSeek.SeekBegin);
		
		var bytes:Bytes = fileInput.read(length);
		done(ByteUtils.BytesToByteArray(bytes));
	}
	
}