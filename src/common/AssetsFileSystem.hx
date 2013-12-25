package common;
import vfs.HttpFileSystem;
import vfs.VirtualFileSystem;
import haxe.Log;

/**
 * ...
 * @author soywiz
 */
class AssetsFileSystem
{
	static private var _assetsFileSystem:IAssetsFileSystem;

	static private function getAssetsFileSystemFactory():IAssetsFileSystem
	{
		if (_assetsFileSystem == null)
		{
			#if (cpp || neko)
				_assetsFileSystem = new common.AssetsFileSystemCpp();
			#else
				_assetsFileSystem = new common.AssetsFileSystemAs3();
			#end
		}
		return _assetsFileSystem;
	}

	static public function getAssetsLocalPath():String
	{
		return getAssetsFileSystemFactory().getAssetsLocalPath();
	}

	static public function getAssetsFileSystem():VirtualFileSystem
	{
		return getAssetsFileSystemFactory().getAssetsFileSystem();
	}
}
