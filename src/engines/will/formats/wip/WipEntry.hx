package engines.will.formats.wip;
import flash.display.BitmapData;
import lang.LangUtils;
import flash.utils.ByteArray;

class WipEntry
{
	static public inline var structSize:Int = 6 * LangUtils.IntSize;

	public var index:Int;
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

	public function read(index:Int, data:ByteArray):WipEntry
	{
		this.index = index;
		this.width = data.readUnsignedInt();
		this.height = data.readUnsignedInt();
		this.x = data.readUnsignedInt();
		this.y = data.readUnsignedInt();
		this.unknown = data.readUnsignedInt();
		this.compressedSize = data.readUnsignedInt();
		return this;
	}
}