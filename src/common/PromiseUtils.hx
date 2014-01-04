package common;

import promhx.Promise;
class PromiseUtils
{
	static public function create():Promise<Dynamic>
	{
		return new Promise<Dynamic>();
	}

	static public function createResolved():Promise<Dynamic>
	{
		return Promise.promise(null);
	}

	static public function returnPromiseOrResolvedPromise(possiblePromise:Promise<Dynamic>):Promise<Dynamic>
	{
		if (Std.is(possiblePromise, Promise))
		{
			return possiblePromise;
		}
		else
		{
			return Promise.promise(null);
		}
	}
}
