package lang;

class DisposableList implements IDisposable
{
	private var list:Array<IDisposable> = null;

	private function new()
	{
	}

	static public function create():DisposableList
	{
		return new DisposableList();
	}

	public function add(disposable:IDisposable):DisposableList
	{
		if (this.list == null) this.list = [];
		this.list.push(disposable);
	}

	public function dispose():Void
	{
		if (list != null)
		{
			for (item in list) item.dispose();
			list = null;
		}
	}
}
