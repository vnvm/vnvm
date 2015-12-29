package engines.brave;

import lang.promise.Deferred;
import lang.promise.Promise;
import lang.promise.IPromise;
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

	static public function getCgDbEntryAsync(name:String):IPromise<CgDbEntry>
	{
		if (cgDb != null) return Promise.createResolved(cgDb.get(name));

		return BraveAssets.getBytesAsync("cgdb.dat").then(function(data:ByteArray)
		{
			cgDb = new CgDb(Decrypt.decryptDataWithKey(data, Decrypt.key23));
			return cgDb.get(name);
		});
	}

	static public function getBitmapAsync(name:String):IPromise<Bitmap>
	{
		return BraveAssets.getBitmapDataAsync(name).then(function(bitmapData:BitmapData)
		{
			return new Bitmap(bitmapData, PixelSnapping.AUTO, true);
		});
	}

	@:noStack static public function getBitmapDataWithAlphaCombinedAsync(name:String):IPromise<BitmapData>
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

	static public function getBitmapDataAsync(name:String):IPromise<BitmapData>
	{
		name = name.toUpperCase();

		return BraveAssets.getBytesAsync('parts/${name}.CRP').then(function(bytes:ByteArray)
		{
			var braveImage:BraveImage = new BraveImage();
			braveImage.load(bytes);
			return braveImage.bitmapData;
		});
	}

	static public function getSoundAsync(name:String):IPromise<Sound>
	{
		if (soundPack != null) return soundPack.getSoundAsync(name);

		return getStreamAsync("sound.pck").pipe(function(stream:Stream)
		{
			return SoundPack.newAsync(1, stream).pipe(function(_soundPack:SoundPack)
			{
				BraveAssets.soundPack = _soundPack;
				return BraveAssets.soundPack.getSoundAsync(name);
			});
		});
	}

	static public function getVoiceAsync(name:String):IPromise<Sound>
	{
		if (voicePack != null) return voicePack.getSoundAsync(name);

		return getStreamAsync("voice/voice.pck").pipe(function(stream:Stream)
		{
			return SoundPack.newAsync(1, stream).pipe(function(_voicePack:SoundPack)
			{
				BraveAssets.voicePack = _voicePack;
				return BraveAssets.voicePack.getSoundAsync(name);
			});
		});
	}

	static public function getMusicAsync(name:String):IPromise<Sound>
	{
		return BraveAssets.getBytesAsync("midi/" + name + ".mid").then(function(bytes:ByteArray)
		{
			var sound:Sound = new Sound();
//sound.loadPCMFromByteArray(
			try
			{
				sound.loadCompressedDataFromByteArray(bytes, bytes.length, true);
			}
			catch (e:Error)
			{
				BraveLog.trace(e);
			}
			return sound;
		});
	}

	static public function getBytesAsync(name:String):IPromise<ByteArray>
	{
		return fs.openAndReadAllAsync(name);
	}

	static private function getStreamAsync(name:String):IPromise<Stream>
	{
		return fs.openAsync(name);
	}
}
