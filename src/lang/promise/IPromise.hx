package lang.promise;

import lang.signal.Signal;
import flash.errors.Error;

interface IPromise<T>
{
	function then<A>(successCallback:T -> A, ?errorCallback:Dynamic -> Void, ?cancelCallback:Void -> Void):IPromise<A>;
	function cancel():Void;
}
