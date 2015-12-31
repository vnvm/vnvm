import com.vnvm.common.async.EventLoop
import com.vnvm.common.io.openAsync
import com.vnvm.engine.dividead.DL1
import com.vnvm.engine.dividead.LZ
import java.io.File

class Dl1Test {
	@org.junit.Test
	fun testName() {
		EventLoop.runAndWait {
			DL1.loadAsync(File("../assets/dividead/SG.DL1").openAsync()).then {
				it["WAKU_C1.BMP"].readAllAsync().then {
					val compressed = it
					File("temp.bmp.lz").writeBytes(compressed)
					val uncompressed = LZ.decode(it)
					//SG.getImage(it)
					File("temp.bmp").writeBytes(uncompressed)
				}
				it.listAsync().then { list ->
					println(list)
				}

			}
		}
	}
}