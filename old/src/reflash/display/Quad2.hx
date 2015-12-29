package reflash.display;

import flash.geom.Matrix3D;
import reflash.display.shader.SolidColorShader;

class Quad2 extends DisplayObject2
{
	public var color:Color2;

	public function new(width:Int, height:Int, color:Color2)
	{
		super();
		this.color = color;
		this.width = width;
		this.height = height;
	}

	override public function drawInternal(drawContext:DrawContext)
	{
		if (width < 1 || height < 1) return;

		var shader = SolidColorShader.getInstance();
		shader.use();
		shader.setProjection(drawContext.projectionMatrix);
		shader.setModelView(drawContext.modelViewMatrix);

		var dpx = Std.int(width * this.anchorX);
		var dpy = Std.int(height * this.anchorY);

		var x1:Float = 0 - dpx, x2:Float = width - dpx + 1;
		var y1:Float = 0 - dpy, y2:Float = height - dpy + 1;

		shader.setColor(color.r, color.g, color.b, color.a * drawContext.alpha);
		shader.addVertex(x1, y2);
		shader.addVertex(x2, y2);
		shader.addVertex(x1, y1);
		shader.addVertex(x2, y1);
		shader.draw();
	}
}
