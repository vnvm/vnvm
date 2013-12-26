package engines.will.formats.anm;

import haxe.Log;
import common.GenericMatrix2D;
import common.ByteArrayUtils;
import flash.utils.ByteArray;
class ANM
{
	public var wipName:String;
	private var entries:GenericMatrix2D<Int>;

	private function new()
	{
		entries = new GenericMatrix2D<Int>(402, 100);
	}

	private function load(input:ByteArray)
	{
		this.wipName = ByteArrayUtils.readStringz(input, 9);
		Log.trace(wipName);

		for (y in 0 ... this.entries.height)
		{
			for (x in 0 ... this.entries.width)
			{
				var value = input.readUnsignedShort();
				this.entries.set(x, y, value);
				//Log.trace('$x, $y: $value');
			}
		}
	}

	static public function fromByteArray(input:ByteArray):ANM
	{
		var anm = new ANM();
		anm.load(input);
		return anm;
	}
}
