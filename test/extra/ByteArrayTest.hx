package extra;
import massive.munit.Assert;
import nme.utils.ByteArray;
import nme.utils.Endian;

/**
 * ...
 * @author soywiz
 */

class ByteArrayTest 
{

	@Test
	public function testWritePos() 
	{
		var ba:ByteArray = new ByteArray();
		
		ba.endian = Endian.LITTLE_ENDIAN;
		
		Assert.areEqual(0, ba.length);
		
		ba.writeByte(0xFF);
		Assert.areEqual(1, ba.length);
		Assert.areEqual(1, ba.position);
		Assert.areEqual(0xFF, ba[0]);

		ba.position = 0;
		Assert.areEqual(0, ba.position);
		ba.writeByte(0x7F);
		Assert.areEqual(1, ba.length);
		Assert.areEqual(1, ba.position);
		Assert.areEqual(0x7F, ba[0]);
		
		ba.writeShort(0x1234);
		Assert.areEqual(3, ba.length);
		Assert.areEqual(3, ba.position);
		Assert.areEqual(0x34, ba[1]);
		Assert.areEqual(0x12, ba[2]);
		
		ba.clear();
		Assert.areEqual(0, ba.length);
		
		ba.writeUTFBytes("TEST");
		Assert.areEqual(4, ba.length);
		Assert.areEqual(4, ba.position);

		ba.writeInt(0x12345678);
		Assert.areEqual(8, ba.length);
		Assert.areEqual(8, ba.position);

		ba.writeShort(0x1234);
		Assert.areEqual(10, ba.length);
		Assert.areEqual(10, ba.position);
		
		ba.position = 3;
		Assert.areEqual(10, ba.length);
		ba.writeShort(0x1234);
		Assert.areEqual(10, ba.length);
		Assert.areEqual(5, ba.position);
	}
	
}