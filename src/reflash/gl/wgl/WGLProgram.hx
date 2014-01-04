package reflash.gl.wgl;

import haxe.Log;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.gl.GL;
class WGLProgram
{
	private var vertexShader:WGLShader;
	private var fragmentShader:WGLShader;
	private var programHandle:GLProgram;

	static public function createProgram(vertexShaderSource:String, fragmentShaderSource:String):WGLProgram
	{
		return new WGLProgram(vertexShaderSource, fragmentShaderSource);
	}

	public function new(vertexShaderSource:String, fragmentShaderSource:String)
	{
		vertexShader = WGLShader.createWithSource(vertexShaderSource, WGLShaderType.VERTEX);
		fragmentShader = WGLShader.createWithSource(fragmentShaderSource, WGLShaderType.FRAGMENT);

		programHandle = GL.createProgram();
		GL.attachShader(programHandle, vertexShader.handle);
		GL.attachShader(programHandle, fragmentShader.handle);
		GL.linkProgram(programHandle);

		if (GL.getProgramParameter(programHandle, GL.LINK_STATUS) == 0) throw "Unable to initialize the shader program.";
	}

	public function use()
	{
		GL.useProgram(programHandle);
	}

	public function getAttribute(name:String):WGLAttribute
	{
		var location = GL.getAttribLocation(programHandle, name);
		if (location < 0) {
			//throw('Can\'t find attribute "$name""');
			Log.trace('Can\'t find attribute "$name""');
		}
		return new WGLAttribute(this, location);
	}

	public function getVertexDescriptor():WGLVertexDescriptor
	{
		return new WGLVertexDescriptor(this);
	}

	public function getUniform(name:String):WGLUniform
	{
		var location = GL.getUniformLocation(programHandle, name);
		if (location < 0) {
			//throw('Can\'t find uniform "$name""');
			Log.trace('Can\'t find uniform "$name""');
		}
		return new WGLUniform(this, location);
	}

	public function dispose()
	{
		vertexShader.dispose();
		fragmentShader.dispose();
		GL.deleteProgram(programHandle);
	}
}