package engines.will.display;

import reflash.display.Color2;
import reflash.display.Quad2;
import lang.promise.IPromise;
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
import flash.display.Sprite;

class GameElementsLayer extends Sprite2 implements IGameElementsLayer
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

	public function getObject(index:Int):DisplayObject2
	{
		return this.layerChilds.get(index);
	}

	public function putColor(index:Int, x:Int, y:Int, width:Int, height:Int, color:Color2, anchor:Anchor):Void
	{
		removeObject(index);
		var sprite = new Quad2(width, height, color).setAnchor(anchor.sx, anchor.sy).setPosition(x, y).setZIndex(index);
		this.layerChilds.set(index, sprite);
		addChild(sprite);
	}

	public function putObjectAsync(index:Int, x:Int, y:Int, name:String, anchor:Anchor):IPromise<Dynamic>
	{
		removeObject(index);

		return willResourceManager.getWipWithMaskAsync(name).then(function(wip:WIP)
		{
			var bitmapData = wip.get(0).bitmapData;
			var sprite = new Image2(WGLTexture.fromBitmapData(bitmapData)).setAnchor(anchor.sx, anchor.sy).setPosition(x, y).setZIndex(index);
			this.layerChilds.set(index, sprite);
			addChild(sprite);
		});
	}

	public function setObjectPos(index:Int, x:Int, y:Int):GameElementsLayer
	{
		if (this.layerChilds.exists(index))
		{
			var child:DisplayObject2 = this.layerChilds.get(index);
			child.x = x;
			child.y = y;
		}
		return this;
	}

	public function setObjectSizeRotation(index:Int, scale:Float, rotation:Float):GameElementsLayer
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

	public function setLayerViewPort(scale:Float, x:Int, y:Int):GameElementsLayer
	{
		this.scaleX = scale;
		this.scaleY = scale;
		this.x = 800 - x;
		this.y = 600 - y;
		return this;
	}
}
