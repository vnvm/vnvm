package reflash.gl.wgl;

import openfl.gl.GLUniformLocation;
import haxe.Log;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.gl.GL;

class WGLProgram implements IGLProgram
{
	private var vertexShader:WGLShader;
	private var fragmentShader:WGLShader;
	private var programHandle:GLProgram;
	private var vertexShaderSource:String;
	private var fragmentShaderSource:String;

	static public function createProgram(vertexShaderSource:String, fragmentShaderSource:String):WGLProgram
	{
		return new WGLProgram(vertexShaderSource, fragmentShaderSource);
	}

	public function new(vertexShaderSource:String, fragmentShaderSource:String)
	{
		this.vertexShaderSource = vertexShaderSource;
		this.fragmentShaderSource = fragmentShaderSource;

		__recreate();
	}

	public function __recreate()
	{
		vertexShader = WGLShader.createWithSource(vertexShaderSource, WGLShaderType.VERTEX);
		fragmentShader = WGLShader.createWithSource(fragmentShaderSource, WGLShaderType.FRAGMENT);

		programHandle = GL.createProgram(); WGLCommon.check();
		GL.attachShader(programHandle, vertexShader.handle); WGLCommon.check();
		GL.attachShader(programHandle, fragmentShader.handle); WGLCommon.check();
		GL.linkProgram(programHandle); WGLCommon.check();

		if (GL.getProgramParameter(programHandle, GL.LINK_STATUS) == 0) throw "Unable to initialize the shader program.";
		WGLCommon.check();
	}

	private function __check()
	{
		//if (programHandle == null) return;

		if (!GL.isProgram(programHandle))
		{
			__recreate();
		}
	}

	public function use()
	{
		__check();
		GL.useProgram(programHandle); WGLCommon.check();
	}

	public function getAttribute(name:String):IGLAttribute
	{
		__check();
		var location = GL.getAttribLocation(programHandle, name);
		WGLCommon.check();
		if (location < 0) {
			//throw('Can\'t find attribute "$name""');
			Log.trace('Can\'t find attribute "$name""');
		}
		return new WGLAttribute(this, location);
	}

	public function getVertexDescriptor():IGLVertexDescriptor
	{
		return new WGLVertexDescriptor(this);
	}

	public function getUniform(name:String):IGLUniform
	{
		__check();
		var location = GL.getUniformLocation(programHandle, name); WGLCommon.check();
		if (location < 0) {
			//throw('Can\'t find uniform "$name""');
			Log.trace('Can\'t find uniform "$name""');
		}
		return new WGLUniform(this, location);
	}

	public function dispose()
	{

		if (vertexShader != null) { vertexShader.dispose(); vertexShader = null; }
		if (fragmentShader != null) { fragmentShader.dispose(); fragmentShader = null; }
		GL.deleteProgram(programHandle); WGLCommon.check();
	}
}