package engines.brave;

import common.AssetsFileSystem;
import common.ByteUtils;
import vfs.FileStream;
import vfs.HttpFileSystem;
import vfs.Stream;
import vfs.VirtualFileSystem;
import engines.brave.cgdb.CgDb;
import engines.brave.cgdb.CgDbEntry;
import engines.brave.formats.BraveImage;
import engines.brave.formats.Decrypt;
import engines.brave.sound.SoundPack;
import engines.brave.BraveLog;
import haxe.io.Bytes;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.PixelSnapping;
import nme.errors.Error;
import nme.events.Event;
import nme.geom.Rectangle;
import nme.media.Sound;
import nme.net.URLLoader;
import nme.net.URLLoaderDataFormat;
import nme.net.URLRequest;
import nme.utils.ByteArray;
import nme.utils.Endian;

#if (cpp || neko)
import nme.filesystem.File;
import sys.FileSystem;
import sys.io.FileInput;
#end

/**
 * ...
 * @author 
 */

class BraveAssets
{
	static var voicePack:SoundPack;
	static var soundPack:SoundPack;
	static var cgDb:CgDb;
	public static var fs:VirtualFileSystem;

	public function new() 
	{
		
	}
	
	static public function getCgDbEntryAsync(name:String, done:CgDbEntry -> Void):Void {
		if (cgDb == null) {
			BraveAssets.getBytesAsync("cgdb.dat", function(data:ByteArray) {
				cgDb = new CgDb(Decrypt.decryptDataWithKey(data, Decrypt.key23));
				done(cgDb.get(name));
			});
		} else {
			done(cgDb.get(name));
		}
	}
	
	static public function getBitmapAsync(name:String, done:Bitmap -> Void):Void {
		BraveAssets.getBitmapDataAsync(name, function(bitmapData:BitmapData) {
			done(new Bitmap(bitmapData, PixelSnapping.AUTO, true));
		});
	}

	@:noStack static public function getBitmapDataWithAlphaCombinedAsync(name:String, done:BitmapData -> Void):Void {
		BraveAssets.getBitmapDataAsync(name, function(mixed:BitmapData) {
			var width:Int = mixed.width;
			var hwidth:Int = Std.int(width / 2);
			var height:Int = mixed.height;
			var out:BitmapData = new BitmapData(hwidth, height, true);
			var color:ByteArray = mixed.getPixels(new Rectangle(0, 0, hwidth, height));
			var alpha:ByteArray = mixed.getPixels(new Rectangle(hwidth, 0, hwidth, height));
			
			color.position = 0;
			alpha.position = 0;
			
			for (n in 0 ... Std.int(color.length / 4)) {
				color[n * 4 + 0] = alpha[n * 4 +1];
			}
			
			out.setPixels(out.rect, color);
			
			done(out);
		});
	}

	/*
	static public function getBitmapData(name:String):BitmapData {
		var braveImage:BraveImage = new BraveImage();
		braveImage.load(BraveAssets.getBytes(Std.format("parts/${name}.CRP")));
		return braveImage.bitmapData;
	}
	*/

	static public function getBitmapDataAsync(name:String, done:BitmapData -> Void):Void {
		name = name.toUpperCase();
		
		BraveAssets.getBytesAsync('parts/${name}.CRP', function(bytes:ByteArray) {
			var braveImage:BraveImage = new BraveImage();
			braveImage.load(bytes);
			done(braveImage.bitmapData);
		});
	}
	
	static public function getSoundAsync(name:String, done:Sound -> Void):Void {
		if (soundPack == null) {
			getStreamAsync("sound.pck", function(stream:Stream):Void {
				SoundPack.newAsync(1, stream, function(_soundPack:SoundPack):Void {
					BraveAssets.soundPack = _soundPack;
					BraveAssets.soundPack.getSoundAsync(name, done);
				});
			});
		} else {
			soundPack.getSoundAsync(name, done);
		}
	}

	static public function getVoiceAsync(name:String, done:Sound -> Void):Void {
		if (voicePack == null) {
			getStreamAsync("voice/voice.pck", function(stream:Stream):Void {
				SoundPack.newAsync(1, stream, function(_voicePack:SoundPack):Void {
					BraveAssets.voicePack = _voicePack;
					BraveAssets.voicePack.getSoundAsync(name, done);
				});
			});
		} else {
			voicePack.getSoundAsync(name, done);
		}
	}
	
	static public function getMusicAsync(name:String, done:Sound -> Void):Void {
		BraveAssets.getBytesAsync("midi/" + name + ".mid", function(bytes:ByteArray) {
			var sound:Sound = new Sound();
			//sound.loadPCMFromByteArray(
			try {
				sound.loadCompressedDataFromByteArray(bytes, bytes.length);
			} catch (e:Error) {
				BraveLog.trace(e);
			}
			done(sound);
		});
	}

	static public function getBytesAsync(name:String, done:ByteArray -> Void):Void {
		fs.openAndReadAllAsync(name, done);
	}

	static private function getStreamAsync(name:String, done:Stream -> Void):Void {
		fs.openAsync(name, done);
	}
}
