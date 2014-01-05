package common.media.audio;

import haxe.io.BytesData;

interface IAudioStream
{
	//function writeBytes(data:BytesData):Void;
	//function getBytesAvailable():Int;
	function decodeFrame():BytesData;
}
