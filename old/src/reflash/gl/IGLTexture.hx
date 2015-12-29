package reflash.gl;

import lang.IDisposable;

interface IGLTexture extends IDisposable
{
	public var textureBase(default, null):IGLTextureBase;
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var width(default, null):Int;
	public var height(default, null):Int;

	public var px1(default, null):Float;
	public var py1(default, null):Float;
	public var px2(default, null):Float;
	public var py2(default, null):Float;

	function slice(x:Int, y:Int, width:Int, height:Int):IGLTexture;
	function split(width:Int, height:Int):Array<IGLTexture>;
}
