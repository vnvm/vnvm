package engines.will;

import promhx.Promise;

interface IScene
{
	function setTransitionMaskAsync(name:String):Promise<Dynamic>;
	function setBackgroundAsync(x:Int, y:Int, index:Int, name:String):Promise<Dynamic>;
}