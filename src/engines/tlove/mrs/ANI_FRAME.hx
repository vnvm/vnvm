package engines.tlove.mrs;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class ANI_FRAME
{
	public var x:Int = 0;
	public var y:Int = 0;
	public var t:Int = 0;

	public function new(s:ByteArray) {
		this.y = s.readUnsignedByte();
		this.x = s.readUnsignedByte() * 8;
		this.t = s.readUnsignedByte() * 16;
	}
}