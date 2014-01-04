package reflash.display;

import openfl.gl.GL;
import haxe.Log;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;

class DisplayObject2 implements IDrawable
{
	public var parent:DisplayObjectContainer2;
	public var anchorX:Float = 0;
	public var anchorY:Float = 0;
	public var x:Float = 0;
	public var y:Float = 0;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var zIndex(default, set):Int;
	public var width:Float;
	public var height:Float;
	public var angle:Float = 0;
	public var alpha:Float = 1;
	public var visible:Bool = true;
	public var blendMode:BlendMode;

	public function new()
	{
		blendMode = BlendMode.NORMAL;
	}

	private function applyMatrix(matrix:Matrix3D, recursive:Bool = false)
	{
		if (recursive && (parent != null))
		{
			parent.applyMatrix(matrix);
		}

		matrix.prependTranslation(x, y, 0);
		matrix.prependRotation(angle, Vector3D.Z_AXIS);
		matrix.prependScale(scaleX, scaleY, 1);
	}

	public function globalToLocal(point:Point):Point
	{
		var matrix = new Matrix3D();
		applyMatrix(matrix, true);
		matrix.invert();
		var transformedVector = matrix.transformVector(new Vector3D(point.x, point.y));
		return new Point(transformedVector.x, transformedVector.y);
	}

	public function localToGlobal(point:Point):Point
	{
		var matrix = new Matrix3D();
		applyMatrix(matrix, true);
		var transformedVector = matrix.transformVector(new Vector3D(point.x, point.y));
		return new Point(transformedVector.x, transformedVector.y);
	}


	private function set_zIndex(value:Int):Int
	{
		if (zIndex != value)
		{
			zIndex = value;
			if (parent != null) parent.resort(this);
		}
		return zIndex;
	}

	public function setAnchor(x:Float, y:Float):DisplayObject2
	{
		this.anchorX = x;
		this.anchorY = y;
		return this;
	}

	public function setZIndex(zIndex:Int):DisplayObject2
	{
		this.zIndex = zIndex;
		return this;
	}

	public function setPosition(x:Float, y:Float):DisplayObject2
	{
		this.x = x;
		this.y = y;
		return this;
	}

	public function setSize(width:Float, height:Float):DisplayObject2
	{
		this.width = width;
		this.height = height;
		return this;
	}

	public function drawElement(drawContext:DrawContext)
	{
		if (visible)
		{
			var oldModelViewMatrix = drawContext.modelViewMatrix.clone();
			var oldAlpha = drawContext.alpha;
			{
				applyMatrix(drawContext.modelViewMatrix);
				drawContext.alpha *= alpha;

				switch (blendMode)
				{
					case BlendMode.NORMAL:
						GL.enable(GL.BLEND);
						//GL.blendFunc (GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
						GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
					case BlendMode.ADD:
						GL.enable(GL.BLEND);
						GL.blendFunc(GL.SRC_ALPHA, GL.ONE);
					//default: throw('Invalid blendMode: $blendMode');
				}

				drawInternal(drawContext);
			}
			drawContext.alpha = oldAlpha;
			drawContext.modelViewMatrix = oldModelViewMatrix;
		}
	}

	private function drawInternal(drawContext:DrawContext)
	{
	}
}
