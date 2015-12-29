package reflash.display;

import Array;
import flash.geom.Matrix3D;

class DrawContext
{
	public var projectionMatrix:Matrix3D;
	public var modelViewMatrix:Matrix3D;
	public var alpha:Float;

	public function new()
	{
		this.projectionMatrix = new Matrix3D();
		this.modelViewMatrix = new Matrix3D();
		this.alpha = 1;
	}
}
