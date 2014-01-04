package engines.brave.utils;

import common.ByteArrayUtils;
import engines.brave.formats.BraveImage;
import sys.io.File;
import haxe.io.Path;
import haxe.Log;
import vfs.SubVirtualFileSystem;
import common.assets.AssetsFileSystem;
import sys.FileSystem;
class CommandLineMain
{
	public function new()
	{

	}

	public function extractAllImages()
	{
		var path = AssetsFileSystem.getAssetsLocalPath() + '/brave';
		var partsPath = '$path/parts';
		for (file in FileSystem.readDirectory(partsPath))
		{
			var ext:String = Path.extension(file);
			switch (ext.toLowerCase())
			{
				case 'crp':
					var fileCrp = file;
					var filePng = Path.withExtension(fileCrp, 'png');
					try {
						var braveImage = BraveImage.decode(ByteArrayUtils.BytesToByteArray(File.getBytes('$partsPath/$fileCrp')));
						File.saveBytes('$partsPath/$filePng', braveImage.encode('png'));
					} catch (e:Dynamic) {
						Log.trace(e);
					}

					//File.
					//Log.trace(filePng);
			}
		}
	}
}
