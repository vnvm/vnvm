package lang;

class DisposableGroup implements IDisposable
{
	private var list:Array<IDisposable>;
	private var disposed:Bool;

	private function new()
	{
		list = [];
	}

	static public function create():DisposableGroup
	{
		return new DisposableGroup();
	}

	public function add(disposable:IDisposable):DisposableGroup
	{
		if (isDisposed())
		{
			disposable.dispose();
		}
		else
		{
			this.list.push(disposable);
		}

		return this;
	}

	private function isDisposed():Bool
	{
		return list == null;
	}

	public function dispose():Void
	{
		if (isDisposed()) return;

		for (item in list) item.dispose();
		list = null;
	}
}
