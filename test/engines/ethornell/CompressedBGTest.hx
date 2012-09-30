package engines.ethornell;
import common.ByteUtils;
import engines.ethornell.CompressedBG;
import sys.io.File;

/**
 * ...
 * @author soywiz
 */

class CompressedBGTest 
{
	@Test
	public function testDecode() {
		var compressedBG:CompressedBG = new CompressedBG(ByteUtils.BytesToByteArray(File.getBytes("assets/edelweiss/housou_jikoa_n")));
		
		File.saveBytes("c:/temp/lol.png", compressedBG.data.encode('png'));
	}
}