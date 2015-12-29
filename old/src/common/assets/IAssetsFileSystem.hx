package common.assets;

import vfs.VirtualFileSystem;

interface IAssetsFileSystem
{
	function getAssetsLocalPath():String;
	function getAssetsFileSystem():VirtualFileSystem;
}