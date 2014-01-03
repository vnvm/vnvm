package reflash.display;

import flash.geom.Matrix3D;
import reflash.display.shader.SolidColorShader;

class Sprite2 extends DisplayObject2
{
	private var childs:Array<DisplayObject2>;

	public function new()
	{
		super();
		childs = new Array<DisplayObject2>();
	}

	public function addChild(child:DisplayObject2):Sprite2
	{
		childs.push(child);
		return this;
	}

	override public function drawInternal(drawContext:DrawContext)
	{
		for (child in childs) child.drawElement(drawContext);
	}
}
