package reflash.display.shader;

import reflash.gl.wgl.WGLType;
import reflash.gl.wgl.WGLVertexBuffer;
import reflash.gl.wgl.WGLVertexDescriptor;
import reflash.gl.wgl.WGLProgram;

class SolidColorShader extends PlaneShader
{
	public function new()
	{
		program = WGLProgram.createProgram(
			"
				attribute vec3 vertexPosition;

				uniform mat4 modelViewMatrix;
				uniform mat4 projectionMatrix;

				void main(void)
				{
					gl_Position = projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
				}
			",
			"
				uniform vec4 color;

				void main(void)
				{
					//gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
					gl_FragColor = color;
				}
			"
		);

		vertexDescriptor = WGLVertexDescriptor.create(program);
		vertexDescriptor.addField("vertexPosition", 2);
	}

	static private var instance:SolidColorShader;

	static public function getInstance():SolidColorShader
	{
		if (instance == null) instance = new SolidColorShader();
		return instance;
	}

	public function setColor(r:Float, g:Float, b:Float, a:Float):Void
	{
		flush();
		program.getUniform("color").setFloat4(r, g, b, a);
	}

	public function addVertex(x:Float, y:Float)
	{
		if (array == null) array = [];
		array.push(x);
		array.push(y);
		vertexCount++;
	}
}
