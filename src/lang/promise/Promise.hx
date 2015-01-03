package lang.promise;

import lang.signal.Signal;
class Promise {
    static public function createDeferred():IDeferred<Dynamic> {
        return new Deferred<Dynamic>();
    }

    static public function fromSignalOnce<T>(signal:Signal<T>):IPromise<T> {
        var deferred = new Deferred<T>();
        signal.addOnce(function(value:T) {
            deferred.resolve(value);
        });
        return deferred.promise;
    }

    static public function fromAnySignalOnce<T>(signals:Array<Signal<Dynamic>>):IPromise<T> {
        var deferred = new Deferred<T>();
        Signal.addAnyOnce(signals, function(value:T) {
            deferred.resolve(value);
        });
        return deferred.promise;
    }

    static public function createResolved<T>(?value:T):IPromise<T> {
        var deferred = new Deferred<T>();
        deferred.resolve(value);
        return deferred.promise;
    }

    static public function returnPromiseOrResolvedPromise(possiblePromise:IPromise<Dynamic>):IPromise<Dynamic> {
        if (Std.is(possiblePromise, IPromise)) {
            return possiblePromise;
        }
        else {
            return createResolved();
        }
    }

    static public function sequence(promiseGeneratorList:Array<Void -> IPromise<Dynamic>>):IPromise<Dynamic> {
        var deferred = new Deferred<Dynamic>();
        var list = promiseGeneratorList.slice(0);
        function step() {
            if (list.length == 0) {
                deferred.resolve(null);
            } else {
                var promiseGenerator = list.shift();
                promiseGenerator().then(function(e) { step(); }, function(e) { step(); });
            }
        }
        step();
        return deferred.promise;
    }

    static public function parallel(promiseGeneratorList:Array<Void -> IPromise<Dynamic>>):IPromise<Dynamic> {
        return whenAll(Lambda.array(Lambda.map(promiseGeneratorList, function(promiseGenerator) { return promiseGenerator(); })));
    }

    static public function whenAll(promises:Array<IPromise<Dynamic>>):IPromise<Array<Dynamic>> {
        var deferred = new Deferred<Array<Dynamic>>();
        var count = promises.length;
        var results:Array<Dynamic> = [for (n in 0 ... promises.length) null];

        function step(index:Int, e:Dynamic) {
            results[index] = e;
            count--;
            if (count <= 0) {
                deferred.resolve(results);
            }
        }

        Lambda.foreach([for (index in 0 ... promises.length) index], function(index) {
            promises[index].then(function(e) {
                step(index, e);
            }, function(e) {
                step(index, e);
            });
            return true;
        });

        return deferred.promise;
    }

    static public function unresolved():IPromise<Dynamic> {
        return Promise.createDeferred().promise;
    }
}
