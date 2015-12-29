package common;
import lang.MathEx;
import massive.munit.Assert;

/**
 * ...
 * @author soywiz
 */

class MathExTest 
{
	@Test
	public function fastUintConstDivShortTest():Void {
		var value:Int = 255 * 7 + 100;
		
		Assert.areEqual(7, MathEx.fastUintConstDivShort(value, 255));
	}
}