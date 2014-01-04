package common.imaging.format.pixel;

interface IPixelFormat
{
	function extractRed(value:Int):Int;
	function extractGreen(value:Int):Int;
	function extractBlue(value:Int):Int;
	function extractAlpha(value:Int):Int;
}
