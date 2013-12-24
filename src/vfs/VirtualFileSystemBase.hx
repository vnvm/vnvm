package vfs;
import flash.errors.Error;
import promhx.Promise.Promise;

/**
 * ...
 * @author soywiz
 */

class VirtualFileSystemBase 
{
	public function openAsync(name:String):Promise<Stream>
	{
		throw(new Error("Not implemented VirtualFileSystem.openAsync"));
		return null;
	}
	
	public function existsAsync(name:String):Promise<Bool>
	{
		throw(new Error("Not implemented"));
		return null;
	}
}