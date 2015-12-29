package engines.will;

import lang.promise.IPromise;
interface IScript
{
	function jumpRelative(offset:Int):Void;
	function jumpAbsolute(position:Int):Void;
	function loadAsync(name:String, position:Int = 0):IPromise<Dynamic>;
	function scriptCallAsync(name:String, position:Int = 0):IPromise<Dynamic>;
	function scriptReturnAsync():IPromise<Dynamic>;
}