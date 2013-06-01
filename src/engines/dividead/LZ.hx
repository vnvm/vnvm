package engines.dividead;
import common.compression.RingBuffer;
import haxe.io.Bytes;
import haxe.Log;
import flash.utils.ByteArray;

class LZ
{
	static public function decode(data:ByteArray):ByteArray
	{
		var magic:String = data.readUTFBytes(2);
		var compressedSize:Int = data.readInt();
		var uncompressedSize:Int = data.readInt();

		if (magic != "LZ") throw("Invalid LZ stream");
		
		return _decode(data);
	}
	
	@:noStack static private function _decode(input:ByteArray):ByteArray {
		var output:ByteArray = new ByteArray();
		var ring:RingBuffer = new RingBuffer(0x1000, 0xFEE);

		//Log.trace("[1]");
		while (input.position < input.length) {
			var code:Int = (input.readUnsignedByte() & 0xFF) | 0x100;
			
			//Log.trace(Std.format("[2] $code"));
			
			while (code != 1) {
				//Log.trace("[3]");
				
				// Uncompressed
				if ((code & 1) != 0) {
					var byte:Int = input.readUnsignedByte();
					output.writeByte(byte);
					ring.write(byte);
				}
				// Compressed
				else {
					if (input.position >= input.length) break;

					var l:Int = input.readUnsignedByte();
					var h:Int = input.readUnsignedByte();
					
					var d:Int = l | (h << 8);
					var p:Int = (d & 0xFF) | ((d >> 4) & 0xF00);
					var s:Int = ((d >> 8) & 0xF) + 3;
					ring.readPosition = p;
					for (n in 0 ... s) {
						var byte:Int = ring.read();
						output.writeByte(byte);
						ring.write(byte);
					}
				}

				code >>= 1;
			}
		}

		//Log.trace(Std.format("compressed: ${input.position},${input.length}, uncompressed: ${output.position},${output.length}"));

		input.position = 0;
		output.position = 0;

		return output;
	}
}
