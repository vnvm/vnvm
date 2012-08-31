package engines.dividead;
import common.io.Stream;
import common.io.VirtualFileSystem;
import common.script.ScriptOpcodes;
import nme.display.BitmapData;
import nme.utils.ByteArray;

/**
 * Dividead's Game class
 * 
 * @author soywiz
 */
class Game
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
	 */
	public var scriptOpcodes:ScriptOpcodes;
	
	/**
	 * 
	 */
	public var state:GameState;
	
	/**
	 * 
	 */
	public var back:BitmapData;
	
	/**
	 * 
	 */
	public var front:BitmapData;
	
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
		this.scriptOpcodes = ScriptOpcodes.createWithClass(AB_OP);
		this.state = new GameState();
		this.back = new BitmapData(640, 480);
		this.front = new BitmapData(640, 480);
	}
	
	/**
	 * 
	 * @param	imageName
	 * @param	done
	 */
	public function getImageCachedAsync(imageName:String, done:BitmapData -> Void):Void {
		if (imageName.indexOf(".") == -1) imageName += ".bmp";
		imageName = imageName.toUpperCase();
		
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
	static public function newAsync(fileSystem:VirtualFileSystem, done:Game -> Void):Void {
		fileSystem.openAsync("sg.dl1", function(sgStream:Stream) {
		fileSystem.openAsync("wv.dl1", function(wvStream:Stream) {
			DL1.loadAsync(sgStream, function(sg:DL1) {
			DL1.loadAsync(wvStream, function(wv:DL1) {
				done(new Game(sg, wv));
			});
			});
		});
		});
	}
}