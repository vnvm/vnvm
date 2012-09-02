package engines.tlove.mrs;
import common.AssetsFileSystem;
import common.io.Stream;
import common.io.SubVirtualFileSystem;
import common.io.VirtualFileSystem;
import haxe.Log;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import nme.utils.ByteArray;
import sys.io.File;

/**
 * ...
 * @author soywiz
 */

class LZTest 
{
	@AsyncTest
	public function testDecompress(factory:AsyncFactory):Void {
		var testDone = factory.createHandler(this, function() { }, 1000);

		var fileSystem:VirtualFileSystem = SubVirtualFileSystem.fromSubPath(AssetsFileSystem.getAssetsFileSystem(), "tlove");
		var pak:PAK;
		var compressed:ByteArray;
		
		fileSystem.openAsync("MRS", function(pakStream:Stream):Void {
			PAK.newPakAsync(pakStream, function(pak:PAK):Void {
				var mrsStream:Stream = pak.get('SLIDE_2.MRS');
				mrsStream.readAllBytesAsync(function(compressed:ByteArray):Void {
					compressed.position = 12 + 0x300;
					var uncompressed:ByteArray = LZ.decode(compressed);
					File.saveBytes("c:/temp/temp.bin", uncompressed);
					testDone();
				});
			});
		});
	}
}