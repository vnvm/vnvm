package common.media.audio;

import flash.utils.Endian;
import haxe.Log;
import haxe.io.Bytes;
import flash.utils.ByteArray;
import flash.events.SampleDataEvent;
import flash.media.Sound;

class AudioStreamSound extends Sound
{
	private var audioStream:IAudioStream;
	private var buffered:ByteArray;

	public function new(audioStream:IAudioStream)
	{
		super();
		this.audioStream = audioStream;
		this.buffered = new ByteArray();

		this.addEventListener(SampleDataEvent.SAMPLE_DATA, generateSound);
	}

	private function generateSound(event:SampleDataEvent)
	{
		var toWrite = 8192 * 2 * 4;

		while (buffered.length < toWrite)
		{
			var frame = this.audioStream.decodeFrame();
			if (frame != null)
			{
				var data = ByteArrayUtils.BytesToByteArray(Bytes.ofData(frame));
				while (data.bytesAvailable > 0)
				{
					buffered.writeFloat(data.readShort() / 32767);
				}
			}
			else
			{
				while (buffered.length < toWrite)
				{
					buffered.writeFloat(0);
				}
			}
		}

		event.data.writeBytes(buffered, 0, toWrite);

		buffered = ByteArrayUtils.sliceByteArray(buffered, toWrite, buffered.length);
	}
}
