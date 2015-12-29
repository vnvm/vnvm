package common.display;
import common.imaging.GraphicUtils;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;

/**
 * ...
 * @author soywiz
 */

class Sprite9Slice extends Sprite
{
	var bitmapData:BitmapData;
	var innerRectangle:Rectangle;

	public function new(bitmapData:BitmapData, innerRectangle:Rectangle) 
	{
		super();
		
		this.bitmapData = bitmapData;
		this.innerRectangle = innerRectangle;
	}
	
	public function update(width:Int, height:Int):Void
	{
		SpriteUtils.removeSpriteChilds(this);
		
		var widthLeft:Int = Std.int(innerRectangle.left), widthRight:Int = Std.int(bitmapData.width - innerRectangle.right);
		var heightTop:Int = Std.int(innerRectangle.top), heightBottom:Int = Std.int(bitmapData.height - innerRectangle.bottom);

		var drawWidths:Array<Int> = [widthLeft, width - widthLeft - widthRight, widthRight];
		var drawHeights:Array<Int> = [heightTop, height - heightTop - heightBottom, heightBottom];
		
		var bitmapWidths:Array<Int> = [widthLeft, bitmapData.width - widthLeft - widthRight, widthRight];
		var bitmapHeights:Array<Int> = [heightTop, bitmapData.height - heightTop - heightBottom, heightBottom];
		
		//trace(width + ", " + height);
		//trace(drawWidths + ", " + drawHeights);

		//trace(bitmapData.width + ", " + bitmapData.height);
		//trace(bitmapWidths + ", " + bitmapHeights);

		//var xList:Array<Int> = [0, widthLeft];
		
		var bitmapY:Int = 0;
		var drawY:Int = 0;
		for (hIndex in 0 ... 3) {
			var bitmapHeight:Int = bitmapHeights[hIndex];
			var drawHeight:Int = drawHeights[hIndex];

			var bitmapX:Int = 0;
			var drawX:Int = 0;
			for (wIndex in 0 ... 3) {
				var bitmapWidth:Int = bitmapWidths[wIndex];
				var drawWidth:Int = drawWidths[wIndex];
				
				//trace(Std.format("($drawX, $drawY)-($drawWidth, $drawHeight) : ($bitmapX, $bitmapY)-($bitmapWidth, $bitmapHeight)"));

				GraphicUtils.drawBitmapSlice(
					graphics, bitmapData,
					drawX, drawY,
					bitmapX, bitmapY,
					drawWidth, drawHeight,
					bitmapWidth, bitmapHeight
				);
				
				bitmapX += bitmapWidth;
				drawX += drawWidth;
			}
			bitmapY += bitmapHeight;
			drawY += drawHeight;
		}
	}
}