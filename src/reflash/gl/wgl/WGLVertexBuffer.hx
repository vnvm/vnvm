package reflash.gl.wgl;

import reflash.gl.wgl.util.IWGLObject;
import reflash.gl.wgl.util._WGLInstances;
import reflash.gl.wgl.util.WGLCommon;
import lang.IDisposable;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;
import openfl.gl.GL;

class WGLVertexBuffer implements IDisposable implements IWGLObject
{
	private var vertexBuffer:GLBuffer;
	private var vertexDescriptor:IGLVertexDescriptor;
	private var data:Array<Float>;

	public function new(vertexDescriptor:IGLVertexDescriptor)
	{
		this.vertexDescriptor = vertexDescriptor;
		__recreate();
		_WGLInstances.getInstance().add(this);
	}

	public function dispose()
	{
		_WGLInstances.getInstance().remove(this);
		if (vertexBuffer != null)
		{
			GL.deleteBuffer(vertexBuffer);
			WGLCommon.check();
			vertexBuffer = null;
		}
	}

	static public function create(vertexDescriptor:IGLVertexDescriptor):WGLVertexBuffer
	{
		return new WGLVertexBuffer(vertexDescriptor);
	}

	public function __recreate()
	{
		this.vertexBuffer = GL.createBuffer();
		_setData();
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
		this._bind();
		this.vertexDescriptor.use();
		GL.drawArrays(GL.TRIANGLE_STRIP, first, count);
		WGLCommon.check();
		this.vertexDescriptor.unuse();
		return this;
	}
}