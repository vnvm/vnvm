package vfs;

import promhx.Promise;
import haxe.Log;

#if (cpp || neko)
import sys.FileSystem;

/**
 * ...
 * @author soywiz
 */

class LocalFileSystem extends VirtualFileSystem
{
	var path:String;
	
	public function new(path:String) 
	{
		this.path = path;
	}
	
	override public function openAsync(name:String):Promise<Stream> 
	{
		return Promise.promise(cast(new FileStream(this.path + "/" + name), Stream));
	}
	
	override public function existsAsync(name:String):Promise<Bool> 
	{
		return Promise.promise(FileSystem.exists(this.path + "/" + name));
	}
}
#end