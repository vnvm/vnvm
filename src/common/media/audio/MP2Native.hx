package common.media.audio;

import haxe.io.Input;
import flash.utils.ByteArray;
import haxe.io.BytesData;
import haxe.io.Bytes;
@:cppFileCode('
extern "C" {
	#include "../../../../../../../../extra/kjmp2/kjmp2.c"
	kjmp2_context_t context;
}
')
class MP2Native implements IAudioStream
{
	private var stream:Input;
	private var buffer:BytesData;
	public var sampleRate(default, null):Int = 0;

	public function new(stream:Input)
	{
		this.stream = stream;
		this.buffer = new BytesData();

		init();
	}

	private function init()
	{
		_reset();
	}

	static public function createWithStream(stream:Input):MP2Native
	{
		return new MP2Native(stream);
	}

	private function writeBytes(data:BytesData):Void
	{
		this.buffer = this.buffer.concat(data);
		if (sampleRate == 0 && this.buffer.length >= 3)
		{
			this.sampleRate = _getSampleRate(this.buffer);
		}
	}

	/*


	public function getBytesAvailable():Int
	{
		return this.buffer.length;
	}
	*/

	/*
	private function readBytes(length:Int):BytesData
	{
		var readed = this.buffer.slice(0, length);
		consumeBytes(length);
		return readed;
	}
	*/

	private function consumeBytes(length:Int):Void
	{
		this.buffer = this.buffer.slice(length, this.buffer.length);
	}


	public function decodeFrame():BytesData
	{
		if (this.buffer.length < 1440)
		{
			writeBytes(this.stream.read(1440).getData());
		}

		if (this.buffer.length > 3)
		{
			var data = Bytes.alloc(1152 * 4).getData();
			var decoded = _decodeFrame(this.buffer, data);
			this.consumeBytes(decoded);
			return data;
		}
		else
		{
			return null;
		}
	}

	@:functionCode('kjmp2_init(&context);')
	private function _reset()
	{
	}

	@:functionCode('return kjmp2_get_sample_rate(data->Pointer());')
	private function _getSampleRate(data:BytesData):Int
	{
		return 0;
	}

	@:functionCode('
		int decoded = kjmp2_decode_frame(&context, input->Pointer(), (short *)output->Pointer());
		return decoded;
	')
	private function _decodeFrame(input:BytesData, output:BytesData):Int
	{
		return 0;
	}
}
