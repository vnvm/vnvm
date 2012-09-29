package engines.ethornell;
import common.AssetsFileSystem;
import common.io.FileStream;
import common.io.Stream;
import common.io.SubVirtualFileSystem;
import common.io.VirtualFileSystem;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

/**
 * ...
 * @author soywiz
 */

class ARCTest 
{

	@AsyncTest
	public function test1(factory:AsyncFactory) 
	{
		var testDone = factory.createHandler(this, function() { }, 1000);
		
		var fileSystem:VirtualFileSystem = SubVirtualFileSystem.fromSubPath(AssetsFileSystem.getAssetsFileSystem(), "edelweiss");
		var stream:Stream;
		var arc:ARC;
		
		fileSystem.openAsync("data01000.arc", function(stream:Stream):Void {
			ARC.openAsync(stream, function(arc:ARC):Void {
				Assert.areEqual("00106", arc.table[0].name);
				Assert.areEqual("zmain", arc.table[arc.table.length - 1].name);
				testDone();
			});
		});
		
	}
	
}