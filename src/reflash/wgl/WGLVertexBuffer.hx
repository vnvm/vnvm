package reflash.wgl;

import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;
import openfl.gl.GL;

class WGLVertexBuffer
{
	private var vertexBuffer:GLBuffer;
	private var vertexDescriptor:WGLVertexDescriptor;

	static public function create(vertexDescriptor:WGLVertexDescriptor):WGLVertexBuffer
	{
		return new WGLVertexBuffer(vertexDescriptor);
	}

	public function new(vertexDescriptor:WGLVertexDescriptor)
	{
		this.vertexBuffer = GL.createBuffer();
		this.vertexDescriptor = vertexDescriptor;
	}

	public function setData(vertices:Array<Float>):WGLVertexBuffer
	{
		this.bind();
		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array (cast vertices), GL.STATIC_DRAW);
		return this;
	}

	public function bind()
	{
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
	}

	public function draw(first:Int, count:Int):WGLVertexBuffer
	{
		this.bind();
		this.vertexDescriptor.use();
		GL.drawArrays(GL.TRIANGLE_STRIP, first, count);
		this.vertexDescriptor.unuse();
		return this;
	}

	public function dispose()
	{
		GL.deleteBuffer(vertexBuffer);
	}
}