import com.vnvm.common.async.EventLoop
import com.vnvm.common.io.openAsync
import com.vnvm.common.io.readAllAsync
import com.vnvm.engine.dividead.DL1
import com.vnvm.engine.dividead.LZ
import java.io.File

class Dl1Test {
	@org.junit.Test
	fun testName() {
		DL1.loadAsync(File("../assets/dividead/SG.DL1").openAsync()).then {
			it.readAllAsync("WAKU_C1.BMP").then {
				val compressed = it
				File("temp.bmp.lz").writeBytes(compressed)
				val uncompressed = LZ.decode(it)
				//SG.getImage(it)
				File("temp.bmp").writeBytes(uncompressed)
			}
			println(it.listFiles().toList())
		}
		EventLoop.frame()

	}
}