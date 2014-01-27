package lang.promise;

import lang.signal.Signal;
import flash.errors.Error;

interface IPromise<T>
{
	function then<A>(successCallback:T -> A, ?errorCallback:Dynamic -> Void):IPromise<A>;
	function pipe<A>(successCallback:T -> IPromise<A>, ?errorCallback:Dynamic -> Void):IPromise<A>;
	function cancel():Void;
}
