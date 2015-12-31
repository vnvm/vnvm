import com.vnvm.common.async.EventLoop
import com.vnvm.common.io.FileAsyncStream
import com.vnvm.common.io.root
import com.vnvm.io.IsoFile
import org.junit.Test
import java.io.File

class IsoTest {
	@Test
	fun testName() {
		EventLoop.runAndWait {
			val path = IsoTest::class.java.getResource("hello.iso").path
			val asyncStream = FileAsyncStream(File(path))
			IsoFile.openAsync(asyncStream).then { vfs ->
				vfs["hello.txt"].readAllAsync().then {
					println(it.toString("UTF-8"))
				}
				vfs.listAsync().then {
					println(it)
				}
			}
		}
	}
}