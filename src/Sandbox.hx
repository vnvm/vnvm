package ;

import haxe.Log;
import lang.promise.Promise;
class Sandbox
{
	static public function test()
	{
		Promise.sequence([
			function() { return Promise.waitTimeAsync(1).then(function(e) { Log.trace('step1'); }); },
			function() { return Promise.waitTimeAsync(1).then(function(e) { Log.trace('step2'); }); }
		]).then(function(e) {
			Log.trace('all completed');
		});
	}
}
