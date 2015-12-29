import com.vnvm.common.script.Opcode
import com.vnvm.common.script.ScriptOpcodes
import org.junit.Test

class InstructionTest {
	@Test
	fun testName() {
		class Test {
			@Opcode(id = 10, format = "format", description = "desc")
			fun test() {

			}
		}
		val opcodes = ScriptOpcodes.createWithClass(Test::class.java)
		println(opcodes)
		println(opcodes)
	}
}