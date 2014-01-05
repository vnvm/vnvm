package lang.promise;

import haxe.Timer;
import lang.time.Timer2;
class Promise
{
	static public function createDeferred():IDeferred<Dynamic>
	{
		return new Deferred<Dynamic>();
	}

	static public function createResolved<T>(?value:T):IPromise<T>
	{
		var deferred = new Deferred<T>();
		deferred.resolve(value);
		return deferred.promise;
	}

	static public function returnPromiseOrResolvedPromise(possiblePromise:IPromise<Dynamic>):IPromise<Dynamic>
	{
		if (Std.is(possiblePromise, IPromise))
		{
			return possiblePromise;
		}
		else
		{
			return createResolved();
		}
	}

	static public function sequence(promises:Array<Void -> IPromise<Dynamic>>):IPromise<Dynamic>
	{
		var deferred = new Deferred<Dynamic>();
		var list = promises.slice(0);
		function step()
		{
			if (list.length == 0) {
				deferred.resolve(null);
			} else {
				var promiseGenerator = list.shift();
				promiseGenerator().then(function(e) { step(); }, function(e) { step(); }, step);
			}
		}
		step();
		return deferred.promise;
	}

	static public function whenAll(promises:Array<IPromise<Dynamic>>):IPromise<Dynamic>
	{
		var deferred = new Deferred<Dynamic>();
		var count = promises.length;
		function step() {
			count--;
			if (count <= 0)
			{
				deferred.resolve(null);
			}
		}

		for (promise in promises) promise.then(function(e) { step(); }, function(e) { step(); }, step);
		return deferred.promise;
	}
}
