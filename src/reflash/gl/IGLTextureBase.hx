package reflash.gl;

import flash.display.BitmapData;
import lang.IDisposable;
import lang.ReferenceCounter;
import openfl.gl.GLTexture;

interface IGLTextureBase extends IDisposable
{
	public var textureId(default, null):GLTexture;
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var referenceCounter(default, null):ReferenceCounter;

	function bindToUnit(unit:Int):IGLTextureBase;
	function setEmptyPixels(width:Int, height:Int):IGLTextureBase;
	function setPixels(bitmapData:BitmapData):IGLTextureBase;
}
