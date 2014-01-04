package common;

import lang.MathEx;
class BitUtils
{
	@:noStack static public inline function mask(bits:Int):Int
	{
		return ((1 << bits) - 1);
	}

	@:noStack static public inline function extract(value:Int, offset:Int, bits:Int):Int
	{
		return (value >> offset) & mask(bits);
	}

	@:noStack static public inline function extractScaled(value:Int, offset:Int, bits:Int, destination:Int):Int
	{
		return MathEx.int_div(extractWithMask(value, offset, mask(bits)) * destination, mask(bits));
	}

	@:noStack static public inline function extractWithMask(value:Int, offset:Int, mask:Int):Int
	{
		return (value >> offset) & mask;
	}

	@:noStack static public inline function rotateRight8(value:Int, offset:Int):Int
	{
		return _rotateRightBits((value & 0xFF), offset, 8);
	}

	@:noStack static private inline function _rotateRightBits(value:Int, offset:Int, bits:Int):Int
	{
		return (value >>> offset) | (value << (bits - offset));
	}
}