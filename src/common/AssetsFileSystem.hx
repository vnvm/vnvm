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
	static public function getAssetsFileSystem():VirtualFileSystem {
		for (tryPath in [nme.filesystem.File.applicationDirectory.nativePath + "/assets", "assets", "../assets", "../../assets", "../../../assets", "../../../../assets"]) {
			if (FileSystem.isDirectory(tryPath)) {
				return new LocalFileSystem(tryPath);
			}
		}
		throw(new Error("Can't locate assets folder"));
	}
}