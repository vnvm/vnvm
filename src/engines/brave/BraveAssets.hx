package engines.brave;

import promhx.Promise;
import vfs.Stream;
import vfs.VirtualFileSystem;
import engines.brave.cgdb.CgDb;
import engines.brave.cgdb.CgDbEntry;
import engines.brave.formats.BraveImage;
import engines.brave.formats.Decrypt;
import engines.brave.sound.SoundPack;
import engines.brave.BraveLog;
import openfl.Assets;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.errors.Error;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.utils.ByteArray;

#if (cpp || neko)
import flash.filesystem.File;
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

	static public function getCgDbEntryAsync(name:String):Promise<CgDbEntry>
	{
		if (cgDb != null) return Promise.promise(cgDb.get(name));

		return BraveAssets.getBytesAsync("cgdb.dat").then(function(data:ByteArray)
		{
			cgDb = new CgDb(Decrypt.decryptDataWithKey(data, Decrypt.key23));
			return cgDb.get(name);
		});
	}

	static public function getBitmapAsync(name:String):Promise<Bitmap>
	{
		return BraveAssets.getBitmapDataAsync(name).then(function(bitmapData:BitmapData)
		{
			return new Bitmap(bitmapData, PixelSnapping.AUTO, true);
		});
	}

	@:noStack static public function getBitmapDataWithAlphaCombinedAsync(name:String):Promise<BitmapData>
	{
		return BraveAssets.getBitmapDataAsync(name).then(function(mixed:BitmapData)
		{
			var width:Int = mixed.width;
			var hwidth:Int = Std.int(width / 2);
			var height:Int = mixed.height;
			var out:BitmapData = new BitmapData(hwidth, height, true);
			var color:ByteArray = mixed.getPixels(new Rectangle(0, 0, hwidth, height));
			var alpha:ByteArray = mixed.getPixels(new Rectangle(hwidth, 0, hwidth, height));

			color.position = 0;
			alpha.position = 0;

			for (n in 0 ... Std.int(color.length / 4))
			{
				color[n * 4 + 0] = alpha[n * 4 + 1];
			}

			out.setPixels(out.rect, color);

			return out;
		});
	}

/*
	static public function getBitmapData(name:String):BitmapData {
		var braveImage:BraveImage = new BraveImage();
		braveImage.load(BraveAssets.getBytes(Std.format("parts/${name}.CRP")));
		return braveImage.bitmapData;
	}
	*/

	static public function getBitmapDataAsync(name:String):Promise<BitmapData>
	{
		name = name.toUpperCase();

		return BraveAssets.getBytesAsync('parts/${name}.CRP').then(function(bytes:ByteArray)
		{
			var braveImage:BraveImage = new BraveImage();
			braveImage.load(bytes);
			return braveImage.bitmapData;
		});
	}

	static public function getSoundAsync(name:String):Promise<Sound>
	{
		if (soundPack != null) return soundPack.getSoundAsync(name);

		var promise = new Promise<Sound>();
		getStreamAsync("sound.pck").then(function(stream:Stream):Void
		{
			SoundPack.newAsync(1, stream).then(function(_soundPack:SoundPack)
			{
				BraveAssets.soundPack = _soundPack;
				BraveAssets.soundPack.getSoundAsync(name).then(function(sound:Sound)
				{
					promise.resolve(sound);
				});
			});
		});
		return promise;
	}

	static public function getVoiceAsync(name:String):Promise<Sound>
	{
		if (voicePack != null) return voicePack.getSoundAsync(name);

		var promise = new Promise<Sound>();

		getStreamAsync("voice/voice.pck").then(function(stream:Stream):Void
		{
			SoundPack.newAsync(1, stream).then(function(_voicePack:SoundPack):Void
			{
				BraveAssets.voicePack = _voicePack;
				BraveAssets.voicePack.getSoundAsync(name).then(function(sound:Sound):Void
				{
					promise.resolve(sound);
				});
			});
		});

		return promise;
	}

	static public function getMusicAsync(name:String):Promise<Sound>
	{
		return BraveAssets.getBytesAsync("midi/" + name + ".mid").then(function(bytes:ByteArray)
		{
			var sound:Sound = new Sound();
//sound.loadPCMFromByteArray(
			try
			{
				sound.loadCompressedDataFromByteArray(bytes, bytes.length);
			}
			catch (e:Error)
			{
				BraveLog.trace(e);
			}
			return sound;
		});
	}

	static public function getBytesAsync(name:String):Promise<ByteArray>
	{
		return fs.openAndReadAllAsync(name);
	}

	static private function getStreamAsync(name:String):Promise<Stream>
	{
		return fs.openAsync(name);
	}
}
