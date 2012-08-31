package engines.dividead;
import common.io.Stream;
import common.io.VirtualFileSystem;
import engines.brave.ByteArrayUtils;
import nme.display.BitmapData;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class GameState 
{
	/**
	 * Script & Graphics
	 */
	public var sg:DL1;
	
	/**
	 * WaVe files
	 */
	public var wv:DL1;

	/**
	 * 
	 */
	private var imageCache:Hash<BitmapData>;
	
	/**
	 * 
	 * @param	sg
	 * @param	wv
	 */
	private function new(sg:DL1, wv:DL1) 
	{
		this.sg = sg;
		this.wv = wv;
		this.imageCache = new Hash<BitmapData>();
	}
	
	/**
	 * 
	 * @param	imageName
	 * @param	done
	 */
	public function getImageCachedAsync(imageName:String, done:BitmapData -> Void):Void {
		if (imageCache.exists(imageName)) {
			done(imageCache.get(imageName));
		} else {
			sg.openAndReadAllAsync(imageName, function(byteArray:ByteArray):Void {
				imageCache.set(imageName, SG.getImage(byteArray));
				done(imageCache.get(imageName));
			});
		}
	}
	
	/**
	 * 
	 * @param	fileSystem
	 * @param	done
	 */
	static public function newAsync(fileSystem:VirtualFileSystem, done:GameState -> Void):Void {
		fileSystem.openAsync("sg.dl1", function(sgStream:Stream) {
		fileSystem.openAsync("wv.dl1", function(wvStream:Stream) {
			DL1.loadAsync(sgStream, function(sg:DL1) {
			DL1.loadAsync(wvStream, function(wv:DL1) {
				done(new GameState(sg, wv));
			});
			});
		});
		});
	}
}