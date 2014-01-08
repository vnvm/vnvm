package vfs;

import lang.promise.Promise;
import lang.promise.IPromise;
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

	override public function getFileSystemUri():String
	{
		return this.path;
	}

	override public function openAsync(name:String):IPromise<Stream>
	{
		var fullPath:String = getFullPath(name);
		Log.trace('openAsync: "' + fullPath + '"');
		return Promise.createResolved(cast(new FileStream(fullPath), Stream));
	}
	
	override public function existsAsync(name:String):IPromise<Bool>
	{
		var fullPath:String = getFullPath(name);
		var exists = FileSystem.exists(fullPath);
		Log.trace('existsAsync: "' + fullPath + '": ' + exists);
		return Promise.createResolved(exists);
	}
}
