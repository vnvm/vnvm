package common.media.video;

import flash.display.BitmapData;
import haxe.io.Bytes;
import haxe.io.Input;

@:cppFileCode('
#include "../../../../../../../../extra/mpeg.cpp"
')
class Mpeg1Native
{
	public function new()
	{

	}

	private var imageData:Bytes;
	public var imageBitmapData(default, null):BitmapData;
	private var input:Input;

	public function open(input:Input)
	{
		this.input = input;
		_open(this);
		this.width = get_width();
		this.height = get_height();
		this.size = get_size();
		imageData = Bytes.alloc(size);
		imageBitmapData = new BitmapData(width, height, true, 0xFFFFFFFF);
	}

	public function decodeFrame():Bool
	{
		var result = _decodeFrame(imageData);
		//var result = _decodeFrame(this);
		imageBitmapData.lock();
		imageBitmapData.setPixels(imageBitmapData.rect, ByteArrayUtils.BytesToByteArray(imageData));
		imageBitmapData.unlock(imageBitmapData.rect);
		return result != 0;
	}

	public function __read(len:Int):Bytes
	{
		try {
			return input.read(len);
		} catch (e:Dynamic) {
			return Bytes.alloc(0);
		}
	}

	public var width(default, null):Int;
	public var height(default, null):Int;
	public var size(default, null):Int;

	@:functionCode('return game_mpeg_get_width();')
	private function get_width():Int { return 0; }

	@:functionCode('return game_mpeg_get_height();')
	private function get_height():Int { return 0; }

	@:functionCode('return game_mpeg_get_size();')
	private function get_size():Int { return 0; }


	@:functionCode('
		//load_and_play_file();
		game_mpeg_open(input);
	')
	private function _open(input:Mpeg1Native)
	{
		//new Bytes().getData();

	}

	@:functionCode('
		return game_mpeg_decode_frame(imageData);
	')
	private function _decodeFrame(imageData:Bytes)
	{
		return 0;
	}
}
