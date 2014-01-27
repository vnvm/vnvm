package engines.will.utils;

import flash.display.PNGEncoderOptions;
import engines.will.formats.wip.WIP;
import lang.promise.Promise;
import lang.promise.IPromise;
import vfs.LocalFileSystem;
import common.ByteArrayUtils;
import engines.brave.formats.BraveImage;
import sys.io.File;
import haxe.io.Path;
import haxe.Log;
import vfs.SubVirtualFileSystem;
import common.assets.AssetsFileSystem;
import sys.FileSystem;

class WillCommandLineMain
{
	public function new()
	{

	}

	public function extractAllImages()
	{
		var path = AssetsFileSystem.getAssetsLocalPath() + '/pw';
		var fs = new LocalFileSystem(path);
		try { FileSystem.createDirectory('$path/images'); } catch (e:Dynamic) { }
		WillResourceManager.createFromFileSystemAsync(fs).then(function(willResourceManager:WillResourceManager) {
			var promises:Array<Void -> IPromise<Dynamic>> = [];
			Lambda.foreach(willResourceManager.getFileNames(), function(name) {
				switch (Path.extension(name))
				{
					case 'WIP':
						var imageName = '$path/images/$name.png';
						if (!FileSystem.exists(imageName))
						{
							promises.push(function() {
								return willResourceManager.getWipWithMaskAsync(Path.withoutExtension(name)).then(function(wip:WIP) {
									Log.trace(name);
									var encodedPng = wip.get(0).bitmapData.encode("png");
									File.saveBytes(imageName, encodedPng);
								});
							});
						}
				}
				return true;
			});
			Promise.sequence(promises);
		});
	}
}
