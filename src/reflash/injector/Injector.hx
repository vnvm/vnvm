package reflash.injector;

import haxe.rtti.Meta;
class Injector
{
	public function injectInto(instance:Dynamic):Void
	{
		var _class = Type.getClass(instance);
		var className = Type.getClassName(_class);
		var classFields = Meta.getFields(_class);
		for (fieldName in Reflect.fields(classFields))
		{
			if (Reflect.hasField(Reflect.field(classFields, fieldName), "Inject"))
			{

			}
		}
	}

	public function map(type:Class<Dynamic>):Void
	{
		Type.getClassName(type);
	}
}

