package reflash.gl.wgl;

import reflash.gl.wgl.util.WGLCommon;
import reflash.gl.wgl.type.WGLShaderType;
import openfl.gl.GLShader;
import openfl.gl.GL;

class WGLShader
{
	public var handle:GLShader;
	private var source:String;
	private var type:WGLShaderType;

	public function new(source:String, type:WGLShaderType)
	{
		this.source = source;
		this.type = type;
		handle = GL.createShader(getGlShaderType(type));
		WGLCommon.check();

		GL.shaderSource(handle, source); WGLCommon.check();
		GL.compileShader(handle); WGLCommon.check();

		if (GL.getShaderParameter(handle, GL.COMPILE_STATUS) == 0)
		{
			var info = GL.getShaderInfoLog(handle);
			throw 'Error compiling shader $info $source';
		}
		WGLCommon.check();
	}

	public function dispose()
	{
		if (handle != null)
		{
			GL.deleteShader(handle); WGLCommon.check();
			handle = null;
		}
	}

	static public function createWithSource(source:String, type:WGLShaderType):WGLShader
	{
		return new WGLShader(source, type);
	}

	static private function getGlShaderType(type:WGLShaderType):Int
	{
		return switch (type) { case WGLShaderType.FRAGMENT: GL.FRAGMENT_SHADER; case WGLShaderType.VERTEX: GL.VERTEX_SHADER; };
	}
}