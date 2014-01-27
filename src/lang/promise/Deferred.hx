package lang.promise;

import lang.signal.Signal;

class Deferred<T> implements IDeferred<T>
{
	public var promise(default, null):IPromise<T>;
	public var onCancel(default, null):Signal<Dynamic>;

	private var promiseImpl:PromiseImpl<T>;

	public function new()
	{
		this.promiseImpl = new PromiseImpl<T>();
		this.promise = this.promiseImpl;
		this.onCancel = this.promiseImpl.onCancel;
	}

	public function resolve(?value:T):Void
	{
		this.promiseImpl.resolve(value);
	}

	public function reject(error:Dynamic):Void
	{
		this.promiseImpl.reject(error);
	}
}

private class PromiseImpl<T> implements IPromise<T>
{
	private var resolvedValue:T;
	private var rejectedError:Dynamic;
	private var state:State;
	private var listeners:Array<PromiseListener<T>>;
	public var onCancel(default, null):Signal<Dynamic>;

	public function new()
	{
		this.listeners = [];
		this.state = State.CREATED;
		this.onCancel = new Signal<Dynamic>();
	}

	private function checkNotCreated()
	{
		if (this.state != State.CREATED) throw('Promise already completed');
	}

	private function isCompleted():Bool
	{
		return this.state != State.CREATED;
	}

	public function resolve(?value:T):Void
	{
		if (isCompleted()) return;
		this.resolvedValue = value;
		this.state = State.RESOLVED;
		this.callPending();
	}

	public function reject(rejectedError:Dynamic):Void
	{
		if (isCompleted()) return;
		this.rejectedError = rejectedError;
		this.state = State.REJECTED;
		this.callPending();
	}

	public function cancel():Void
	{
		if (isCompleted()) return;
		this.onCancel.dispatch(null);
		this.onCancel.dispose();
	}

	public function then<A>(successCallback:T -> A, ?errorCallback:Dynamic -> Void):IPromise<A>
	{
		var deferred = new Deferred<A>();

		listeners.push({
			successCallback: function(value:T) { deferred.resolve(successCallback(value)); },
			errorCallback: errorCallback
		});

		deferred.onCancel.add(function(e) {
			cancel();
		});

		callPending();

		return deferred.promise;
	}

	public function pipe<A>(successCallback:T -> IPromise<A>, ?errorCallback:Dynamic -> Void):IPromise<A>
	{
		var deferred = new Deferred<A>();

		listeners.push({
		successCallback: function(value:T) {
			successCallback(value).then(deferred.resolve, deferred.reject);
		},
		errorCallback: errorCallback
		});

		deferred.onCancel.add(function(e) {
			cancel();
		});

		callPending();

		return deferred.promise;
	}

	private function callPending()
	{
		if (!isCompleted()) return;

		this.onCancel.dispose();

		while (listeners.length > 0)
		{
			var listener = listeners.shift();

			switch (this.state)
			{
				case State.REJECTED: if (listener.errorCallback != null) listener.errorCallback(rejectedError);
				case State.RESOLVED: if (listener.successCallback != null) listener.successCallback(resolvedValue);
				default: throw('Invalid state');
			}
			if (listener.anyCallback != null) listener.anyCallback();
		}
	}
}


private typedef PromiseListener<T> =
{
	@:optional var successCallback:T -> Void;
	@:optional var errorCallback:Dynamic -> Void;
	@:optional var anyCallback:Void -> Void;
}

private enum State
{
	CREATED;
	REJECTED;
	RESOLVED;
}
