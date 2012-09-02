package engines.tlove.mrs;
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
	@:nostack
	static public function decode(input:ByteArray, outputSize:Int, debug:Bool = false):ByteArray
	{
		var output:ByteArray = new ByteArray();
		
		//input.position -= 1;
		
		//debug = true;
		
		input.endian = Endian.LITTLE_ENDIAN;
		output.endian = Endian.LITTLE_ENDIAN;
		
		//params.debug = 1;
		
		//if (params.debug) printf("IN(%08X), OUT(%08X) {\n", vsrc.len, vdst.len);
		
		while ((input.position < input.length) && (output.position < outputSize))
		{
			var c:Int = (input.readUnsignedByte() & 0xFF);
			
			//if (output.position >= outputSize) break;
			
			#if debug
			if (debug) Log.trace(StringEx.sprintf("CODE: %02X", [c]));
			#end
		
			// LZ
			if ((c & 0x80) != 0)
			{
				var c2:Int = (input.readUnsignedByte() & 0xFF);
				c &= 0x7F;
				c2 &= 0xFF;
				
				var offset:Int = ((c & 0xF) << 8) | c2;
				var c3:Int = (c >> 4) & 0xF;

				if (c3 != 0) {
					c3 += 2; 
				} else {
					c3 = (input.readUnsignedByte() & 0xFF) + 0x0A;
				}
				
				#if debug
				if (debug) Log.trace(StringEx.sprintf("  %06X | %06X: PATTERN OFFSET(%d) LENGTH(%d)", [output.position, input.position, offset, c3]));
				#end
				
				if (offset > output.length) throw(new Error("Invalid LZ. Require more data."));
				
				while (c3-- > 0) {
					var b:Int = output[output.length - offset - 1];
					#if debug
					//if (debug) Log.trace(StringEx.sprintf("  PATTERN BYTE (%02X)", [b]));
					#end
					//output.writeBytes(output, output.length - offset - 1, 1);
					output.writeByte(b);
				}
			}
			// RLE
			else if ((c & 0x40) != 0)
			{
				c &= 0x3F; // 0b01000000
				if (c == 0) {
					c = (input.readUnsignedByte() & 0xFF) + 0x40;
				} else {
					
				}
				c++;

				//output.position = output.length - 1;
				//var byte:Int = output.readUnsignedByte();
				//Log.trace(Std.format("len:${output.length}"));
				
				if (output.length == 0) throw(new Error("Invalid RLE. Require compressed bytes."));
				
				var byte:Int = (output[output.length - 1] & 0xFF);
				var short:Int = byte | (byte << 8);
				var int:Int = short | (short << 16);

				#if debug
				if (debug) Log.trace(StringEx.sprintf("  %06X | %06X: REPEAT LAST BYTE(%02X) TIMES(%d)", [output.position, input.position, byte, c]));
				#end

				//while (c >= 4) { output.writeInt(int); c -= 4; }
				while (c >= 1) { output.writeByte(byte); c -= 1; }
			}
			// Uncompressed block.
			else
			{
				c &= 0x3F;
				if (c == 0) {
					c = (input.readUnsignedByte() & 0xFF) + 0x40;
				}

				#if debug
				if (debug) Log.trace(StringEx.sprintf("  %06X | %06X: UNCOMPRESSED COUNT(%d)", [output.position, input.position, c]));
				#end

				//while (c >= 4) { output.writeUnsignedInt(input.readUnsignedInt()); c -= 4; }
				while (c >= 1) {
					var b:Int = input.readUnsignedByte() & 0xFF;
					#if debug
					//if (debug) Log.trace(StringEx.sprintf("  %06X | %06X: UNCOMPRESSED(%02X)", [output.position, input.position, b]));
					#end
					output.writeByte(b);
					c -= 1;
				}
			}
			
			//if (output.position >= 1000) break;
		}
		
		output.position = 0;
		
		//if (params.debug) printf("}\n");
		return output;
	}
}