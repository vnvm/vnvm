package common.display;
import flash.display.Sprite;

class Quad extends Sprite
{
	public function new(width:Int, height:Int, color:Int)
	{
		super();
		this.graphics.beginFill(color, 1);
		this.graphics.drawRect(0, 0, width, height);
		this.graphics.endFill();
	}
}
