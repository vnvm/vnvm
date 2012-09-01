package common;
import common.MathEx;
import massive.munit.Assert;

/**
 * ...
 * @author soywiz
 */

class MathExTest 
{
	@Test
	public function fastUintConstDiv16Test():Void {
		var value:Int = 255 * 7 + 100;
		
		Assert.areEqual(7, MathEx.fastUintConstDiv16(value, 255));
	}
}