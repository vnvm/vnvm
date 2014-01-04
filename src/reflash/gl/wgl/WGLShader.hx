package reflash.gl.wgl;

import openfl.gl.GLShader;
import openfl.gl.GL;

class WGLShader
{
	public var handle:GLShader;
	private var source:String;
	private var type:WGLShaderType;

	static public function createWithSource(source:String, type:WGLShaderType):WGLShader
	{
		return new WGLShader(source, type);
	}

	public function new(source:String, type:WGLShaderType)
	{
		this.source = source;
		this.type = type;
		__recreate();
	}

	private function __recreate()
	{
		handle = GL.createShader (switch (type) {
			case WGLShaderType.FRAGMENT: GL.FRAGMENT_SHADER;
			case WGLShaderType.VERTEX: GL.VERTEX_SHADER;
		}); WGLCommon.check();
		GL.shaderSource (handle, source); WGLCommon.check();
		GL.compileShader (handle); WGLCommon.check();
		if (GL.getShaderParameter(handle, GL.COMPILE_STATUS) == 0) {
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
}