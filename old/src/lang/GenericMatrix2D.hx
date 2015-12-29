package lang;

import lang.exceptions.OutOfBoundsException;
class GenericMatrix2D<T>
{
	public var width(default,null) : Int;
	public var height(default,null) : Int;
	private var data:Array<T>;

	public function new(width:Int, height:Int)
	{
		this.width = width;
		this.height = height;
		this.data = [for (n in 0 ... width * height) null];
	}

	private function getIndex(x:Int, y:Int):Int
	{
		if (x < 0 || y < 0 || x >= width || y >= height) throw(new OutOfBoundsException());
		return y * width + x;
	}

	public function get(x:Int, y:Int):T
	{
		return data[getIndex(x, y)];
	}

	public function set(x:Int, y:Int, value:T):Void
	{
		data[getIndex(x, y)] = value;
	}
}