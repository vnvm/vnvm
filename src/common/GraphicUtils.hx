package common;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.Vector;

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
		#if flash
		graphics.drawTriangles(Vector.ofArray(verticies), Vector.ofArray(indices), Vector.ofArray(uvtData));
		#else
		graphics.drawTriangles(cast verticies, cast indices, cast uvtData);
		#end
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