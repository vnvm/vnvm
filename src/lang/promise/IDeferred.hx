package lang.promise;

import lang.signal.Signal;
import flash.errors.Error;

interface IDeferred<T>
{
	function resolve(?value:T):Void;
	function reject(error:Dynamic):Void;
	function onCancel(callback:Void -> Void):Void;
	var promise(default, null):IPromise<T>;
}
