package engines.will.formats.anm;

import common.GenericMatrix2D;
import common.ByteArrayUtils;
import flash.utils.ByteArray;

class TBL
{
	public var count:Int;
	public var mskName:String;
	public var enable_flags:Array<Int>;
	private var keymap:GenericMatrix2D<Int>;

	public function new()
	{
		enable_flags = [for (n in 0 ... 0x100) 0];
		keymap = new GenericMatrix2D<Int>(0x10, 0x12);
	}

	function load(stream:ByteArray)
	{
		this.count    = stream.readUnsignedInt();
		this.mskName = ByteArrayUtils.readStringz(stream, 9);

		for (n in 0 ... 0x100)
		{
			this.enable_flags[n] = stream.readUnsignedInt();
		}

		/*
		for (y in 0 ... 0x12)
		{
			for (x in 0 ... 0x10)
			{
				var value = stream.readUnsignedByte();
				this.keymap.set(x, y, value);
			}
		}
		*/

		// Local
		//this.mask = ::resman.get_mask(this.msk_name);
		//this.resetPosition();
		return this;
	}

	static public function fromByteArray(data:ByteArray):TBL
	{
		return new TBL().load(data);
	}
}