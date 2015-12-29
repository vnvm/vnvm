package lang;

class ReferenceCounter
{
	private var disposable:IDisposable;
	private var referenceCount:Int;

	public function new(disposable:IDisposable)
	{
		this.disposable = disposable;
		this.referenceCount = 0;
	}

	public function increment():Void
	{
		this.referenceCount++;
	}

	public function decrement():Void
	{
		this.referenceCount--;
		if (this.referenceCount <= 0)
		{
			disposable.dispose();
			disposable = null;
		}
	}
}
