package engines.tlove;

import common.Event2;
import common.GraphicUtils;
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
import haxe.Timer;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.PixelSnapping;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.media.SoundChannel;
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
	static inline public var fps:Int = 60;
	
	public var onMouseClick:Event2<MouseEvent>;
	public var onMouseMove:Event2<MouseEvent>;
	public var onMouseDown:Event2<MouseEvent>;
	public var onMouseUp:Event2<MouseEvent>;
	public var mousePosition:Point;
	public var blackOverlay:Sprite;
	
	public var musicChannel:SoundChannel;

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
		
		this.onMouseClick = new Event2<MouseEvent>();
		this.onMouseMove = new Event2<MouseEvent>();
		this.onMouseDown = new Event2<MouseEvent>();
		this.onMouseUp = new Event2<MouseEvent>();
		this.mousePosition = new Point( -1, -1);
		
		this.blackOverlay = new Sprite();
		//this.blackOverlay.graphics
		GraphicUtils.drawSolidFilledRectWithBounds(this.blackOverlay.graphics, 0, 0, 640, 400, 0x000000, 1.0);
		this.blackOverlay.alpha = 0;
		
		this.sprite.addChild(new Bitmap(updatedBitmap, PixelSnapping.AUTO, true));
		this.sprite.addChild(this.blackOverlay);
		
		
		var e:MouseEvent;
		
		function updateMousePos(e:MouseEvent) {
			mousePosition = new Point(Math.round(e.localX), Math.round(e.localY));
		}
		
		this.sprite.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
			updateMousePos(e);
			this.onMouseClick.trigger(e);
		});
		this.sprite.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent) {
			updateMousePos(e);
			this.onMouseMove.trigger(e);
		});
		this.sprite.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
			updateMousePos(e);
			this.onMouseDown.trigger(e);
		});
		this.sprite.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent) {
			updateMousePos(e);
			this.onMouseUp.trigger(e);
		});
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
	
	public function run(script:String):Void {
		if (script == null) script = "MAIN";
		Log.trace('run');
		
		dat.loadAsync(script, function() {
			Log.trace('loaded : ' + script);
			dat.execute();
		});
	}
	
	public function delay(done:Void -> Void, timeInFrames:Int):Void {
		//Timer.delay(done, Std.int(timeInFrames * 1000 / Game.fps));
		Timer.delay(done, Std.int(timeInFrames * 10));
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