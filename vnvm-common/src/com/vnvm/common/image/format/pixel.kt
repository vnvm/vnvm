package com.vnvm.common.image.format

interface IPixelFormat
{
	function extractRed(value:Int):Int;
	function extractGreen(value:Int):Int;
	function extractBlue(value:Int):Int;
	function extractAlpha(value:Int):Int;
}

class PixelFormat565 implements IPixelFormat
{
	public function new()
	{

	}

	@:noStack inline public function extractRed(value:Int):Int
	{
		return BitUtils.extractScaled(value, 11, 5, 0xFF);
	}

	@:noStack inline public function extractGreen(value:Int):Int
	{
		return BitUtils.extractScaled(value, 5, 6, 0xFF);
	}

	@:noStack inline public function extractBlue(value:Int):Int
	{
		return BitUtils.extractScaled(value, 0, 5, 0xFF);
	}

	@:noStack inline public function extractAlpha(value:Int):Int
	{
		return 0xFF;
	}
}
