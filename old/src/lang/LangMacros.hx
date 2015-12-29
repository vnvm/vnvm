package lang;

import haxe.macro.Expr;
class LangMacros
{
	//@:macro
	macro
	public static function swap (e1:Expr, e2:Expr):Expr
	{
		return macro {
			var __temp = $e1;
			$e1 = $e2;
			$e2 = __temp;
		};
	}
}
