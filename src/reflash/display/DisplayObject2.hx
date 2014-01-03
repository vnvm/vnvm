package reflash.display;

import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import reflash.display.shader.SolidColorShader;
import reflash.wgl.WGLVertexBuffer;

class DisplayObject2 implements IDrawable
{
	public var anchorX:Float = 0;
	public var anchorY:Float = 0;
	public var x:Float = 0;
	public var y:Float = 0;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var zIndex:Int = 0;
	public var width:Float;
	public var height:Float;
	public var angle:Float = 0;
	public var alpha:Float = 1;

	public function setAnchor(x:Float, y:Float):DisplayObject2
	{
		this.anchorX = x;
		this.anchorY = y;
		return this;
	}

	public function setPosition(x:Float, y:Float):DisplayObject2
	{
		this.x = x;
		this.y = y;
		return this;
	}

	public function new()
	{
	}

	inline public function drawElement(drawContext:DrawContext)
	{
		var oldModelViewMatrix = drawContext.modelViewMatrix.clone();
		var oldAlpha = drawContext.alpha;
		{
			drawContext.modelViewMatrix.prependTranslation(x, y, 0);
			drawContext.modelViewMatrix.prependRotation(angle, Vector3D.Z_AXIS);
			drawContext.modelViewMatrix.prependScale(scaleX, scaleY, 1);
			drawContext.alpha *= alpha;
			drawInternal(drawContext);
		}
		drawContext.alpha = oldAlpha;
		drawContext.modelViewMatrix = oldModelViewMatrix;
	}

	private function drawInternal(drawContext:DrawContext)
	{
	}
}
