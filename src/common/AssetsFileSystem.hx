package common;
import vfs.HttpFileSystem;
import vfs.VirtualFileSystem;
import haxe.Log;
import flash.errors.Error;

#if (cpp || neko)
import sys.FileSystem;
import vfs.LocalFileSystem;

/**
 * ...
 * @author soywiz
 */

class AssetsFileSystem 
{
	static public function getAssetsLocalPath():String {
		for (tryPath in [
			"/mnt/sdcard/vnvm",
			"/private/var/mobile/vnvm",
			flash.filesystem.File.applicationDirectory.nativePath + "/assets",
			"assets", "../assets", "../../assets", "../../../assets", "../../../../assets"
		]) {
			#if !neko
			Log.trace('Try path \'$tryPath\'');
			#end
			if (FileSystem.exists(tryPath) && FileSystem.isDirectory(tryPath)) {
				#if !neko
				Log.trace('Found assets at \'$tryPath\'');
				#end
				return tryPath;
			}
		}
		throw(new Error("Can't locate assets folder"));
	}

	static public function getAssetsFileSystem():VirtualFileSystem {
		return new LocalFileSystem(getAssetsLocalPath());
	}
}
#else

class AssetsFileSystem 
{
	static public function getAssetsLocalPath():String {
		//return "assets";
		return "../../../assets";
	}

	static public function getAssetsFileSystem():VirtualFileSystem
	{
		Log.trace('flash.AssetsFileSystem.getAssetsFileSystem()');
		return new HttpFileSystem(getAssetsLocalPath());
	}
}

#end