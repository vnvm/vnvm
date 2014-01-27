package reflash.display;

import reflash.display.shader.BlendShader;
import reflash.gl.IGLTexture;
import reflash.display.shader.TransitionShader;

class TransitionImageBlend2 extends DisplayObject2
{
	private var colorTexture1:IGLTexture;
	private var colorTexture2:IGLTexture;
	public var step:Float;

	public function new(colorTexture1:IGLTexture, colorTexture2:IGLTexture, step:Float = 0.5)
	{
		super();
		this.colorTexture1 = colorTexture1;
		this.colorTexture2 = colorTexture2;
		this.width = colorTexture1.width;
		this.height = colorTexture1.height;
		this.step = step;
	}

	override private function drawInternal(drawContext:DrawContext)
	{
		var shader = BlendShader.getInstance();
		//var shader = TextureShader.getInstance();
		shader.use();
		shader.setProjection(drawContext.projectionMatrix);
		shader.setModelView(drawContext.modelViewMatrix);

		var dpx = Std.int(width * this.anchorX);
		var dpy = Std.int(height * this.anchorY);

		var x1:Float = 0 - dpx, x2:Float = width - dpx;
		var y1:Float = 0 - dpy, y2:Float = height - dpy;

		var tx1:Float = 0, tx2:Float = 1;
		var ty1:Float = 0, ty2:Float = 1;

		shader.setColorTexture1(this.colorTexture1.textureBase);
		shader.setColorTexture2(this.colorTexture2.textureBase);
		shader.setStep(step);


		shader.setAlpha(drawContext.alpha);

		//Log.trace('($x1, $y1)-($x2, $y2) (${texture.px1},${texture.py1})-(${texture.px2},${texture.py2})');

		shader.addVertex(x1, y2, colorTexture1.px1, colorTexture1.py2);
		shader.addVertex(x1, y1, colorTexture1.px1, colorTexture1.py1);
		shader.addVertex(x2, y2, colorTexture1.px2, colorTexture1.py2);
		shader.addVertex(x2, y1, colorTexture1.px2, colorTexture1.py1);

		shader.draw();
	}

}

