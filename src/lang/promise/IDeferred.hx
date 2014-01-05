package lang.promise;

import lang.signal.Signal;
import flash.errors.Error;

interface IDeferred<T>
{
	function resolve(?value:T):Void;
	function reject(error:Dynamic):Void;
	var onCancel(default, null):Signal<Dynamic>;
	var promise(default, null):IPromise<T>;
}
