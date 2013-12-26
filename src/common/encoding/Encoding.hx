package common.encoding;

import flash.utils.ByteArray;
class Encoding
{
	static public var UTF8:Encoding;

	private var charsetName:String;

	static public function __init__()
	{
		UTF8 = new Encoding('UTF-8');
	}

	private function new(name:String)
	{
		this.charsetName = name;
	}

	public function getString(byteArray:ByteArray):String
	{
		var backPosition = byteArray.position;
		byteArray.position = 0;
		var output = byteArray.readMultiByte(byteArray.length, charsetName);
		byteArray.position = backPosition;
		return output;
	}
}