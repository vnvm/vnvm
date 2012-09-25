package common;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.Vector;

/**
 * ...
 * @author 
 */

class GraphicUtils 
{
	static private var matrix:Matrix = new Matrix();

	static public function drawBitmapSlice(graphics:Graphics, bitmapData:BitmapData, dstX:Int, dstY:Int, srcX:Int, srcY:Int, dstW:Int, dstH:Int, ?srcW:Int, ?srcH:Int):Void {
		if (srcW == null) srcW = dstW;
		if (srcH == null) srcH = dstH;

		var pointTL:Point = new Point(dstX       , dstY       );
		var pointBR:Point = new Point(dstX + dstW, dstY + dstH);

		var uvPointTL:Point = new Point((srcX) / bitmapData.width, (srcY) / bitmapData.height);
		var uvPointBR:Point = new Point((srcX + srcW) / bitmapData.width, (srcY + srcH) / bitmapData.height);
		
		var verticies:Array<Float> = [pointTL.x, pointTL.y, pointBR.x, pointTL.y, pointTL.x, pointBR.y, pointBR.x, pointBR.y];
		var uvtData:Array<Float> = [uvPointTL.x, uvPointTL.y, uvPointBR.x, uvPointTL.y, uvPointTL.x, uvPointBR.y, uvPointBR.x, uvPointBR.y];
		var indices:Array<Int> = [0, 1, 2, 1, 3, 2];
		 
		graphics.beginBitmapFill(bitmapData, null, false, true);
		graphics.drawTriangles(verticies, indices, uvtData);
		graphics.endFill();
	}

	static public function drawSolidFilledRectWithBounds(graphics:Graphics, x0:Float, y0:Float, x1:Float, y1:Float, rgb:Int = 0x000000, alpha:Float = 1.0):Void {
		var x = x0;
		var y = y0;
		var w = x1 - x0;
		var h = y1 - y0;
		graphics.beginFill(rgb, alpha);
		graphics.drawRect(x, y, w, h);
		graphics.endFill();
	}
}