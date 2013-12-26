package common.compression;

import lang.exceptions.NotImplementedException;
import promhx.Promise;
import flash.utils.ByteArray;
import cpp.vm.Thread;
class LzDecoderAsync
{
	static public function decodeAsync(input:ByteArray):Promise<ByteArray>
	{
		throw(new NotImplementedException());
		/*
		var thread = Thread.create(function() {
			var message = Thread.readMessage(true);
			LzDecoder.decode(input, );
		});

		thread.sendMessage(input);
		*/
	}
}