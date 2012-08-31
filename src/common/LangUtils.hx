package common;
import nme.errors.Error;

/**
 * ...
 * @author soywiz
 */

class LangUtils 
{
	static public function tryFinally(action:Void -> Void, finally:Void -> Void) {
		try {
			action();
			finally();
		} catch (e:Error) {
			finally();
			throw(e);
		}
	}
}