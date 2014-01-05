package lang.promise;

import lang.signal.Signal;

class Deferred<T> implements IDeferred<T>
{
	public var promise(default, null):IPromise<T>;

	private var promiseImpl:PromiseImpl<T>;

	public function new()
	{
		this.promiseImpl = new PromiseImpl<T>();
		this.promise = this.promiseImpl;
	}

	public function resolve(?value:T):Void
	{
		this.promiseImpl.resolve(value);
	}

	public function reject(error:Dynamic):Void
	{
		this.promiseImpl.reject(error);
	}

	public function onCancel(callback:Void -> Void):Void
	{
		this.promiseImpl.onCancel(callback);
	}
}

private class PromiseImpl<T> implements IPromise<T>
{
	private var resolvedValue:T;
	private var rejectedError:Dynamic;
	private var state:State;
	private var listeners:Array<PromiseListener<T>>;

	public function onCancel(callback:Void -> Void):Void
	{
		listeners.push({ cancelCallback: callback });
	}

	public function new()
	{
		this.listeners = [];
		this.state = State.CREATED;
	}

	private function checkNotCreated()
	{
		if (this.state != State.CREATED) throw('Promise already completed');
	}

	public function resolve(?value:T):Void
	{
		if (this.state != State.CREATED) return;
		this.resolvedValue = value;
		this.state = State.RESOLVED;
		this.callPending();
	}

	public function reject(rejectedError:Dynamic):Void
	{
		if (this.state != State.CREATED) return;
		this.rejectedError = rejectedError;
		this.state = State.REJECTED;
		this.callPending();
	}

	public function then<A>(successCallback:T -> A, ?errorCallback:Dynamic -> Void, ?cancelCallback:Void -> Void):IPromise<A>
	{
		var deferred = new Deferred<A>();

		listeners.push({
		successCallback: function(value:T) {
			var result = successCallback(value);
			deferred.resolve(result);
		},
		errorCallback: errorCallback,
		cancelCallback: cancelCallback
		});

		callPending();

		return deferred.promise;
	}

	public function cancel():Void
	{
		if (this.state != State.CREATED) return;
		this.state = State.CANCELLED;
		this.callPending();
	}

	private function callPending()
	{
		if (state == State.CREATED) return;

		while (listeners.length > 0)
		{
			var listener = listeners.shift();

			switch (this.state)
			{
				case State.REJECTED: if (listener.errorCallback != null) listener.errorCallback(rejectedError);
				case State.RESOLVED: if (listener.successCallback != null) listener.successCallback(resolvedValue);
				case State.CANCELLED: {
					if (listener.cancelCallback != null) listener.cancelCallback();
					if (listener.successCallback != null) listener.successCallback(null);
				}
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
	@:optional var cancelCallback:Void -> Void;
	@:optional var anyCallback:Void -> Void;
}

private enum State
{
	CREATED;
	REJECTED;
	RESOLVED;
	CANCELLED;
}
