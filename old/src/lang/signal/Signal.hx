package lang.signal;

class Signal<T> implements IDisposable
{
	private var slots:Array<Slot<T>>;

	public function new()
	{
	}

	static public function addAny(signals:Array<Signal<Dynamic>>, handler:Dynamic -> Void):IDisposable
	{
		var disposableGroup = DisposableGroup.create();
		for (signal in signals) disposableGroup.add(signal.add(handler));
		return disposableGroup;
	}

	static public function addAnyOnce(signals:Array<Signal<Dynamic>>, handler:Dynamic -> Void):IDisposable
	{
		var disposableGroup = DisposableGroup.create();
		function handler2(value) {
			disposableGroup.dispose();
			handler(value);
		};
		for (signal in signals) disposableGroup.add(signal.add(handler2));
		return disposableGroup;
	}

	public function add(handler:T -> Void):IDisposable
	{
		if (slots == null) slots = [];
		var slot = new Slot(this, handler);
		slots.push(slot);
		return slot;
	}

	public function addOnce(handler:T -> Void):IDisposable
	{
		if (slots == null) slots = [];
		var slot:Slot<T> = null;
		slot = new Slot(this, function(value) {
			slot.dispose();
			handler(value);
		});
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
