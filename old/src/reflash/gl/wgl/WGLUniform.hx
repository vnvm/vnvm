package reflash.gl.wgl;

import reflash.gl.wgl.util.WGLCommon;
import openfl.gl.GL;
import flash.geom.Matrix3D;

class WGLUniform implements IGLUniform
{
	private var program:IGLProgram;
	private var index:Int;

	public function new(program:IGLProgram, index:Int)
	{
		this.program = program;
		this.index = index;
	}

	public function setTexture(textureUnit:Int, textureBase:IGLTextureBase)
	{
		textureBase.bindToUnit(textureUnit);
		GL.uniform1i(this.index, textureUnit);
		WGLCommon.check();
	}

	public function setInteger(value:Int)
	{
		GL.uniform1i(index, value);
		WGLCommon.check();
	}

	public function setBool(value:Bool)
	{
		GL.uniform1i(index, value ? 1 : 0);
		WGLCommon.check();
	}

	public function setFloat(value:Float)
	{
		GL.uniform1f(index, value);
		WGLCommon.check();
	}

	public function setFloat4(x:Float, y:Float, z:Float, w:Float)
	{
		GL.uniform4f(index, x, y, z, w);
		WGLCommon.check();
	}

	public function setMatrix(matrix:Matrix3D, transpose:Bool = false)
	{
		GL.uniformMatrix3D(index, transpose, matrix);
		WGLCommon.check();
	}
}