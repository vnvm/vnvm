package common;

import vfs.VirtualFileSystem;

interface IAssetsFileSystem
{
	function getAssetsLocalPath():String;
	function getAssetsFileSystem():VirtualFileSystem;
}