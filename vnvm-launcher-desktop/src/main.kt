import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.backends.lwjgl.LwjglApplication
import com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.Pixmap
import com.badlogic.gdx.graphics.g2d.Gdx2DPixmap
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.g2d.TextureRegion
import com.badlogic.gdx.math.Affine2
import com.badlogic.jglfw.gl.GL
import com.vnvm.common.collection.Stack
import com.vnvm.common.collection.foreach
import com.vnvm.common.image.BitmapData
import com.vnvm.common.view.Image
import com.vnvm.common.view.Views
import com.vnvm.graphics.GraphicsContext
import com.vnvm.graphics.RenderContext
import com.vnvm.graphics.Texture
import com.vnvm.graphics.TextureSlice
import java.nio.ByteBuffer
import kotlin.properties.Delegates

fun main(args: Array<String>) {
	LwjglApplication(GdxApp({ views ->
		val bmp = BitmapData(128, 128)
		val texture = views.graphics.createTexture(bmp)
		bmp.lock {
			foreach(128, 128) { x, y, n ->
				bmp.setPixel32(x, y, 0xFF0000FF.toInt())
			}
		}
		val image = Image(texture)
		image.x = 128.0
		image.scaleX = 2.0
		image.scaleY = 2.0
		image.rotation = 0.1
		views.root.addChild(image)
		//views.root.scaleX = 2.0
		//views.root.scaleY = 2.0
	}), LwjglApplicationConfiguration().apply {
		width = 640;
		height = 480;
		title = "HelloWorld";
	});
}

class LibgdxTexture(
	val data: BitmapData
) : Texture {
	override val width: Int = data.width
	override val height: Int = data.height
	var tex: com.badlogic.gdx.graphics.Texture? = null
	var version = -1

	fun checkVersion() {
		if (version == data.version) return
		version = data.version
		upload(data)
	}

	fun upload(data: BitmapData) {
		val pixelsData = data.getPixels()
		val bb = ByteBuffer.allocateDirect(pixelsData.size)
		bb.put(pixelsData)
		bb.flip()
		val pixmap = Gdx2DPixmap(bb, longArrayOf(0L, data.width.toLong(), data.height.toLong(), Gdx2DPixmap.GDX2D_FORMAT_RGBA8888.toLong()))
		val pixmap2 = Pixmap(pixmap)
		tex?.dispose()
		tex = com.badlogic.gdx.graphics.Texture(pixmap2)
	}

	override fun dispose() {
		tex?.dispose()
		tex = null
	}
}

class LibgdxContext : RenderContext, GraphicsContext {
	val batch = SpriteBatch()

	override fun createTexture(data: BitmapData): TextureSlice = TextureSlice(LibgdxTexture(data))

	private val stack = Stack<Affine2>()
	var affine = Affine2()

	override fun begin() {
		val width = Gdx.graphics.width.toFloat()
		val height = Gdx.graphics.height.toFloat()
		val camera = OrthographicCamera(width, height);
		camera.setToOrtho(true, width, height);

		camera.update();
		batch.projectionMatrix = camera.combined;

		stack.clear()
		affine.idt()
		batch.begin()
	}

	override fun save() {
		stack.push(Affine2(affine))
	}

	override fun restore() {
		affine.set(stack.pop())
	}

	override fun rotate(radians: Double) {
		affine.rotateRad(radians.toFloat())
	}

	override fun translate(x: Double, y: Double) {
		affine.translate(x.toFloat(), y.toFloat())
	}

	override fun scale(sx: Double, sy: Double) {
		affine.scale(sx.toFloat(), sy.toFloat())
	}

	private val texreg = TextureRegion()

	override fun quad(tex: TextureSlice, width: Double, height: Double) {
		val tt = tex.texture as LibgdxTexture
		tt.checkVersion()
		val t = tt.tex!!
		texreg.setRegion(t)
		texreg.setRegion(tex.u1, tex.v1, tex.u2, tex.v2)
		batch.draw(texreg, width.toFloat(), height.toFloat(), affine)
		//batch.draw(t, 0f, 0f)
	}

	override fun end() {
		//batch.flush()
		batch.end()
	}
}

class GdxApp(private val init: (views: Views) -> Unit) : ApplicationListener {
	var views by Delegates.notNull<Views>()
	var context by Delegates.notNull<RenderContext>()
	var texture by Delegates.notNull<com.badlogic.gdx.graphics.Texture>()
	//private var batch: SpriteBatch;
	//private var font: BitmapFont;

	override public fun create(): Unit {

		val context = LibgdxContext()
		this.context = context
		this.views = Views(context)
		init(this.views)
		//texture = com.badlogic.gdx.graphics.Texture("test.png")
		val pixmap = Pixmap(128, 128, Pixmap.Format.RGBA8888)
		pixmap.setColor(Color.BLUE)
		pixmap.fillRectangle(0, 0, 128, 128)
		texture = com.badlogic.gdx.graphics.Texture(pixmap)
	}

	override public fun dispose() {
		//batch.dispose();
		//font.dispose();
	}

	override public fun render(): Unit {
		Gdx.gl.glClearColor(1f, 0f, 1f, 1f);
		Gdx.gl.glClear(GL.GL_COLOR_BUFFER_BIT);

		//batches.begin()
		//batches.draw(texture, 0f, 0f)
		//batches.end()

		views.render(context)
		views.update(20)
	}

	override public fun resize(width: Int, height: Int): Unit {
	}

	override public fun pause() {
	}

	override public fun resume() {
	}
}
