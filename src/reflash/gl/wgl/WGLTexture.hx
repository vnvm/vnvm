package reflash.gl.wgl;

import flash.geom.Rectangle;
import haxe.Log;
import reflash.display.IDrawable;
import lang.IDisposable;
import flash.display.BitmapData;

class WGLTexture implements IGLTexture
	//implements IDrawable
{
	public var textureBase(default, null):IGLTextureBase;
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var width(default, null):Int;
	public var height(default, null):Int;

	private var rectangle:Rectangle;

	public var px1(default, null):Float;
	public var py1(default, null):Float;
	public var px2(default, null):Float;
	public var py2(default, null):Float;

	private function new(textureBase:IGLTextureBase, rectangle:Rectangle)
	{
		textureBase.referenceCounter.increment();
		this.textureBase = textureBase;

		this.rectangle = rectangle;

		this.x = Std.int(rectangle.x);
		this.y = Std.int(rectangle.y);
		this.width = Std.int(rectangle.width);
		this.height = Std.int(rectangle.height);

		this.px1 = (this.x) / textureBase.width;
		this.py1 = (this.y) / textureBase.height;
		this.px2 = (this.x + this.width) / textureBase.width;
		this.py2 = (this.y + this.height) / textureBase.height;
		/*
		this.px1 = (this.x);
		this.py1 = (this.y);
		this.px2 = (this.x + this.width);
		this.py2 = (this.y + this.height);
		*/
	}

	public function dispose()
	{
		if (textureBase != null)
		{
			textureBase.referenceCounter.decrement();
			textureBase = null;
		}
	}

	public function slice(x:Int, y:Int, width:Int, height:Int):IGLTexture
	{
		var newRect = new Rectangle(this.x + x, this.y + y, width, height);
		var intersectedRectangle = newRect.intersection(this.rectangle);

		//Log.trace('$this, $newRect, $intersectedRectangle');

		return new WGLTexture(this.textureBase, intersectedRectangle);
	}

	public function split(width:Int, height:Int):Array<IGLTexture>
	{
		var list:Array<IGLTexture> = [];
		for (x in 0 ... Math.floor(this.width / width))
		{
			for (y in 0 ... Math.floor(this.height / height))
			{
				list.push(slice(x * width, y * height, width, height));
			}
		}
		return list;
	}

	static public function fromTextureBase(textureBase:IGLTextureBase, width:Int, height:Int):IGLTexture
	{
		return new WGLTexture(textureBase, new Rectangle(0, 0, width, height));
	}

	static public function fromEmpty(width:Int, height:Int):IGLTexture
	{
		return fromTextureBase(WGLTextureBase.createEmpty(width, height), width, height);
	}

	static public function fromBitmapData(bitmapData:BitmapData):IGLTexture
	{
		return fromTextureBase(WGLTextureBase.createWithBitmapData(bitmapData), bitmapData.width, bitmapData.height);
	}

	/*
	public function drawElement(drawContext:DrawContext):Void
	{
		new Image2(drawContext).setAnchor(0, 0).setPosition(0, 0).drawElement(drawContext);
	}
	*/

	public function toString():String
	{
		return 'WGLTexture($textureBase, ($x, $y, $width, $height))';
	}
}
