package lang.promise;

import lang.signal.Signal;

class Deferred<T> implements IDeferred<T>
{
	private var resolvedValue:T;
	private var rejectedError:Dynamic;
	private var state:State;
	private var listeners:Array<PromiseListener<T>>;
	public var promise(default, null):IPromise<T>;

	public function onCancel(callback:Void -> Void):Void
	{
		listeners.push({ cancelCallback: callback });
	}

	public function new()
	{
		this.promise = new PromiseImpl<T>(this);
		this.listeners = [];
		this.state = State.CREATED;
	}

	private function checkNotCreated()
	{
		if (this.state != State.CREATED) throw('Promise already completed');
	}

	public function resolve(?value:T):Void
	{
		checkNotCreated();
		this.resolvedValue = value;
		this.state = State.RESOLVED;
		this.callPending();
	}

	public function reject(rejectedError:Dynamic):Void
	{
		checkNotCreated();
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
		checkNotCreated();
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
				case State.RESOLVED: if (listener.successCallback != null) {
					listener.successCallback(resolvedValue);
				}
				case State.CANCELLED: if (listener.cancelCallback != null) listener.cancelCallback();
				default: throw('Invalid state');
			}
			if (listener.anyCallback != null) listener.anyCallback();
		}
	}
}

class PromiseImpl<T> implements IPromise<T>
{
	private var deferred:Deferred<T>;

	public function new(deferred:Deferred<T>)
	{
		this.deferred = deferred;
	}

	public function then<A>(successCallback:T -> A, ?errorCallback:Dynamic -> Void, ?cancelCallback:Void -> Void):IPromise<A>
	{
		return this.deferred.then(successCallback, errorCallback, cancelCallback);
	}

	public function cancel():Void
	{
		this.deferred.cancel();
	}
}

typedef PromiseListener<T> =
{
	@:optional var successCallback:T -> Void;
	@:optional var errorCallback:Dynamic -> Void;
	@:optional var cancelCallback:Void -> Void;
	@:optional var anyCallback:Void -> Void;
}

enum State
{
	CREATED;
	REJECTED;
	RESOLVED;
	CANCELLED;
}
