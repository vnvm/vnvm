package common;

/**
 * ...
 * @author soywiz
 */

class Log2 
{
	@:macro public static function tracef( fmt : haxe.macro.Expr.ExprOf<String> ) : haxe.macro.Expr.ExprOf<String> {
		//return macro Log.trace(Std.format(fmt));
	}
}