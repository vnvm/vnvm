package reflash.display;

import reflash.gl.IGLTexture;
import reflash.display.shader.TransitionShader;

class TransitionImage2 extends DisplayObject2
{
	private var colorTexture1:IGLTexture;
	private var colorTexture2:IGLTexture;
	private var maskTexture:IGLTexture;
	private var mask:IGLTexture;
	public var step:Float;
	public var reverse:Bool;
	public var blend:Bool;

	public function new(colorTexture1:IGLTexture, colorTexture2:IGLTexture, maskTexture:IGLTexture, step:Float = 0.5, reverse:Bool = false, blend:Bool = false)
	{
		super();
		this.colorTexture1 = colorTexture1;
		this.colorTexture2 = colorTexture2;
		this.maskTexture = maskTexture;
		this.width = maskTexture.width;
		this.height = maskTexture.height;
		this.step = step;
		this.reverse = reverse;
		this.blend = blend;
	}

	override private function drawInternal(drawContext:DrawContext)
	{
		var shader = TransitionShader.getInstance();
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
		shader.setMaskTexture(this.maskTexture.textureBase);
		shader.setStep(step);
		shader.setReverse(reverse);
		shader.setBlend(blend);
		//shader.setTexture(this.colorTexture.textureBase);

		shader.setAlpha(drawContext.alpha);

		//Log.trace('($x1, $y1)-($x2, $y2) (${texture.px1},${texture.py1})-(${texture.px2},${texture.py2})');

		shader.addVertex(x1, y2, maskTexture.px1, maskTexture.py2);
		shader.addVertex(x1, y1, maskTexture.px1, maskTexture.py1);
		shader.addVertex(x2, y2, maskTexture.px2, maskTexture.py2);
		shader.addVertex(x2, y1, maskTexture.px2, maskTexture.py1);

		shader.draw();
	}

}

