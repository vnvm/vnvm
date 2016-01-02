import com.vnvm.common.IPoint
import com.vnvm.common.Point
import com.vnvm.ui.SpatialMenu
import org.junit.Assert
import org.junit.Test

class UiTest {
	@Test
	fun testName() {
		val center = SpatialMenu.Item(Point(0, 0), "center")
		val right = SpatialMenu.Item(Point(1, 0), "right")
		val down = SpatialMenu.Item(Point(0, 1), "down")
		val left = SpatialMenu.Item(Point(-1, 0), "left")
		val up = SpatialMenu.Item(Point(0, -1), "up")
		val items = listOf(center, right, down, left, up)
		Assert.assertEquals(SpatialMenu.moveRight(items, center), right)
		Assert.assertEquals(SpatialMenu.moveLeft(items, center), left)
		Assert.assertEquals(SpatialMenu.moveDown(items, center), down)
		Assert.assertEquals(SpatialMenu.moveUp(items, center), up)
	}

	@Test
	fun testName2() {
		val a = SpatialMenu.Item(Point(0, 0), "a")
		val b = SpatialMenu.Item(Point(1, 0), "b")
		val c = SpatialMenu.Item(Point(2, 0), "c")
		val items = listOf(a, b, c)
		Assert.assertEquals(SpatialMenu.moveRight(items, a), b)
		Assert.assertEquals(SpatialMenu.moveRight(items, b), c)
		Assert.assertEquals(SpatialMenu.moveRight(items, c), c)
	}
}