package vfs;
import lang.promise.IPromise;
import flash.errors.Error;

/**
 * ...
 * @author soywiz
 */

class VirtualFileSystemBase 
{
	public function openAsync(name:String):IPromise<Stream>
	{
		throw(new Error("Not implemented VirtualFileSystem.openAsync"));
		return null;
	}
	
	public function existsAsync(name:String):IPromise<Bool>
	{
		throw(new Error("Not implemented"));
		return null;
	}
}