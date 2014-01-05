package lang.signal;

class Signal<T> implements IDisposable
{
	private var slots:Array<Slot<T>>;

	public function new()
	{
	}

	public function add(handler:T -> Void):IDisposable
	{
		if (slots == null) slots = [];
		var slot = new Slot(this, handler);
		slots.push(slot);
		return slot;
	}

	public function __removeSlot(slot: Slot<T>)
	{
		slots.remove(slot);
	}

	public function dispatch(value:T)
	{
		if (slots != null) for (slot in slots) slot.callback(value);
	}

	public function dispose()
	{
		slots = null;
	}
}
