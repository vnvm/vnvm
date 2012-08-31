package common.io;

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
	
	override public function openAsync(name:String, done:Stream -> Void):Void 
	{
		done(new FileStream(this.path + "/" + name));
	}
}