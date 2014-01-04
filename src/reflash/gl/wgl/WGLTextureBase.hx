package reflash.gl.wgl;

import haxe.Log;
import flash.utils.Endian;
import common.ByteArrayUtils;
import flash.utils.ByteArray;
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
	private var data:ByteArray;
	public var referenceCounter(default, null):ReferenceCounter;

	private function new()
	{
		this.referenceCounter = new ReferenceCounter(this);
		this.__recreate();
	}

	public function dispose()
	{
		if (textureId != null)
		{
			GL.deleteTexture(textureId); WGLCommon.check();
			this.textureId = null;
			this.referenceCounter = null;
		}
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
		__check();
		_bindToUnit(unit);
		return this;
	}

	private function _bindToUnit(unit:Int)
	{
		GL.activeTexture(GL.TEXTURE0 + unit); WGLCommon.check();
		GL.bindTexture(GL.TEXTURE_2D, textureId); WGLCommon.check();
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR); WGLCommon.check();
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR); WGLCommon.check();
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE); WGLCommon.check();
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE); WGLCommon.check();
	}

	private function __recreate()
	{
		this.textureId = GL.createTexture();
		WGLCommon.check();

		if (data != null)
		{
			_setImageData();
		}
		WGLCommon.check();
	}

	private function _setImageData()
	{
		_bindToUnit(0);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, new UInt8Array(data));
	}

	private function __check()
	{
		if (!GL.isTexture(this.textureId))
		{
			__recreate();
		}
	}

	@:noStack public function setRgbaBytes(width:Int, height:Int, data:ByteArray):IGLTextureBase
	{
		this.width = width;
		this.height = height;
		this.data = data;
		this._setImageData();
		return this;
	}


	public function setEmptyPixels(width:Int, height:Int):IGLTextureBase
	{
		return setRgbaBytes(width, height, ByteArrayUtils.newByteArrayWithLength(width * height * 4, Endian.LITTLE_ENDIAN));
	}

	@:noStack public function setPixels(bitmapData:BitmapData):IGLTextureBase
	{
		var width = bitmapData.width, height = bitmapData.height;

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

		return setRgbaBytes(width, height, data);
	}

	static private function create():IGLTextureBase
	{
		return new WGLTextureBase();
	}

	static public function createEmpty(width:Int, height:Int):IGLTextureBase
	{
		return create().setEmptyPixels(width, height);
	}

	static public function createWithBitmapData(bitmapData:BitmapData):IGLTextureBase
	{
		return create().setPixels(bitmapData);
	}
}