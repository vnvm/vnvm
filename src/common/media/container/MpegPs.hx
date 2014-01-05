package common.media.container;

import flash.utils.ByteArray;
import lang.StringEx;
import haxe.Log;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.Input;

class MpegPsStream extends Input
{
	private var mpegPs:MpegPs;
	private var streamIndex:Int;
	private var buffer:ByteArray;
	private var position:Int = 0;

	public function new(mpegPs:MpegPs, streamIndex:Int)
	{
		this.mpegPs = mpegPs;
		this.streamIndex = streamIndex;
		this.buffer = new ByteArray();
	}

	public function writeBytes(data:ByteArray):Void
	{
		this.buffer.writeBytes(data, 0, data.length);
	}

	private function fill(expected:Int):Void
	{
		while (getAvailable() < expected) this.mpegPs.fillStream(streamIndex);
	}

	public function getAvailable():Int
	{
		return buffer.length - position;
	}

	private function reduce():Void
	{
		if (position >= 0x4000)
		{
			buffer = ByteArrayUtils.sliceByteArray(buffer, position);
			position = 0;
		}
	}

	private function reduceAndFill(expected:Int)
	{
		reduce();
		if (getAvailable() < expected) fill(expected);
	}

	override public function readByte():Int
	{
		reduceAndFill(1);
		return buffer[position++];
	}

	override public function readBytes(s:Bytes, pos:Int, len:Int):Int
	{
		reduceAndFill(len);
		var available = getAvailable();

		if (len > available) len = available;

		for (n in 0 ... len) s.set(pos++, buffer[position++]);
		return len;
	}
}

class MpegPs
{
	private var stream:Input;
	private var streams:Map<Int, MpegPsStream>;

	public function new(stream:Input)
	{
		this.stream = stream;
		this.stream.bigEndian = true;
		this.streams = new Map<Int, MpegPsStream>();
	}

	public function getVideoStream(index:Int):Input
	{
		return getStream(ChunkTypes.ST_VideoFirst + index);
	}

	public function getAudioStream(index:Int):Input
	{
		return getStream(ChunkTypes.ST_AudioFirst + index);
	}

	private function getStream(index:Int):MpegPsStream
	{
		if (!this.streams.exists(index))
		{
			this.streams.set(index, new MpegPsStream(this, index));
		}
		return this.streams.get(index);
	}

	public function fillStream(index:Int):Bool
	{
		while (true)
		{
			var streamPacket = readStreamPacket();
			var data = streamPacket.data.getData();
			var skip:Int = 7;
			/*
			if (data[0] & 0x40)
			{
				skip += 6;
			}
			*/

			getStream(streamPacket.streamIndex).writeBytes(ByteArrayUtils.BytesToByteArray(Bytes.ofData(data.slice(skip))));

			if (streamPacket.streamIndex == index) return true;
		}

		return false;
	}

	public function readStreamPacket():StreamPacket
	{
		while (true)
		{
			var packet = readPacket();

			var types = [StreamType.Video, StreamType.Audio, StreamType.Private];
			var chunks = [
				[ChunkTypes.ST_VideoFirst, ChunkTypes.ST_VideoLast],
				[ChunkTypes.ST_AudioFirst, ChunkTypes.ST_AudioLast],
				[ChunkTypes.ST_PrivateFirst, ChunkTypes.ST_PrivateLast]
			];

			for (n in 0 ... types.length)
			{
				var chunk = chunks[n];
				var streamType = types[n];
				if ((packet.type >= chunk[0]) && (packet.type <= chunk[1]))
				{
					//var streamIndex = packet.type - chunk[0];
					var streamIndex = packet.type;
					return new StreamPacket(streamType, streamIndex, packet.data);
				}
			}
		}
	}

	public function readPacket():Packet
	{
		while (true)
		{
			var packet = _readAnyPacket();
			switch (packet.type)
			{
				case ChunkTypes.Start, ChunkTypes.SystemHeader, ChunkTypes.ST_Padding:
					continue;
			}
			return packet;
		}
	}

	private function _readAnyPacket():Packet
	{
		var chunkType = getNextPacketAndSync();
		return new Packet(chunkType, switch (chunkType)
		{
			case ChunkTypes.Start: stream.read(8);
			case ChunkTypes.SystemHeader: stream.read(14);
			default: stream.read(stream.readUInt16());
		});
	}

	private function getNextPacketAndSync():Int
	{
		var value:Int = 0xFFFFFFFF;
		var byte:Int;
		while ((byte = stream.readByte()) != -1)
		{
			value <<= 8;
			value |= byte;
			if ((value & 0xFFFFFF00) == 0x00000100)
			{
				return value;
			}
		}
		return 0xFFFFFFFF;
	}
}

class StreamPacket
{
	public var streamType(default, null):StreamType;
	public var streamIndex(default, null):Int;
	public var data(default, null):Bytes;

	public function new(streamType:StreamType, streamIndex:Int, data:Bytes)
	{
		this.streamType = streamType;
		this.streamIndex = streamIndex;
		this.data = data;
	}

	public function toString()
	{
		return 'StreamPacket(${streamType}, ${streamIndex}, ${data.length})';
	}
}

class Packet
{
	public var type(default, null):Int;
	public var data(default, null):Bytes;

	public function new(type:Int, data:Bytes)
	{
		this.type = type;
		this.data = data;
	}

	public function toString()
	{
		return 'Packet(${type}, ${data.length})';
	}
}

enum StreamType
{
	Video;
	Audio;
	Private;
	Other;
}

class ChunkTypes
{
	static public var Start            = 0x000001BA;
	static public var SystemHeader     = 0x000001BB;
	static public var ST_PSMapTable    = 0x000001BC;
	static public var ST_PrivateFirst      = 0x000001BD;
	static public var ST_Padding       = 0x000001BE;
	static public var ST_PrivateLast      = 0x000001BF;
	static public var ST_AudioFirst        = 0x000001C0;
	static public var ST_AudioLast        = 0x000001DF;
	static public var ST_VideoFirst        = 0x000001E0;
	static public var ST_VideoLast        = 0x000001EF;
	static public var ST_ECM           = 0x000001F0;
	static public var ST_EMM           = 0x000001F1;
	static public var ST_DSMCC         = 0x000001F2;
	static public var ST_ISO_13522     = 0x000001F3;
	static public var ST_ITUT_A        = 0x000001F4;
	static public var ST_ITUT_B        = 0x000001F5;
	static public var ST_ITUT_C        = 0x000001F6;
	static public var ST_ITUT_D        = 0x000001F7;
	static public var ST_ITUT_E        = 0x000001F8;
	static public var ST_PSDirectory   = 0x000001FF;
	static public var Invalid          = 0xFFFFFFFF;
}