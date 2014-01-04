package reflash.display.shader;

import reflash.gl.IGLTextureBase;
import reflash.gl.wgl.type.WGLType;
import reflash.gl.wgl.WGLVertexDescriptor;
import reflash.gl.wgl.WGLProgram;

class TextureShader extends PlaneShader
{
	public function new()
	{
		program = WGLProgram.createProgram(
			"
				attribute vec3 vertexPosition;
				attribute vec3 aTexCoord;

				uniform mat4 modelViewMatrix;
				uniform mat4 projectionMatrix;

				varying vec2 vTexCoord;

				void main(void)
				{
					gl_Position = projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
					vTexCoord = aTexCoord.xy;
				}
			",
			"
        		varying vec2 vTexCoord;
        		uniform sampler2D uSampler;
        		uniform float alpha;

				void main(void)
				{
					gl_FragColor = texture2D(uSampler, vTexCoord);
					gl_FragColor.a *= alpha;
				}
			"
		);

		vertexDescriptor = WGLVertexDescriptor.create(program);
		vertexDescriptor.addField("vertexPosition", 2);
		vertexDescriptor.addField("aTexCoord", 2);
	}

	static private var instance:TextureShader;

	static public function getInstance():TextureShader
	{
		if (instance == null) instance = new TextureShader();
		return instance;
	}

	public function setTexture(texture:IGLTextureBase):Void
	{
		flush();
		program.getUniform("uSampler").setTexture(0, texture);
	}

	public function setAlpha(alpha:Float):Void
	{
		flush();
		program.getUniform("alpha").setFloat(alpha);
	}


	public function addVertex(x:Float, y:Float, tx:Float, ty:Float)
	{
		if (array == null) array = [];
		array.push(x);
		array.push(y);
		array.push(tx);
		array.push(ty);
		vertexCount++;
	}
}
