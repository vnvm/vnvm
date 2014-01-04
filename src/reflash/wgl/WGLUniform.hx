package reflash.wgl;

import openfl.gl.GL;
import reflash.wgl.WGLProgram;
import flash.geom.Matrix3D;

class WGLUniform
{
	private var program:WGLProgram;
	private var index:Int;

	public function new(program:WGLProgram, index:Int)
	{
		this.program = program;
		this.index = index;
	}

	public function setTexture(textureUnit:Int, textureBase:WGLTextureBase)
	{
		GL.activeTexture(GL.TEXTURE0 + textureUnit);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		textureBase.bindToUnit(textureUnit);
		GL.uniform1i(this.index, textureUnit);
	}

	public function setInteger(value:Int)
	{
		GL.uniform1i(index, value);
	}

	public function setFloat(value:Float)
	{
		GL.uniform1f(index, value);
	}

	public function setFloat4(x:Float, y:Float, z:Float, w:Float)
	{
		GL.uniform4f(index, x, y, z, w);
	}

	public function setMatrix(matrix:Matrix3D, transpose:Bool = false)
	{
		GL.uniformMatrix3D(index, transpose, matrix);
	}
}