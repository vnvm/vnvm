package common.compression;

import lang.promise.IPromise;
import lang.exceptions.NotImplementedException;
import flash.utils.ByteArray;
import cpp.vm.Thread;
class LzDecoderAsync
{
	static public function decodeAsync(input:ByteArray):IPromise<ByteArray>
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