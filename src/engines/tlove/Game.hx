package engines.tlove;

import common.imaging.BitmapData8;
import common.imaging.Palette;
import common.io.Stream;
import common.io.VirtualFileSystem;
import common.LangUtils;
import common.PathUtils;
import common.script.ScriptOpcodes;
import engines.tlove.mrs.MRS;
import engines.tlove.script.DAT;
import engines.tlove.script.DAT_OP;
import haxe.Log;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.PixelSnapping;
import nme.display.Sprite;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class Game 
{
	public var midi:PAK;
	public var mrs:PAK;
	public var date:PAK;
	public var eff:PAK;
	public var scriptOpcodes:ScriptOpcodes;
	public var dat:DAT;
	public var layers:Array<BitmapData8>;
	public var currentPalette:Palette;
	public var workPalette:Palette;
	public var backupPalette:Palette;
	public var lastLoadedPalette:Palette;
	public var sprite:Sprite;
	private var updatedBitmap:BitmapData;
	public var state:GameState;

	private function new() 
	{
		this.scriptOpcodes = ScriptOpcodes.createWithClass(DAT_OP);
		this.state = new GameState();
		this.dat = new DAT(this);
		this.layers = LangUtils.createArray(function():BitmapData8 { return BitmapData8.createNewWithSize(640, 400); }, 8);
		this.currentPalette = new Palette();
		this.workPalette = new Palette();
		this.backupPalette = new Palette();
		this.lastLoadedPalette = new Palette();
		this.updatedBitmap = new BitmapData(640, 400);
		this.sprite = new Sprite();
		this.sprite.addChild(new Bitmap(updatedBitmap, PixelSnapping.AUTO, true));
	}
	
	public function updateImage():Void {
		this.layers[0].drawToBitmapData(updatedBitmap);
	}
	
	public function getMrsAsync(name:String, done:MRS -> Void):Void {
		var ba:ByteArray;
		mrs.getBytesAsync(PathUtils.addExtensionIfMissing(name, "mrs").toUpperCase(), function(ba:ByteArray):Void {
			done(new MRS(ba));
		});
	}
	
	public function run():Void {
		Log.trace('run');
		dat.loadAsync("MAIN", function() {
			Log.trace('loaded');
			dat.execute();
		});
	}
	
	static public function initFromFileSystemAsync(fs:VirtualFileSystem, done:Game -> Void):Void {
		var game:Game = new Game();
		
		fs.openBatchAsync(["MIDI", "MRS", "DATE", "EFF"], function(midiStream:Stream, mrsStream:Stream, dateStream:Stream, effStream:Stream):Void {
			PAK.newPakAsync(midiStream, function(midi:PAK) {
			PAK.newPakAsync(mrsStream, function(mrs:PAK) {
			PAK.newPakAsync(dateStream, function(date:PAK) {
			PAK.newPakAsync(effStream, function(eff:PAK) {
				game.midi = midi;
				game.mrs = mrs;
				game.date = date;
				game.eff = eff;
				
				done(game);
			});
			});
			});
			});
		});
	}
}