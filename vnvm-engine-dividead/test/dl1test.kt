import com.vnvm.common.io.FileAsyncStream
import com.vnvm.common.io.openAsync
import com.vnvm.engine.dividead.DL1
import java.io.File

class Dl1Test {
	@org.junit.Test
	fun testName() {
		DL1.loadAsync(File("test.dl1").openAsync()).then {
			println(it.listFiles().toList())
		}
	}
}