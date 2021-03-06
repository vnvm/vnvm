package reflash.display.shader;

import reflash.gl.IGLProgram;
import reflash.gl.IGLVertexDescriptor;
import reflash.gl.wgl.WGLVertexBuffer;
import flash.geom.Matrix3D;

class PlaneShader
{
	private var program:IGLProgram;
	public var vertexDescriptor:IGLVertexDescriptor;

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
