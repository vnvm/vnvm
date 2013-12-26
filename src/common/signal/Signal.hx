package common.signal;

class Signal<T>
{
	private var handlers:Array<T -> Void>;

	public function new()
	{
		handlers = new Array<T -> Void>();
	}

	public function add(handler:T -> Void):Signal<T>
	{
		handlers.push(handler);
		return this;
	}

	public function dispatch(value:T)
	{
		for (handler in handlers) handler(value);
	}

	public function dispose()
	{
		handlers = null;
	}
}