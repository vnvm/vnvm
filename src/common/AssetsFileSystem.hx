package common;
import common.io.LocalFileSystem;
import common.io.VirtualFileSystem;
import haxe.Log;
import nme.errors.Error;
import sys.FileSystem;

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
			Log.trace(Std.format("Try path '$tryPath'"));
			if (FileSystem.exists(tryPath) && FileSystem.isDirectory(tryPath)) {
				Log.trace(Std.format("Found assets at '$tryPath'"));
				return tryPath;
			}
		}
		throw(new Error("Can't locate assets folder"));
	}

	static public function getAssetsFileSystem():VirtualFileSystem {
		return new LocalFileSystem(getAssetsLocalPath());
	}
}