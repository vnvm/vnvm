package reflash.gl.wgl.util;

class _WGLInstances
{
	private var objects:Map<IWGLObject, Bool>;

	private function new()
	{
		this.objects = new Map<IWGLObject, Bool>();
	}

	static private var instance:_WGLInstances;

	static public function getInstance():_WGLInstances
	{
		if (instance == null) instance = new _WGLInstances();
		return instance;
	}

	public function restore()
	{
		for (object in objects.keys())
		{
			object.__recreate();
		}
	}

	public function add(item:IWGLObject)
	{
		objects.set(item, true);
	}

	public function remove(item:IWGLObject)
	{
		objects.remove(item);
	}
}
