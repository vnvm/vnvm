package common.imaging;

import haxe.io.Bytes;
import flash.utils.Endian;
import flash.utils.ByteArray;
import flash.display.BitmapData;

class BitmapDataSerializer
{
	static private inline var outputPixelSize = 4;

	@:noStack static public function decode(input:ByteArray, width:Int, height:Int, channels:String = "argb", interleaved:Bool = true):BitmapData
	{
		var inputStart = input.position;
		var output = ByteArrayUtils.newByteArrayWithLength(width * height * 4, Endian.LITTLE_ENDIAN);
		var totalPixels = width * height;
		var inputPixelSize = interleaved ? channels.length : 1;
		var displacementNextChannel = interleaved ? 1 : totalPixels;
		var channelStartOffset = 0;

		for (channelChar in channels.split(''))
		{
			var readOffset = inputStart + channelStartOffset;
			var writeOffset = getChannelOffset(channelChar);
			for (n in 0 ... totalPixels)
			{
				output[writeOffset] = input[readOffset];
				readOffset += inputPixelSize;
				writeOffset += outputPixelSize;
			}
			channelStartOffset += displacementNextChannel;
		}

		if (channels.indexOf('a') < 0)
		{
			var writeOffset = getChannelOffset('a');
			for (n in 0 ... totalPixels)
			{
				output[writeOffset] = 0xFF;
				writeOffset += outputPixelSize;
			}
		}

		return BitmapDataSerializer.fromByteArray(width, height, output);
	}

	static public function getChannelOffset(channelChar:String):Int
	{
		#if flash9
		return switch (channelChar) { case 'a': 3; case 'r': 2; case 'g': 1; case 'b': 0; default: throw('Invalid channel char $channelChar'); }
		#else
		return switch (channelChar) { case 'a': 0; case 'r': 1; case 'g': 2; case 'b': 3; default: throw('Invalid channel char $channelChar'); }
		#end
	}

	static public function fromByteArray(width:Int, height:Int, data:ByteArray):BitmapData
	{
		var bitmapData = new BitmapData(width, height, true, 0x00000000);

		bitmapData.setPixels(bitmapData.rect, data);

		return bitmapData;
	}
}