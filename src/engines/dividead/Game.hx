package engines.dividead;

import lang.promise.Promise;
import lang.promise.IPromise;
import engines.dividead.formats.SG;
import engines.dividead.formats.DL1;
import engines.dividead.script.AB_OP;
import vfs.SubVirtualFileSystem;
import haxe.Log;
import common.imaging.BitmapDataUtils;
import common.display.OptionList;
import common.input.GameInput;
import vfs.Stream;
import vfs.VirtualFileSystem;
import common.input.Keys;
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
class Game {
    public var sg:VirtualFileSystem; // Sprite and Graphics
    public var mid:VirtualFileSystem; // MIDi files
    public var wv:VirtualFileSystem; // WaVe files
    public var fileSystem:VirtualFileSystem;
    private var imageCache:Map<String, BitmapData>;
    public var scriptOpcodes:ScriptOpcodes;
    public var state:GameState;
    public var back:BitmapData;
    public var front:BitmapData;
    public var textField:TextField;
    public var gameSprite:Sprite;
    public var overlaySprite:Sprite;
    public var voiceChannel:SoundChannel;
    public var effectChannel:SoundChannel;
    public var musicChannel:SoundChannel;
    public var optionList:OptionList;

    public function isSkipping():Bool return GameInput.isPressing(Keys.Control);

    private function new(fileSystem:VirtualFileSystem, sg:DL1, wv:DL1) {
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
        gameSprite.addChild(overlaySprite = new Sprite());

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

    public function getImageCachedAsync(imageName:String):IPromise<BitmapData> {
        imageName = addExtensionsWhenRequired(imageName, "bmp").toUpperCase();

        if (imageCache.exists(imageName)) {
            return Promise.createResolved(imageCache.get(imageName));
        } else {
            return sg.openAndReadAllAsync(imageName).then(function(byteArray:ByteArray) {
                imageCache.set(imageName, SG.getImage(byteArray));
                return imageCache.get(imageName);
            });
        }
    }

    public function getImageMaskCachedAsync(imageNameColor:String, imageNameMask:String):IPromise<BitmapData> {
        var imageName:String = '${imageNameColor}${imageNameMask}';

        if (imageCache.exists(imageName)) {
            return Promise.createResolved(imageCache.get(imageName));
        } else {
            return getImageCachedAsync(imageNameColor).pipe(function(color:BitmapData) {
                return getImageCachedAsync(imageNameMask).then(function(mask:BitmapData) {
                    imageCache.set(imageName, BitmapDataUtils.combineColorMask(color, mask));
                    return imageCache.get(imageName);
                });
            });
        }
    }

    public function getSoundAsync(soundName:String):IPromise<Sound> return getSoundMusicAsync('wav', wv, soundName);
    public function getMusicAsync(musicName:String):IPromise<Sound> return getSoundMusicAsync('mid', mid, musicName);

    private function getSoundMusicAsync(extension:String, vfs:VirtualFileSystem, name:String) {
        name = addExtensionsWhenRequired(name, extension).toUpperCase();

        var byteArray:ByteArray;
        return vfs.openAndReadAllAsync(name).then(function(byteArray:ByteArray) {
            var sound:Sound = new Sound();
            try {
                sound.loadCompressedDataFromByteArray(byteArray, byteArray.length);
            } catch (e:Dynamic) {
                Log.trace('Error: ' + e);
            }
            return sound;
        });
    }

/**
	 * 
	 * @param	fileSystem
	 * @param	done
	 */

    static public function newAsync(fileSystem:VirtualFileSystem):IPromise<Game> {
        return getDl1Async(fileSystem, "SG.DL1").pipe(function(sg:DL1) {
            return getDl1Async(fileSystem, "WV.DL1").then(function(wv:DL1) {
                return new Game(fileSystem, sg, wv);
            });
        });
    }

    static private function getDl1Async(fileSystem:VirtualFileSystem, name:String):IPromise<DL1> {
        return fileSystem.openAsync(name).pipe(function(stream:Stream) {
            return DL1.loadAsync(stream);
        });
    }
}