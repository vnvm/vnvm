package reflash.display.shader;

import reflash.gl.IGLTextureBase;
import lang.MathEx;
import openfl.gl.GL;
import reflash.gl.wgl.type.WGLType;
import reflash.gl.wgl.WGLVertexDescriptor;
import reflash.gl.wgl.WGLProgram;

class BlendShader extends PlaneShader
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
        		uniform sampler2D uSampler1;
        		uniform sampler2D uSampler2;
        		uniform float alpha;
        		uniform float step;

				void main(void)
				{
					vec3 color1 = texture2D(uSampler1, vTexCoord).rgb;
					vec3 color2 = texture2D(uSampler2, vTexCoord).rgb;
					gl_FragColor.rgb = color1.rgb + color2.rgb * step;
					gl_FragColor.a = alpha;
				}
			"
		);

		vertexDescriptor = WGLVertexDescriptor.create(program);
		vertexDescriptor.addField("vertexPosition", 2);
		vertexDescriptor.addField("aTexCoord", 2);
	}

	static private var instance:BlendShader;

	static public function getInstance():BlendShader
	{
		if (instance == null) instance = new BlendShader();
		return instance;
	}

	public function setColorTexture1(value:IGLTextureBase):BlendShader
	{
		flush();
		program.getUniform("uSampler1").setTexture(1, value);
		return this;
	}

	public function setColorTexture2(value:IGLTextureBase):BlendShader
	{
		flush();
		program.getUniform("uSampler2").setTexture(2, value);
		return this;
	}

	public function setAlpha(value:Float):BlendShader
	{
		flush();
		program.getUniform("alpha").setFloat(value);
		return this;
	}

	public function setStep(value:Float):BlendShader
	{
		flush();
		program.getUniform("step").setFloat(value);
		return this;
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
