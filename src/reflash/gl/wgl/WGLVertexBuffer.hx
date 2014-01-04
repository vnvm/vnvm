package reflash.gl.wgl;

import lang.IDisposable;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;
import openfl.gl.GL;

class WGLVertexBuffer implements IDisposable
{
	private var vertexBuffer:GLBuffer;
	private var vertexDescriptor:IGLVertexDescriptor;
	private var data:Array<Float>;

	static public function create(vertexDescriptor:IGLVertexDescriptor):WGLVertexBuffer
	{
		return new WGLVertexBuffer(vertexDescriptor);
	}

	public function new(vertexDescriptor:IGLVertexDescriptor)
	{
		this.vertexDescriptor = vertexDescriptor;
		__recreate();
	}

	private function __recreate()
	{
		this.vertexBuffer = GL.createBuffer();
		_setData();
	}

	private function _check()
	{
		if (!GL.isBuffer(this.vertexBuffer))
		{
			__recreate();
		}
	}

	private function _setData()
	{
		if (this.data != null)
		{
			this._bind();
			GL.bufferData(GL.ARRAY_BUFFER, new Float32Array (cast this.data), GL.STATIC_DRAW);
			WGLCommon.check();
		}
	}

	public function setData(vertices:Array<Float>):WGLVertexBuffer
	{
		this.data = vertices.slice(0);
		//this.data = vertices;
		this._check();
		_setData();
		return this;
	}

	private function _bind()
	{
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		WGLCommon.check();
	}

	public function draw(first:Int, count:Int):WGLVertexBuffer
	{
		this._check();
		this._bind();
		this.vertexDescriptor.use();
		GL.drawArrays(GL.TRIANGLE_STRIP, first, count);
		WGLCommon.check();
		this.vertexDescriptor.unuse();
		return this;
	}

	public function dispose()
	{
		if (vertexBuffer != null)
		{
			GL.deleteBuffer(vertexBuffer);
			WGLCommon.check();
			vertexBuffer = null;
		}
	}
}