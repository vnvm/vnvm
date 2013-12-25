package common;

import vfs.HttpFileSystem;
import haxe.Log;
import vfs.VirtualFileSystem;

class AssetsFileSystemAs3 implements IAssetsFileSystem
{
	public function new() {}

	public function getAssetsLocalPath():String
	{
		//return "assets";
		return "../../../assets";
	}

	public function getAssetsFileSystem():VirtualFileSystem
	{
		Log.trace('flash.AssetsFileSystem.getAssetsFileSystem()');
		return new HttpFileSystem(getAssetsLocalPath());
	}
}