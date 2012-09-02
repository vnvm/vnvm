package engines.tlove.mrs;
import nme.errors.Error;
import nme.utils.ByteArray;
import nme.utils.Endian;

/**
 * ...
 * @author soywiz
 */

/*struct ANI
{
	struct FRAME
	{
		ubyte x8;
		ubyte y;
		ubyte time;
	}
	ubyte magic; // 01
	ubyte ani_count;
	ubyte[10] pad;
	ushort x;
	ushort y;
	ushort w8;
	ushort h;
	FRAME[36] frames;
}*/

class ANI
{
	public var magic:Int = 1;
	public var x:Int = 0;
	public var y:Int = 0;
	public var w:Int = 0;
	public var h:Int = 0;
	public var frames:Array<ANI_FRAME>;
	public var mrs:MRS = null;
	public var totalTime:Int = 0;
	
	/*
	function getImageFrame(n)
	{
		return this.mrs.image.slice(frames[n].x, frames[n].y, w, w);
	}

	function getIndexByTime(time)
	{
		local time = (time % total_time);
		local ctime = 0;
		foreach (n, frame in frames) {
			ctime += frame.t;
			if (time < ctime) {
				//printf("%d|%d\n", ctime, time);
				//printf("%d\n", n);
				return n;
			}
		}
		return 0;
	}

	constructor(mrs, s)
	{
		if (magic != 1) throw("Invalid frame");

	}
	*/
	
	public function new(mrs:MRS, s:ByteArray) {
		this.mrs = mrs;
		this.magic = s.readUnsignedByte();
		
		if (magic != 1) throw(new Error("Invalid image frame"));
		
		var count:Int = s.readUnsignedByte();
		s.endian = Endian.BIG_ENDIAN;
		s.position += 0xC;
		this.x = s.readUnsignedShort();
		this.y = s.readUnsignedShort();
		this.w = s.readUnsignedShort() * 8;
		this.h = s.readUnsignedShort();
		this.frames = [];
		this.totalTime = 0;
		
		//printf("ANIMATION(%d,%d)-(%d,%d)\n", x, y, w, h);
		
		for (n in 0 ... count)
		{
			var frame = new ANI_FRAME(s);
			this.frames.push(frame);
			this.totalTime += frame.t;
		}
		
		s.endian = Endian.LITTLE_ENDIAN;
	}
}
