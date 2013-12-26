package engines.will.formats.wip;
import flash.display.BitmapData;
import common.LangUtils;
import flash.utils.ByteArray;

class WipEntry
{
	static public inline var structSize:Int = 6 * LangUtils.IntSize;

	public var width:Int;
	public var height:Int;
	public var x:Int;
	public var y:Int;
	public var unknown:Int;
	public var compressedSize:Int;
	public var bitmapData:BitmapData;

	public function new()
	{

	}

	public function read(data:ByteArray)
	{
		width = data.readUnsignedInt();
		height = data.readUnsignedInt();
		x = data.readUnsignedInt();
		y = data.readUnsignedInt();
		unknown = data.readUnsignedInt();
		compressedSize = data.readUnsignedInt();
		return this;
	}
}