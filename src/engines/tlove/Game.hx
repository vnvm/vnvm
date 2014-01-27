package engines.tlove;

import lang.signal.Signal;
import lang.promise.IPromise;
import lang.promise.Deferred;
import haxe.io.Path;
import common.imaging.GraphicUtils;
import common.imaging.BitmapData8;
import common.imaging.Palette;
import vfs.Stream;
import vfs.VirtualFileSystem;
import lang.LangUtils;
import common.script.ScriptOpcodes;
import engines.tlove.mrs.MRS;
import engines.tlove.script.DAT;
import engines.tlove.script.DAT_OP;
import haxe.Log;
import haxe.Timer;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.SoundChannel;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;

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
	private var _lastUpdatedPalette:Palette;
	public var sprite:Sprite;
	private var updatedBitmap:BitmapData;
	public var state:GameState;
	static inline public var fps:Int = 60;
	
	public var onMouseLeftClick:Signal<MouseEvent>;
	public var onMouseRightClick:Signal<MouseEvent>;
	public var onMouseMove:Signal<MouseEvent>;
	public var onMouseDown:Signal<MouseEvent>;
	public var onMouseUp:Signal<MouseEvent>;
	public var mousePosition:Point;
	public var blackOverlay:Sprite;
	public var uiSprite:Sprite;
	
	public var musicChannel:SoundChannel;
	
	public var mouseRects:Array<Dynamic>;
	public var mouseSelectedRect:Dynamic;
	public var lastMouseEvent:MouseEvent;
	
	private function new() 
	{
		this.mouseRects = [];
		this.scriptOpcodes = ScriptOpcodes.createWithClass(DAT_OP);
		this.state = new GameState();
		this.dat = new DAT(this);
		this.layers = LangUtils.createArray(function():BitmapData8 { return BitmapData8.createNewWithSize(640, 400); }, 8);
		this.currentPalette = new Palette();
		this.workPalette = new Palette();
		this.backupPalette = new Palette();
		this.lastLoadedPalette = new Palette();
		this._lastUpdatedPalette = new Palette();
		this.updatedBitmap = new BitmapData(640, 400);
		this.sprite = new Sprite();
		
		this.onMouseLeftClick = new Signal<MouseEvent>();
		this.onMouseRightClick = new Signal<MouseEvent>();
		this.onMouseMove = new Signal<MouseEvent>();
		this.onMouseDown = new Signal<MouseEvent>();
		this.onMouseUp = new Signal<MouseEvent>();
		this.mousePosition = new Point( -1, -1);
		
		this.uiSprite = new Sprite();
		this.blackOverlay = new Sprite();
		//this.blackOverlay.graphics
		GraphicUtils.drawSolidFilledRectWithBounds(this.blackOverlay.graphics, 0, 0, 640, 400, 0x000000, 1.0);
		this.blackOverlay.alpha = 0;
		
		this.sprite.addChild(new Bitmap(updatedBitmap, PixelSnapping.AUTO, true));
		this.sprite.addChild(this.blackOverlay);
		this.sprite.addChild(this.uiSprite);
		
		
		var e:MouseEvent;
		
		function updateMousePos(e:MouseEvent) {
			mousePosition = new Point(Math.round(e.localX), Math.round(e.localY));
		}
		
		this.sprite.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
			updateMousePos(e);
			this.onMouseLeftClick.dispatch(e);
		});
		this.sprite.addEventListener("rightClick", function(e:MouseEvent) {
			updateMousePos(e);
			this.onMouseRightClick.dispatch(e);
		});
		this.sprite.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent) {
			updateMousePos(e);
			this.onMouseMove.dispatch(e);
		});
		this.sprite.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
			updateMousePos(e);
			this.onMouseDown.dispatch(e);
		});
		this.sprite.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent) {
			updateMousePos(e);
			this.onMouseUp.dispatch(e);
		});
	}
	
	public function updateImage(?rect:Rectangle):Void {
		//var renderPalette = currentPalette;
		var renderPalette = workPalette;
		
		if (rect == null) rect = this.layers[0].rect;
		if (!Palette.equals(renderPalette, _lastUpdatedPalette)) {
			rect = this.layers[0].rect;
		}
		this.layers[0].drawToBitmapDataWithPalette(updatedBitmap, renderPalette, rect);
		Palette.copy(renderPalette, _lastUpdatedPalette);
	}
	
	public function getMrsAsync(name:String, done:MRS -> Void):Void {
		var ba:ByteArray;
		mrs.getBytesAsync(Path.withExtension(name, "mrs").toUpperCase()).then(function(ba:ByteArray):Void {
			done(new MRS(ba));
		});
	}
	
	public function run(script:String, scriptPos:Int = 0):Void {
		if (script == null) script = "MAIN";
		Log.trace('run');
		
		dat.loadAsync(script).then(function(?e) {
			Log.trace('loaded : ' + script);
			dat.jumpRawAddress(scriptPos);
			dat.executeAsync();
		});
	}
	
	public function delay(done:Void -> Void, timeInFrames:Int):Void {
		//Timer.delay(done, Std.int(timeInFrames * 1000 / Game.fps));
		Timer.delay(done, Std.int(timeInFrames * 10));
	}

	public function putTextRectangle(rect:Rectangle, text: String) {
		//Log.trace("printText: '" + text + "'");
		var tf:TextField = new TextField();
		tf.autoSize = ((rect.width == 0) || (rect.height == 0)) ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
		tf.antiAliasType = AntiAliasType.NORMAL;
		//tf.sharpness = 0;
		tf.wordWrap = ((rect.width != 0) && (rect.height != 0));
		tf.width = rect.width;
		tf.height = rect.height;
		//tf.textColor = 0xFFFFFFFF;
		tf.border = false;
		//tf.condenseWhite = false;
		tf.defaultTextFormat = new TextFormat("Lucida Console", 12, 0xFFFFFFFF, false, false, false);
		tf.text = text;
		
		Log.trace("putTextRectangle(" + rect.x + "," + rect.y + "," + rect.width + "," + rect.height + ")-(" + tf.width + "," + tf.height + ")");
		var testBitmap:BitmapData = new BitmapData(Std.int(tf.width), Std.int(tf.height), true, 0x00000000);
		//uiSprite.addChild(new Bitmap(testBitmap));
		testBitmap.draw(tf);
		var bmp:BitmapData8 = BitmapData8.createWithBitmapData(testBitmap);
		bmp.drawToBitmapData8(this.layers[0], cast rect.x, cast rect.y);
		updateImage(new Rectangle(rect.x, rect.y, testBitmap.width, testBitmap.height));
	}

	public function putText(x:Int, y:Int, text: String) {
		putTextRectangle(new Rectangle(x, y, 0, 0), text);
	}

	public function printText(text: String) {
		Log.trace("printText: '" + text + "'");
	}
	
	public function clearText() {
		Log.trace("clearText");
	}

	public function breakText() {
		Log.trace("breakText");
	}

	public function pushButton() {
		Log.trace("pushButton");
	}
	
	public function outputName(nameIndex:Int) {
		Log.trace("outputName:" + nameIndex);
	}

	static public function initFromFileSystemAsync(fs:VirtualFileSystem, done:Game -> Void):Void {
		var game:Game = new Game();
		
		openAndCreatePakAsync(fs, "MIDI").then(function(midi:PAK):Void {
		openAndCreatePakAsync(fs, "MRS").then(function(mrs:PAK):Void {
		openAndCreatePakAsync(fs, "DATE").then(function(date:PAK):Void {
		openAndCreatePakAsync(fs, "EFF").then(function(eff:PAK):Void {
			game.midi = midi;
			game.mrs = mrs;
			game.date = date;
			game.eff = eff;
			
			done(game);
		});
		});
		});
		});
	}
	
	static private function openAndCreatePakAsync(fs:VirtualFileSystem, name:String):IPromise<PAK>
	{
		var stream:Stream;
		return fs.openAsync(name).pipe(function(stream:Stream) {
			return PAK.newPakAsync(stream);
		});
	}
}