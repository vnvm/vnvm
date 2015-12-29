package common.geom;

import flash.geom.Point;
import flash.geom.Rectangle;
class Anchor
{
	static public var topLeft:Anchor;
	static public var centerCenter:Anchor;

	static public function __init__()
	{
		topLeft = new Anchor(0, 0);
		centerCenter = new Anchor(0.5, 0.5);
	}

	public var sx:Float;
	public var sy:Float;

	public function new(sx:Float, sy:Float)
	{
		this.sx = sx;
		this.sy = sy;
	}

	public function getPointInRect(rect:Rectangle):Point
	{
		return new Point(rect.x + rect.width * this.sx, rect.y + rect.height * this.sy);
	}
}