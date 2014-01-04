package reflash.gl.wgl;

import openfl.gl.GLShader;
import openfl.gl.GL;

class WGLShader
{
	public var handle:GLShader;

	static public function createWithSource(source:String, type:WGLShaderType):WGLShader
	{
		return new WGLShader(source, type);
	}

	public function new(source:String, type:WGLShaderType)
	{
		handle = GL.createShader (switch (type) {
			case WGLShaderType.FRAGMENT: GL.FRAGMENT_SHADER;
			case WGLShaderType.VERTEX: GL.VERTEX_SHADER;
		});
		GL.shaderSource (handle, source);
		GL.compileShader (handle);
		if (GL.getShaderParameter(handle, GL.COMPILE_STATUS) == 0) {
			var info = GL.getShaderInfoLog(handle);
			throw 'Error compiling shader $info $source';
		}
	}

	public function dispose()
	{
		GL.deleteShader(handle);
		handle = null;
	}
}