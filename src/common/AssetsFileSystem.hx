package common;
import common.io.HttpFileSystem;
import common.io.VirtualFileSystem;
import haxe.Log;
import nme.errors.Error;

#if (cpp || neko)
import sys.FileSystem;
import common.io.LocalFileSystem;

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
			nme.filesystem.File.applicationDirectory.nativePath + "/assets",
			"assets", "../assets", "../../assets", "../../../assets", "../../../../assets"
		]) {
			#if !neko
			Log.trace(Std.format("Try path '$tryPath'"));
			#end
			if (FileSystem.exists(tryPath) && FileSystem.isDirectory(tryPath)) {
				#if !neko
				Log.trace(Std.format("Found assets at '$tryPath'"));
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
		return "assets";
	}

	static public function getAssetsFileSystem():VirtualFileSystem {
		return new HttpFileSystem(getAssetsLocalPath());
	}
}

#end