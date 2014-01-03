package reflash.wgl;

import flash.geom.Rectangle;
import openfl.utils.ArrayBuffer;
import openfl.utils.UInt8Array;
import openfl.utils.ArrayBufferView;
import openfl.gl.GLTexture;
import flash.display.BitmapData;
import openfl.gl.GL;

class WGLTextureBase implements IGLTexture
{
	public var textureId(default, null):GLTexture;
	public var width(default, null):Int;
	public var height(default, null):Int;

	public function new(textureId:GLTexture)
	{
		this.textureId = textureId;
	}

	public function dispose()
	{
		GL.deleteTexture(textureId);
	}

	public function bind():WGLTextureBase
	{
		GL.bindTexture(GL.TEXTURE_2D, textureId);
		return this;
	}

	public function setEmptyPixels(width:Int, height:Int):WGLTextureBase
	{
		this.width = width;
		this.height = height;
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
		return this;
	}

	public function setPixels(bitmapData:BitmapData):WGLTextureBase
	{
		var width = bitmapData.width, height = bitmapData.height;
		//new ArrayBufferView();

		this.width = width;
		this.height = height;

		//var pixels = new UInt8Array(new ArrayBuffer(width*height*4));
		//for(i in 0...width*height*4) pixels[i] = Std.random(256);
		var pixels = new UInt8Array(bitmapData.getPixels(bitmapData.rect));
		//var pixels = new UInt8Array(bitmapData.getPixels(new flash.geom.Rectangle(1000, 1000)));

		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, pixels);
		return this;
	}

	static public function createEmpty(width:Int, height:Int):WGLTextureBase
	{
		return (new WGLTextureBase(GL.createTexture())).bind().setEmptyPixels(width, height);
	}

	static public function createWithBitmapData(bitmapData:BitmapData):WGLTextureBase
	{
		return (new WGLTextureBase(GL.createTexture())).bind().setPixels(bitmapData);
	}
}