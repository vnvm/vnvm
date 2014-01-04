package engines.will;

import flash.display.BitmapData;
import reflash.display.DisplayObject2;
import reflash.gl.wgl.WGLTexture;
import reflash.display.Image2;
import reflash.display.Sprite2;
import flash.geom.Rectangle;
import common.geom.Anchor;
import flash.geom.Point;
import flash.display.Bitmap;
import flash.display.PixelSnapping;
import flash.display.DisplayObject;
import flash.utils.ByteArray;
import engines.will.formats.wip.WIP;
import promhx.Promise;
import flash.display.Sprite;

class GameLayer extends Sprite2
{
	private var layerChilds:Map<Int, DisplayObject2>;
	private var willResourceManager:WillResourceManager;

	public function new(willResourceManager:WillResourceManager, anchor:Anchor)
	{
		super();
		this.willResourceManager = willResourceManager;
		this.layerChilds = new Map<Int, DisplayObject2>();
		var point = anchor.getPointInRect(new Rectangle(0, 0, 800, 600));
		this.x = point.x;
		this.y = point.y;
	}

	public function removeObject(index:Int):Void
	{
		if (this.layerChilds.exists(index))
		{
			this.removeChild(this.layerChilds[index]);
			this.layerChilds.remove(index);
		}
	}

	public function putObjectAsync(index:Int, x:Int, y:Int, name:String, anchor:Anchor):Promise<Dynamic>
	{
		removeObject(index);

		return willResourceManager.getWipWithMaskAsync(name).then(function(wip:WIP)
		{
			//var bitmapData = new BitmapData(800, 600); bitmapData.noise(0);
			var bitmapData = wip.get(0).bitmapData;
			/*
			var sprite = new Sprite2();
			var bitmap = new Image2(WGLTexture.fromBitmapData(bitmapData));
			bitmap.x = -bitmap.width * anchor.sx;
			bitmap.y = -bitmap.height * anchor.sy;
			sprite.addChild(bitmap);
			sprite.x = x;
			sprite.y = y;
			//sprite.zIndex = index;
			this.layerChilds.set(index, sprite);
			addChild(sprite);
			*/
			var sprite = new Image2(WGLTexture.fromBitmapData(bitmapData)).setAnchor(anchor.sx, anchor.sy).setPosition(x, y);
			this.layerChilds.set(index, sprite);
			addChild(sprite);
		});
	}

	public function setObjectPos(index:Int, x:Int, y:Int):GameLayer
	{
		if (this.layerChilds.exists(index))
		{
			var child:DisplayObject2 = this.layerChilds.get(index);
			child.x = x;
			child.y = y;
		}
		return this;
	}

	public function setObjectSizeRotation(index:Int, scale:Float, rotation:Float):GameLayer
	{
		if (this.layerChilds.exists(index))
		{
			var child:DisplayObject2 = this.layerChilds.get(index);
			child.scaleX = scale;
			child.scaleY = scale;
			child.angle = rotation;
		}
		return this;
	}

	public function setLayerViewPort(scale:Float, x:Int, y:Int):GameLayer
	{
		this.scaleX = scale;
		this.scaleY = scale;
		this.x = x;
		this.y = y;
		return this;
	}
}
