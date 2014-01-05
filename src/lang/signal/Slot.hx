package lang.signal;

class Slot<T> implements IDisposable
{
	private var signal:Signal<T>;
	public var callback(default, null):T -> Void;

	public function new(signal:Signal<T>, callback:T -> Void)
	{
		this.signal = signal;
		this.callback = callback;
	}

	public function dispose():Void
	{
		this.signal.__removeSlot(this);
		this.signal = null;
		this.callback = null;
	}
}
