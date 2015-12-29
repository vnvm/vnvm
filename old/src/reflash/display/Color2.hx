package reflash.display;

class Color2
{
	public var r(default, null):Float;
	public var g(default, null):Float;
	public var b(default, null):Float;
	public var a(default, null):Float;

	private function new(r:Float, g:Float, b:Float, a:Float)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	static public function create(r:Float, g:Float, b:Float, a:Float = 1):Color2
	{
		return new Color2(r, g, b, a);
	}
}
