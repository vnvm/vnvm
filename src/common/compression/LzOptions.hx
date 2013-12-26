package common.compression;

import common.BitUtils;

class LzOptions
{
	public var ringBufferSize:Int = 0x1000;
	//public var opsize:Int = 1;
	public var startRingBufferPos:Int = 1;
	//public var init:Int = 0;
	public var compressedBit:Int = 0;

	public var countPositionBytesHighFirst:Bool = true;

	public var positionCountExtractor:IPositionCountExtractor;

	public function setCountPositionBits(countBits:Int, positionBits:Int, countAdd:Int):Void
	{
		this.positionCountExtractor = new LzGenericPositionCountExtractor().setCountPositionBits(countBits, positionBits, countAdd);
	}

	public function new()
	{
		this.positionCountExtractor = new LzGenericPositionCountExtractor();
	}
}

class LzGenericPositionCountExtractor implements IPositionCountExtractor
{
	public var countAdd:Int = 2;
	private var countOffset:Int = 0;
	private var countMask:Int = BitUtils.mask(4);
	private var positionOffset:Int = 4;
	private var positionMask:Int = BitUtils.mask(12);

	public function new()
	{

	}

	public function setCountPositionBits(countBits:Int, positionBits:Int, countAdd:Int):IPositionCountExtractor
	{
		if (countBits + positionBits != 16) throw('Invalid bots $countBits, $positionBits');

		this.countOffset = 0;
		this.countMask = BitUtils.mask(countBits);

		this.positionOffset = countBits;
		this.positionMask = BitUtils.mask(positionBits);

		this.countAdd = countAdd;

		return this;
	}

	@:noStack public function extractPosition(param:Int):Int
	{
		return BitUtils.extractWithMask(param, positionOffset, positionMask);
	}

	@:noStack public function extractCount(param:Int):Int
	{
		return BitUtils.extractWithMask(param, countOffset, countMask) + countAdd;
	}
}