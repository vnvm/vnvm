package engines.tlove;
import common.AssetsFileSystem;
import common.ByteArrayUtils;
import common.io.Stream;
import common.io.SubVirtualFileSystem;
import common.io.VirtualFileSystem;
import haxe.Log;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class PAKTest 
{
	@AsyncTest
	public function testLoad(factory:AsyncFactory):Void {
		var testDone = factory.createHandler(this, function() { }, 1000);

		var fileSystem:VirtualFileSystem = SubVirtualFileSystem.fromSubPath(AssetsFileSystem.getAssetsFileSystem(), "tlove");
		var bytes:ByteArray;
		var m005:Stream;
		var pakStream:Stream;
		var pak:PAK;
		
		fileSystem.openAsync("MIDI", function(pakStream:Stream):Void {
			PAK.newPakAsync(pakStream, function(pak:PAK):Void {
				Assert.areEqual(
					"[M001.MID,M016B.MID,M002.MID,M003.MID,M010.MID,M004.MID,M011.MID,M005.MID,M012.MID,M006.MID,M013.MID,M014.MID,M007.MID,M008.MID,M015.MID,M009.MID]",
					Std.string(pak.getNames())
				);
				
				var m005:Stream = pak.get('M005.MID');
				m005.readAllBytesAsync(function(bytes:ByteArray):Void {
					Assert.areEqual(
						"MThd",
						ByteArrayUtils.readStringz(bytes, 4)
					);
					testDone();
				});
			});
		});
	}
	
}