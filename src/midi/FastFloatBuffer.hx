package midi;

import haxe.ds.Vector;
class FastFloatBuffer
{
	
	public var length : Int;
	public var length_inv : Float;
	
	public static function fromVector(i : Array<Float>)
	{
		var ffb = new FastFloatBuffer(i.length, i);
		return ffb;
	}

	private var data : Array<Float>;
	public var playhead : Int;
	public var playback_rate : Int;
	
	public function new(size : Int, ?basis : Array<Float>)
	{
		if (basis == null || Std.int(basis.length) != size )
		{
			data = new Array<Float>();
			while (data.length < size) data.push(0.0);
			if (basis != null)
			{
				for (d in 0...data.length)
					data[d] = basis[d % basis.length]; // loop basis when size greater
			}
		}
		else
			data = basis;
		length = size;
		length_inv = 1. / size;
		playhead = 0;
		playback_rate = 1;
	}
	
	public inline function set(i : Int, d : Float)
	{
		data[i] = d;
	}
	
	public inline function get(i : Int)
	{
		return data[i];
	}
	
	public inline function toVector() : Vector<Float>
	{
		return Vector.fromArrayCopy(data);
	}
	
	public inline function advancePlayhead() { playhead = ((playhead + playback_rate) % length); }
	public inline function advancePlayheadUnbounded() { playhead += playback_rate; }
	public inline function windowPlayhead() { playhead = playhead % length; }
	
	public inline function read()
	{ return data[playhead]; }	
	
	public inline function write(d : Float)
	{ data[playhead] = d; }
	
	public inline function add(d : Float)
	{ data[playhead] += d; }
	
}