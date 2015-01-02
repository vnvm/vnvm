package common.assets;

import flash.filesystem.File;
import flash.errors.Error;
import vfs.VirtualFileSystem;
import vfs.LocalFileSystem;
import sys.FileSystem;
import haxe.Log;

class AssetsFileSystemCpp implements IAssetsFileSystem
{
	public function new() {}

	private function getPossiblePaths():Array<String>
	{
		return [
			"/mnt/sdcard/vnvm",
			"/private/var/mobile/vnvm",
			File.applicationDirectory.nativePath + "/assets",
			"assets",
			"../assets",
			"../../assets",
			"../../../assets",
			"../../../../assets",
			"../../../../../assets",
			"../../../../../../assets",
			"../../../../../../../assets",
			"../../../../../../../../assets"
		];
	}

	public function getAssetsLocalPath():String
	{
		for (tryPath in this.getPossiblePaths())
		{
			Log.trace('Try path \'$tryPath\'');
			if (FileSystem.exists(tryPath) && FileSystem.isDirectory(tryPath)) {
				Log.trace('Found assets at \'$tryPath\'');
				return tryPath;
			}
		}
		throw(new Error("Can't locate assets folder"));
	}

	public function getAssetsFileSystem():VirtualFileSystem
	{
		return new LocalFileSystem(getAssetsLocalPath());
	}
}