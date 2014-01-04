package reflash.display;

import haxe.Log;
import reflash.wgl.WGLTexture;
import reflash.wgl.WGLTextureBase;
import reflash.display.shader.TextureShader;
import reflash.display.shader.SolidColorShader;
class Image2 extends DisplayObject2
{
	private var texture:WGLTexture;

	public function new(texture:WGLTexture)
	{
		super();
		this.texture = texture;
		this.width = texture.width;
		this.height = texture.height;
	}

	override private function drawInternal(drawContext:DrawContext)
	{
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

		shader.setTexture(this.texture.textureBase);
		shader.setAlpha(drawContext.alpha);

		//Log.trace('($x1, $y1)-($x2, $y2) (${texture.px1},${texture.py1})-(${texture.px2},${texture.py2})');

		shader.addVertex(x1, y2, texture.px1, texture.py2);
		shader.addVertex(x1, y1, texture.px1, texture.py1);
		shader.addVertex(x2, y2, texture.px2, texture.py2);
		shader.addVertex(x2, y1, texture.px2, texture.py1);

		shader.draw();
	}
}
