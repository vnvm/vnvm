package reflash.display;

import reflash.display.shader.TextureShader;
import reflash.display.shader.TransitionShader;
import reflash.wgl.WGLTexture;
class TransitionImage2 extends DisplayObject2
{
	private var colorTexture:WGLTexture;
	private var maskTexture:WGLTexture;
	private var mask:WGLTexture;
	public var step:Float;

	public function new(colorTexture:WGLTexture, maskTexture:WGLTexture, step:Float = 0.5)
	{
		super();
		this.colorTexture = colorTexture;
		this.maskTexture = maskTexture;
		this.width = colorTexture.width;
		this.height = colorTexture.height;
		this.step = step;
	}

	override private function drawInternal(drawContext:DrawContext)
	{
		//var shader = TransitionShader.getInstance();
		var shader = TextureShader.getInstance();
		shader.use();
		shader.setProjection(drawContext.projectionMatrix);
		shader.setModelView(drawContext.modelViewMatrix);

		var dpx = Std.int(width * this.anchorX);
		var dpy = Std.int(height * this.anchorY);

		var x1:Float = 0 - dpx, x2:Float = width - dpx;
		var y1:Float = 0 - dpy, y2:Float = height - dpy;

		var tx1:Float = 0, tx2:Float = 1;
		var ty1:Float = 0, ty2:Float = 1;

		//shader.setColorTexture(this.colorTexture.textureBase).setMaskTexture(this.maskTexture.textureBase).setStep(step);
		shader.setTexture(this.colorTexture.textureBase);

		shader.setAlpha(drawContext.alpha);

		//Log.trace('($x1, $y1)-($x2, $y2) (${texture.px1},${texture.py1})-(${texture.px2},${texture.py2})');

		shader.addVertex(x1, y2, colorTexture.px1, colorTexture.py2);
		shader.addVertex(x1, y1, colorTexture.px1, colorTexture.py1);
		shader.addVertex(x2, y2, colorTexture.px2, colorTexture.py2);
		shader.addVertex(x2, y1, colorTexture.px2, colorTexture.py1);

		shader.draw();
	}

}

