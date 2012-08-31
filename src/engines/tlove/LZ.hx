package engines.tlove;
import common.StringEx;
import haxe.Log;
import nme.errors.Error;
import nme.utils.ByteArray;
import nme.utils.Endian;

/**
 * ...
 * @author soywiz
 */

class LZ 
{
	static public function decode(input:ByteArray):ByteArray
	{
		var output:ByteArray = new ByteArray();
		
		input.endian = Endian.LITTLE_ENDIAN;
		output.endian = Endian.LITTLE_ENDIAN;
		
		//params.debug = 1;
		
		//if (params.debug) printf("IN(%08X), OUT(%08X) {\n", vsrc.len, vdst.len);
		
		while (input.position < input.length)
		{
			var c:Int = (input.readUnsignedByte() & 0xFF);
			
			//Log.trace(StringEx.sprintf("CODE: %02X\n", [c]));
		
			// LZ
			if ((c & 0x80) != 0)
			{
				c &= ~0x80; // 0b10000000;
				var offset:Int = ((c & 0xF) << 8) | (input.readUnsignedByte() & 0xFF);
				c = (c >> 4) & 0xF;

				if (c != 0) {
					c += 2; 
				} else {
					c = (input.readUnsignedByte() & 0xFF) + 0x0A;
				}
				
				//if (params.debug) printf("  %06X | %06X: PATTERN OFFSET(%d) LENGTH(%d)\n", dst - vdst.data, src - vsrc.data, offset, c);
				
				if (offset > output.length) throw(new Error("Invalid LZ. Require more data."));
				
				while (c-- > 0) {
					//output.writeBytes(output, output.length - offset - 1, 1);
					output.writeByte(output[output.length - offset - 1]);
				}
			}
			// RLE
			else if ((c & 0x40) != 0)
			{
				c &= ~0x40; // 0b01000000
				if (c == 0) c = (input.readUnsignedByte() & 0xFF) + 0x40;
				c++;

				//if (params.debug) printf("  %06X | %06X: REPEAT LAST BYTE(%02X) TIMES(%d)\n", dst - vdst.data, src - vsrc.data, dst[-1], c);

				//output.position = output.length - 1;
				//var byte:Int = output.readUnsignedByte();
				//Log.trace(Std.format("len:${output.length}"));
				
				if (output.length == 0) throw(new Error("Invalid RLE. Require compressed bytes."));
				
				var byte:Int = (output[output.length - 1] & 0xFF);
				var short:Int = byte | (byte << 8);
				var int:Int = short | (short << 16);
				while (c >= 4) { output.writeInt(int); c -= 4; }
				while (c >= 1) { output.writeByte(byte); c -= 1; }
			}
			// Uncompressed block.
			else
			{
				if (c == 0) c = (input.readUnsignedByte() & 0xFF) + 0x40;

				
				while (c >= 4) { output.writeUnsignedInt(input.readUnsignedInt()); c -= 4; }
				while (c >= 1) { output.writeByte(input.readUnsignedByte()); c -= 1; }
			}
		}
		
		output.position = 0;
		
		//if (params.debug) printf("}\n");
		return output;
	}
}