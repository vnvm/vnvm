import com.vnvm.common.io.BinBytes
import com.vnvm.io.Struct
import com.vnvm.io.u32b
import org.junit.Assert
import org.junit.Test

class StructTest {
	@Test
	fun testName() {
		val bytes = BinBytes(byteArrayOf(1, 0, 0, 0, 1, 0, 0, 0))
		val struct = Struct.read<u32b>(bytes)
		Assert.assertEquals(1, struct.l)
		Assert.assertEquals(16777216, struct.b)
	}
}