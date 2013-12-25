package vfs;

import promhx.Promise;
import haxe.Log;

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

	private function getFullPath(name:String):String
	{
		return this.path + "/" + name;
	}
	
	override public function openAsync(name:String):Promise<Stream> 
	{
		var fullPath:String = getFullPath(name);
		Log.trace('openAsync: "' + fullPath + '"');
		return Promise.promise(cast(new FileStream(fullPath), Stream));
	}
	
	override public function existsAsync(name:String):Promise<Bool> 
	{
		var fullPath:String = getFullPath(name);
		var exists = FileSystem.exists(fullPath);
		Log.trace('existsAsync: "' + fullPath + '": ' + exists);
		return Promise.promise(exists);
	}
}
