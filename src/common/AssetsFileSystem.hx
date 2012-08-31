package common;
import common.io.LocalFileSystem;
import common.io.VirtualFileSystem;
import nme.errors.Error;
import sys.FileSystem;

/**
 * ...
 * @author soywiz
 */

class AssetsFileSystem 
{
	static public function getAssetsLocalPath():String {
		for (tryPath in ["/private/var/mobile/vnvm", nme.filesystem.File.applicationDirectory.nativePath + "/assets", "assets", "../assets", "../../assets", "../../../assets", "../../../../assets"]) {
			if (FileSystem.isDirectory(tryPath)) {
				return tryPath;
			}
		}
		throw(new Error("Can't locate assets folder"));
	}

	static public function getAssetsFileSystem():VirtualFileSystem {
		return new LocalFileSystem(getAssetsLocalPath());
	}
}