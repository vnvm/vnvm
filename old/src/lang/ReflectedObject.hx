package lang;

class ReflectedObject
{
	private var object:Dynamic;
	public var fields(get, null):Array<String>;

	private function new(object:Dynamic)
	{
		this.object = object;
	}

	public function set(field:String, value:Dynamic)
	{
		Reflect.setField(object, field, value);
	}

	public function get(field:String):Dynamic
	{
		return Reflect.field(object, field);

	}

	private function get_fields():Array<String>
	{
		return Reflect.fields(object);
	}
}
