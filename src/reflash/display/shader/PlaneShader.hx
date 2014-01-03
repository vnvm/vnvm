package reflash.display.shader;

import haxe.Log;
import reflash.wgl.WGLVertexBuffer;
import reflash.wgl.WGLVertexDescriptor;
import flash.geom.Matrix3D;
import reflash.wgl.WGLProgram;
class PlaneShader
{
	private var program:WGLProgram;
	public var vertexDescriptor:WGLVertexDescriptor;

	public function setModelView(matrix:Matrix3D)
	{
		flush();
		program.getUniform("modelViewMatrix").setMatrix(matrix);
	}

	public function setProjection(matrix:Matrix3D)
	{
		flush();
		program.getUniform("projectionMatrix").setMatrix(matrix);
	}

	private var array:Array<Float>;
	private var vertexCount:Int = 0;

	public function flush()
	{
		draw();
	}

	public function draw()
	{
		if (array == null) return;
		if (vertexCount == 0) return;
		WGLVertexBuffer.create(vertexDescriptor).setData(array).draw(0, vertexCount).dispose();
		array = null;
		vertexCount = 0;
	}

	public function use()
	{
		program.use();
	}
}
