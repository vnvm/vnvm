package midi;
import midi.ExtendedByteArray;
import flash.utils.ByteArray;
import haxe.ds.Vector;
import midi.WAV;
import haxe.io.BytesInput;

class Codec
{
	
	public static function WAV(wav : WAVEHeader, data : ByteArray, data_chk : FourByteChunk) : Array<Array<Float>>
	{
		data.position = data_chk.position;
		
		// this is actually assuming PCM data right now. Hmm.
		
		var vec = new Array<Float>();
		var vec_right = new Array<Float>();
		if (wav.channels != 2)
			vec_right = vec;
		
		if (wav.bitsPerSample == 32)
		{
			var size = 1./Math.pow(2, 32);
			var samples = Std.int(data_chk.len / 4);
			if (wav.channels == 2)
			{
				for (n in 0...samples>>1)
				{
					vec.push(data.readInt()*size);
					vec_right.push(data.readInt()*size);
				}
			}
			else
			{
				for (n in 0...samples)
				{
					vec.push(data.readInt()*size);
				}
			}
		}
		else if (wav.bitsPerSample == 16)
		{
			var size = 1./Math.pow(2, 16);
			var samples = Std.int(data_chk.len/2);
			if (wav.channels == 2)
			{
				for (n in 0...samples>>1)
				{
					vec.push(data.readShort()*size);
					vec_right.push(data.readShort()*size);
				}
			}
			else
			{
				for (n in 0...samples)
				{
					vec.push(data.readShort()*size);
				}
			}
		}
		else if (wav.bitsPerSample == 8)
		{
			var size = 1./Math.pow(2, 8);
			var samples = Std.int(data_chk.len);
			if (wav.channels == 2)
			{
				for (n in 0...samples>>1)
				{
					vec.push(data.readByte()*size);
					vec_right.push(data.readByte()*size);
				}
			}
			else
			{
				for (n in 0...samples)
				{
					vec.push(data.readByte()*size);
				}
			}
		}
		else throw wav.bitsPerSample + " bits per sample? really?";
		
		return [vec, vec_right];
	}
	
	
}