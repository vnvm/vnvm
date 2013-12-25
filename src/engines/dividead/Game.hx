package engines.dividead;

import vfs.SubVirtualFileSystem;
import haxe.Log;
import promhx.Promise;
import common.BitmapDataUtils;
import common.display.OptionList;
import common.GameInput;
import common.GraphicUtils;
import vfs.Stream;
import vfs.VirtualFileSystem;
import common.Keys;
import common.script.ScriptOpcodes;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.ByteArray;

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
	public var sg:VirtualFileSystem;

	/**
	 *
	 */
	public var mid:VirtualFileSystem;

	/**
	 * WaVe files
	 */
	public var wv:VirtualFileSystem;
	
	/**
	 * 
	 */
	public var fileSystem:VirtualFileSystem;

	/**
	 * 
	 */
	private var imageCache:Map<String, BitmapData>;
	
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
	 */
	public var textField:TextField;
	
	/**
	 * 
	 */
	public var gameSprite:Sprite;
	
	/**
	 * 
	 */
	public var voiceChannel:SoundChannel;

	/**
	 * 
	 */
	public var effectChannel:SoundChannel;

	/**
	 * 
	 */
	public var musicChannel:SoundChannel;
	
	/**
	 * 
	 */
	public var optionList:OptionList;

	/**
	 * 
	 */
	//public var blackSprite:Sprite;
	
	public function isSkipping():Bool {
		return GameInput.isPressing(Keys.Control);
	}

	/**
	 * 
	 * @param	sg
	 * @param	wv
	 */
	private function new(fileSystem:VirtualFileSystem, sg:DL1, wv:DL1) 
	{
		this.fileSystem = fileSystem;
		this.mid = SubVirtualFileSystem.fromSubPath(fileSystem, 'MID');
		this.sg = sg;
		this.wv = wv;
		this.imageCache = new Map<String, BitmapData>();
		this.scriptOpcodes = ScriptOpcodes.createWithClass(AB_OP);
		this.state = new GameState();
		this.back = new BitmapData(640, 480, false, 0xFF000000);
		this.front = new BitmapData(640, 480, false, 0xFF000000);
		//this.back = new BitmapData(640, 480);
		//this.front = new BitmapData(640, 480);
		#if cpp
			this.front.createHardwareSurface();
		#end
		this.textField = new TextField();
		textField.defaultTextFormat = new TextFormat("Arial", 12, 0xFFFFFF);
		textField.selectable = false;
		textField.x = 110;
		textField.y = 400;
		textField.width = 420;
		textField.height = 60;
		textField.text = "";
		textField.textColor = 0xFFFFFF;
		
		/*
		blackSprite = new Sprite();
		GraphicUtils.drawSolidFilledRectWithBounds(blackSprite.graphics, 0, 0, 640, 480, 0x000000, 1.0);
		blackSprite.alpha = 0;
		blackSprite.visible = 0;
		*/
		
		optionList = new OptionList(428, 60, 3, 2, true);
		optionList.sprite.x = 108;
		optionList.sprite.y = 402;
		gameSprite = new Sprite();
		gameSprite.addChild(new Bitmap(front, PixelSnapping.AUTO, true));
		gameSprite.addChild(textField);
		gameSprite.addChild(optionList.sprite);
		
		optionList.visible = false;
	}
	
	static private function addExtensionsWhenRequired(name:String, expectedExtension:String):String {
		if (name.indexOf(".") == -1) name += "." + expectedExtension;
		return name;
	}
	
	/**
	 * 
	 * @param	imageName
	 * @param	done
	 */
	public function getImageCachedAsync(imageName:String):Promise<BitmapData> {
		var promise = new Promise<BitmapData>();
		imageName = addExtensionsWhenRequired(imageName, "bmp").toUpperCase();
		
		if (imageCache.exists(imageName)) {
			promise.resolve(imageCache.get(imageName));
		} else {
			sg.openAndReadAllAsync(imageName).then(function(byteArray:ByteArray):Void {
				imageCache.set(imageName, SG.getImage(byteArray));
				promise.resolve(imageCache.get(imageName));
			});
		}
		return promise;
	}

	public function getImageMaskCachedAsync(imageNameColor:String, imageNameMask:String):Promise<BitmapData> {
		var imageName:String = '${imageNameColor}${imageNameMask}';
		var promise = new Promise<BitmapData>();
		
		if (imageCache.exists(imageName)) {
			promise.resolve(imageCache.get(imageName));
		} else {
			getImageCachedAsync(imageNameColor).then(function(color:BitmapData) {
			getImageCachedAsync(imageNameMask).then(function(mask:BitmapData) {
				imageCache.set(imageName, BitmapDataUtils.combineColorMask(color, mask));
				promise.resolve(imageCache.get(imageName));
			});
			});
		}
		return promise;
	}

	/**
	 * 
	 * @param	soundName
	 * @param	done
	 */
	public function getSoundAsync(soundName:String):Promise<Sound>
	{
		return getSoundMusicAsync('wav', wv, soundName);
	}
	
	public function getMusicAsync(musicName:String):Promise<Sound>
	{
		return getSoundMusicAsync('mid', mid, musicName);
	}

	private function getSoundMusicAsync(extension:String, vfs:VirtualFileSystem, name:String)
	{
		name = addExtensionsWhenRequired(name, extension).toUpperCase();

		var byteArray:ByteArray;
		var promise = new Promise<Sound>();
		vfs.openAndReadAllAsync(name).then(function(byteArray:ByteArray):Void {
			var sound:Sound = new Sound();
			try {
				sound.loadCompressedDataFromByteArray(byteArray, byteArray.length);
			} catch (e:Dynamic) {
				Log.trace('Error: ' + e);
			}
			promise.resolve(sound);
		});
		return promise;
	}
	
	/**
	 * 
	 * @param	fileSystem
	 * @param	done
	 */
	static public function newAsync(fileSystem:VirtualFileSystem):Promise<Game>
	{
		var promise = new Promise<Game>();
		getDl1Async(fileSystem, "SG.DL1").then(function(sg:DL1)
		{
			getDl1Async(fileSystem, "WV.DL1").then(function(wv:DL1)
			{
				promise.resolve(new Game(fileSystem, sg, wv));
			});
		});
		return promise;
	}

	static private function getDl1Async(fileSystem:VirtualFileSystem, name:String):Promise<DL1>
	{
		var promise = new Promise<DL1>();
		fileSystem.openAsync(name).then(function(stream:Stream):Void
		{
			DL1.loadAsync(stream).then(function(dl1:DL1)
			{
				promise.resolve(dl1);
			});
		});
		return promise;
	}
}