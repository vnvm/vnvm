package vfs;

import promhx.Promise;

/**
 * ...
 * @author soywiz
 */

class SubVirtualFileSystem extends VirtualFileSystem
{
	var parent:VirtualFileSystem;
	var path:String;
	
	private function new(parent:VirtualFileSystem, path:String) {
		this.parent = parent;
		this.path = path;
	}
	
	override public function openAsync(name:String):Promise<Stream> 
	{
		return parent.openAsync(this.path + "/" + name);
	}
	
	override public function existsAsync(name:String):Promise<Bool>
	{
		return parent.existsAsync(this.path + "/" + name);
	}
	
	static public function fromSubPath(parent:VirtualFileSystem, path:String):SubVirtualFileSystem {
		return new SubVirtualFileSystem(parent, path);
	}
}