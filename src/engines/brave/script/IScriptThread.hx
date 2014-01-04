package engines.brave.script;

/**
 * ...
 * @author 
 */

import promhx.Promise;
interface IScriptThread
{
	function executeAsync():Promise<Dynamic>;
	function getSpecial(index:Int):Dynamic;
	function getVariable(index:Int):Variable;
}