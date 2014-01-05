package engines.brave.script;

/**
 * ...
 * @author 
 */

import lang.promise.IPromise;
interface IScriptThread
{
	function executeAsync():IPromise<Dynamic>;
	function getSpecial(index:Int):Dynamic;
	function getVariable(index:Int):Variable;
}