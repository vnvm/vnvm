package engines.ethornell;
import common.ByteArrayUtils;
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
		var compressedBG:CompressedBG = new CompressedBG(ByteArrayUtils.BytesToByteArray(File.getBytes("assets/edelweiss/housou_jikoa_n")));
		
		File.saveBytes("c:/temp/lol.png", compressedBG.data.encode('png'));
	}
}