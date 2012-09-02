package engines.dividead;
import common.GraphicUtils;
import common.io.Stream;
import common.io.VirtualFileSystem;
import common.script.ScriptOpcodes;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.PixelSnapping;
import nme.display.Sprite;
import nme.media.Sound;
import nme.media.SoundChannel;
import nme.text.TextField;
import nme.text.TextFormat;
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
	public var fileSystem:VirtualFileSystem;

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
	//public var blackSprite:Sprite;

	/**
	 * 
	 * @param	sg
	 * @param	wv
	 */
	private function new(fileSystem:VirtualFileSystem, sg:DL1, wv:DL1) 
	{
		this.fileSystem = fileSystem;
		this.sg = sg;
		this.wv = wv;
		this.imageCache = new Hash<BitmapData>();
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
		
		gameSprite = new Sprite();
		gameSprite.addChild(new Bitmap(front, PixelSnapping.AUTO, true));
		gameSprite.addChild(textField);
		//gameSprite.addChild(blackSprite);
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
	public function getImageCachedAsync(imageName:String, done:BitmapData -> Void):Void {
		imageName = addExtensionsWhenRequired(imageName, "bmp").toUpperCase();
		
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
	 * @param	soundName
	 * @param	done
	 */
	public function getSoundAsync(soundName:String, done:Sound -> Void):Void {
		soundName = addExtensionsWhenRequired(soundName, "wav").toUpperCase();

		var byteArray:ByteArray;
		wv.openAndReadAllAsync(soundName, function(byteArray:ByteArray) {
			var sound:Sound = new Sound();
			sound.loadCompressedDataFromByteArray(byteArray, byteArray.length);
			done(sound);
		});
	}
	
	public function getMusicAsync(musicName:String, done:Sound -> Void):Void {
		musicName = addExtensionsWhenRequired(musicName, "mid").toUpperCase();
		
		var byteArray:ByteArray;
		fileSystem.openAndReadAllAsync(Std.format("MID/$musicName"), function(byteArray:ByteArray):Void {
			var sound:Sound = new Sound();
			sound.loadCompressedDataFromByteArray(byteArray, byteArray.length);
			done(sound);
		});
	}
	
	/**
	 * 
	 * @param	fileSystem
	 * @param	done
	 */
	static public function newAsync(fileSystem:VirtualFileSystem, done:Game -> Void):Void {
		fileSystem.openAsync("SG.DL1", function(sgStream:Stream) {
		fileSystem.openAsync("WV.DL1", function(wvStream:Stream) {
			DL1.loadAsync(sgStream, function(sg:DL1) {
			DL1.loadAsync(wvStream, function(wv:DL1) {
				done(new Game(fileSystem, sg, wv));
			});
			});
		});
		});
	}
}