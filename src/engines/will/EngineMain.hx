package engines.will;

import flash.display.PixelSnapping;
import engines.will.formats.wip.WIP;
import promhx.Promise;
import haxe.Log;
import common.GameScalerSprite;
import common.BitmapDataUtils;
import vfs.SubVirtualFileSystem;
import vfs.VirtualFileSystem;
import vfs.VirtualFileSystemBase;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.utils.ByteArray;
//import sys.io.File;

/**
 * ...
 * @author soywiz
 */

class EngineMain extends Sprite implements IScene
{
	private var gameSprite:Sprite;
	private var fs:VirtualFileSystem;
	private var initScript:String;
	private var willResourceManager:WillResourceManager;
	private var backgroundLayer:Sprite;

	public function new(fs:VirtualFileSystem, subpath:String, script:String) 
	{
		super();

		if (script == null) script = 'PW0001';

		this.initScript = script;
		this.fs = SubVirtualFileSystem.fromSubPath(fs, subpath);
		//this.fs = fs;
		this.gameSprite = new Sprite();

		this.backgroundLayer = new Sprite();

		this.gameSprite.addChild(this.backgroundLayer);

		addChild(new GameScalerSprite(800, 600, this.gameSprite));
		init();
	}

	private function init()
	{
		var _this = this;
		WillResourceManager.createFromFileSystemAsync(fs).then(function(willResourceManager:WillResourceManager) {
			_this.willResourceManager = willResourceManager;
			var rio = new RIO2(_this, willResourceManager);

			rio.loadAsync(initScript).then(function(e) {
				rio.executeAsync().then(function(e) {
					Log.trace('END!');
				});
			});
		});
	}

	public function setTransitionMaskAsync(name:String):Promise<Dynamic>
	{
		return willResourceManager.readAllBytesAsync('$name.MSK').then(function(data:ByteArray) {
			var wip = WIP.fromByteArray(data);
			//gameSprite.addChild(new Bitmap(wip.get(0).bitmapData));
		});
	}

	public function setBackgroundAsync(x:Int, y:Int, index:Int, name:String):Promise<Dynamic>
	{
		return willResourceManager.readAllBytesAsync('$name.WIP').then(function(data:ByteArray) {
			var wip = WIP.fromByteArray(data);
			//backgroundLayer.removeChildren();
			while (backgroundLayer.numChildren > 0) backgroundLayer.removeChildAt(0);
			backgroundLayer.addChild(new Bitmap(wip.get(0).bitmapData, PixelSnapping.ALWAYS, true));
		});
	}
}