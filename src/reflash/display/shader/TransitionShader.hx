package reflash.display.shader;

import reflash.gl.IGLTextureBase;
import lang.MathEx;
import openfl.gl.GL;
import reflash.gl.wgl.WGLType;
import reflash.gl.wgl.WGLVertexDescriptor;
import reflash.gl.wgl.WGLProgram;

class TransitionShader extends PlaneShader
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
        		uniform sampler2D uSamplerMask;
        		uniform float alpha;
        		uniform float step;

				void main(void)
				{
					vec3 color1 = texture2D(uSampler1, vTexCoord).rgb;
					vec3 color2 = texture2D(uSampler2, vTexCoord).rgb;
					float step1 = texture2D(uSamplerMask, vTexCoord).r;
					gl_FragColor.rgb = mix(color1, color2, clamp(step1 + step, 0.0, 1.0));
					gl_FragColor.a = alpha;
				}
			"
		);

		vertexDescriptor = WGLVertexDescriptor.create(program);
		vertexDescriptor.addField("vertexPosition", 2);
		vertexDescriptor.addField("aTexCoord", 2);
	}

	static private var instance:TransitionShader;

	static public function getInstance():TransitionShader
	{
		if (instance == null) instance = new TransitionShader();
		return instance;
	}

	public function setColorTexture1(value:IGLTextureBase):TransitionShader
	{
		flush();
		program.getUniform("uSampler1").setTexture(1, value);
		return this;
	}

	public function setColorTexture2(value:IGLTextureBase):TransitionShader
	{
		flush();
		program.getUniform("uSampler2").setTexture(2, value);
		return this;
	}

	public function setMaskTexture(value:IGLTextureBase):TransitionShader
	{
		flush();
		program.getUniform("uSamplerMask").setTexture(0, value);
		return this;
	}

	public function setAlpha(value:Float):TransitionShader
	{
		flush();
		program.getUniform("alpha").setFloat(value);
		return this;
	}

	public function setStep(value:Float):TransitionShader
	{
		flush();
		program.getUniform("step").setFloat(MathEx.translateRange(value, 0, 1, -1, 1));
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
