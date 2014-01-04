package reflash.gl.wgl;

import lang.ReferenceCounter;
import flash.geom.Rectangle;
import openfl.utils.ArrayBuffer;
import openfl.utils.UInt8Array;
import openfl.utils.ArrayBufferView;
import openfl.gl.GLTexture;
import flash.display.BitmapData;
import openfl.gl.GL;

class WGLTextureBase implements IGLTextureBase
{
	public var textureId(default, null):GLTexture;
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var referenceCounter(default, null):ReferenceCounter;

	private function new(textureId:GLTexture)
	{
		this.textureId = textureId;
		this.referenceCounter = new ReferenceCounter(this);
	}

	public function dispose()
	{
		GL.deleteTexture(textureId);
		this.referenceCounter = null;
	}

	/*
	public function bind():WGLTextureBase
	{
		GL.bindTexture(GL.TEXTURE_2D, textureId);
		return this;
	}
	*/

	public function bindToUnit(unit:Int):IGLTextureBase
	{
		GL.activeTexture(GL.TEXTURE0 + unit);
		GL.bindTexture(GL.TEXTURE_2D, textureId);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		return this;
	}

	public function setEmptyPixels(width:Int, height:Int):IGLTextureBase
	{
		this.width = width;
		this.height = height;
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
		return this;
	}

	@:noStack public function setPixels(bitmapData:BitmapData):IGLTextureBase
	{
		var width = bitmapData.width, height = bitmapData.height;
		//new ArrayBufferView();

		this.width = width;
		this.height = height;

		//var pixels = new UInt8Array(new ArrayBuffer(width*height*4));
		//for(i in 0...width*height*4) pixels[i] = Std.random(256);
		var data = bitmapData.getPixels(bitmapData.rect);
		var src = 0;
		var dst = 0;

		for (n in 0 ... width * height)
		{
			var a = data[src++];
			var r = data[src++];
			var g = data[src++];
			var b = data[src++];

			data[dst++] = r; // r
			data[dst++] = g; // g
			data[dst++] = b; // b
			data[dst++] = a; // a
		}

		var pixels = new UInt8Array(data);
		//var pixels = new UInt8Array(bitmapData.getPixels(new flash.geom.Rectangle(1000, 1000)));

		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, pixels);
		return this;
	}

	static private function create():IGLTextureBase
	{
		return new WGLTextureBase(GL.createTexture());
	}

	static public function createEmpty(width:Int, height:Int):IGLTextureBase
	{
		return create().bindToUnit(0).setEmptyPixels(width, height);
	}

	static public function createWithBitmapData(bitmapData:BitmapData):IGLTextureBase
	{
		return create().bindToUnit(0).setPixels(bitmapData);
	}
}