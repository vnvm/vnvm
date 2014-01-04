package reflash.gl;

import flash.geom.Matrix3D;

interface IGLUniform
{
	function setTexture(textureUnit:Int, textureBase:IGLTextureBase):Void;
	function setInteger(value:Int):Void;
	function setBool(value:Bool):Void;
	function setFloat(value:Float):Void;
	function setFloat4(x:Float, y:Float, z:Float, w:Float):Void;
	function setMatrix(matrix:Matrix3D, transpose:Bool = false):Void;
}
