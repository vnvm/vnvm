package engines.will;

import promhx.Promise;
interface IScript
{
	function jumpRelative(offset:Int):Void;
	function jumpAbsolute(position:Int):Void;
	function loadAsync(name:String, position:Int = 0):Promise<Dynamic>;
}