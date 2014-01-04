package lang;

class DisposableHolder<T: IDisposable>
{
	public var value(default, null):T;

	public function new()
	{
	}

	public function set(value:T):T
	{
		dispose();
		return this.value = value;
	}

	public function dispose():Void
	{
		if (this.value != null)
		{
			this.value.dispose();
			this.value =  null;
		}
	}
}
