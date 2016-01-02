import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.Files
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.InputProcessor
import com.badlogic.gdx.backends.lwjgl.LwjglApplication
import com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration
import com.badlogic.gdx.files.FileHandle
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.Pixmap
import com.badlogic.gdx.graphics.g2d.Gdx2DPixmap
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.g2d.TextureRegion
import com.badlogic.gdx.math.Affine2
import com.badlogic.jglfw.gl.GL
import com.vnvm.common.async.Signal
import com.vnvm.common.collection.Stack
import com.vnvm.common.error.ignoreerror
import com.vnvm.common.image.BitmapData
import com.vnvm.common.image.Color
import com.vnvm.common.image.Colors
import com.vnvm.common.view.Views
import com.vnvm.engine.dividead.DivideadEngine
import com.vnvm.graphics.*
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.properties.Delegates

fun main(args: Array<String>) {
	val app = GdxApp { views ->
		DivideadEngine.start(views)
	}

	LwjglApplication(app, LwjglApplicationConfiguration().apply {
		width = 640
		height = 480
		title = "VNVM"
		ignoreerror { addIcon("logo128.png", Files.FileType.Internal) }
	})
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
		val pixelsData = data.getPixels(flipY = false)
		//val pixelsData = data.getPixels(flipY = true)
		val bb = ByteBuffer.allocateDirect(pixelsData.size * 4)
		bb.order(ByteOrder.LITTLE_ENDIAN)
		for (n in 0 until pixelsData.size) {
			bb.putInt(n shl 2, pixelsData[n])

		}
		//bb.flip()
		val pixmap = Gdx2DPixmap(bb, longArrayOf(0L, data.width.toLong(), data.height.toLong(), Gdx2DPixmap.GDX2D_FORMAT_RGBA8888.toLong()))
		val pixmap2 = Pixmap(pixmap)
		tex?.dispose()

		//println("upload texture")

		/*
		val pixmap2 = Pixmap(data.width, data.height, Pixmap.Format.RGBA8888)
		foreach(data.width, data.height) { x, y, n ->
			pixmap2.drawPixel(x, y, Integer.reverseBytes(data.getPixel32(x, y)))
		}
		*/
		tex = com.badlogic.gdx.graphics.Texture(pixmap2, Pixmap.Format.RGBA8888, false)
		tex!!.setFilter(
			com.badlogic.gdx.graphics.Texture.TextureFilter.Linear,
			com.badlogic.gdx.graphics.Texture.TextureFilter.Linear
		)
	}

	override fun dispose() {
		tex?.dispose()
		tex = null
	}
}

class SoundWrapper(val native: com.badlogic.gdx.audio.Sound) : Sound {
}

class MusicWrapper(val native: com.badlogic.gdx.audio.Music) : Music {
}

class LibgdxContext : RenderContext, GraphicsContext, InputContext, WindowContext, AudioContext {
	override fun getSound(data: ByteArray, offset: Int, size: Int): Sound {
		val file = FileHandle.tempDirectory("vnvm").child("1.wav")
		file.writeBytes(data, offset, size, false)
		return try {
			SoundWrapper(Gdx.audio.newSound(file))
		} catch (e: Throwable) {
			e.printStackTrace()
			DummySoundMusic
		}
	}

	override fun getMusic(data: ByteArray, offset: Int, size: Int): Music {
		val file = FileHandle.tempDirectory("vnvm").child("1.mid")
		file.writeBytes(data, offset, size, false)
		return try {
			MusicWrapper(Gdx.audio.newMusic(file))
		} catch (e: Throwable) {
			e.printStackTrace()
			DummySoundMusic
		}
	}

	override fun play(sound: Sound) {
		(sound as? SoundWrapper)?.native?.play()
	}

	override fun play(sound: Music) {
		(sound as? MusicWrapper)?.native?.play()
	}

	override fun stop(sound: Sound) {
		(sound as? SoundWrapper)?.native?.stop()
		(sound as? SoundWrapper)?.native?.dispose()
	}

	override fun stop(sound: Music) {
		(sound as? MusicWrapper)?.native?.stop()
		(sound as? MusicWrapper)?.native?.dispose()
	}

	override var title: String
		get() = throw UnsupportedOperationException()
		set(value) {
			Gdx.graphics.setTitle(value)
		}
	override val onEvent = Signal<Event>()

	val batch = SpriteBatch()
	override fun createTexture(data: BitmapData): TextureSlice = TextureSlice(LibgdxTexture(data))

	private val stack = Stack<Affine2>()
	var affine = Affine2()

	override fun begin() {
		if (DEBUG) println("--------------")
		val width = Gdx.graphics.width.toFloat()
		val height = Gdx.graphics.height.toFloat()
		val camera = OrthographicCamera(width, height);
		camera.setToOrtho(true, width, height);
		//camera.setToOrtho(false, width, height);

		camera.update()
		batch.projectionMatrix = camera.combined;

		stack.clear()
		affine.idt()
		batch.begin()
	}

	//val DEBUG = true
	val DEBUG = false

	override fun save() {
		if (DEBUG) println("save")
		stack.push(Affine2(affine))
	}

	override fun restore() {
		if (DEBUG) println("restore")
		affine.set(stack.pop())
	}

	override fun rotate(radians: Double) {
		if (DEBUG) println("rotate: $radians")
		affine.rotateRad(radians.toFloat())
	}

	override fun translate(x: Double, y: Double) {
		if (DEBUG) println("translate: $x, $y")
		affine.translate(x.toFloat(), y.toFloat())
	}

	override fun scale(sx: Double, sy: Double) {
		if (DEBUG) println("scale: $sx, $sy")
		affine.scale(sx.toFloat(), sy.toFloat())
	}

	private val texreg = TextureRegion()

	var _color = Colors.WHITE
	override var color: Color
		get() = _color
		set(value) {
			_color = value
			batch.setColor(color.rf, color.gf, color.bf, color.af)
		}

	val tempAffine = Affine2()
	override fun quad(tex: TextureSlice, x: Double, y: Double, width: Double, height: Double) {
		if (DEBUG) println("quad: $width, $height")
		val tt = tex.texture as LibgdxTexture
		tt.checkVersion()
		val t = tt.tex!!
		val rect = tex.rect
		//val texreg = TextureRegion() // Should we do a copy?
		texreg.setRegion(t)
		texreg.setRegion(tex.u1, tex.v2, tex.u2, tex.v1)
		tempAffine.set(affine)
		tempAffine.translate(x.toFloat(), y.toFloat())
		batch.draw(texreg, width.toFloat(), height.toFloat(), tempAffine)
		//batch.draw(t, 0f, 0f)
	}

	override fun end() {
		if (DEBUG) println("end")
		//batch.flush()
		batch.end()
	}
}

class GdxApp(private val init: (views: Views) -> Unit) : ApplicationListener {
	var views by Delegates.notNull<Views>()
	var context by Delegates.notNull<RenderContext>()

	override public fun create(): Unit {
		val context = LibgdxContext()
		this.context = context
		this.views = Views(context, context, context, context)
		init(this.views)
		val clickEvent = MouseClickEvent(0.0, 0.0, 0)
		val moveEvent = MouseMovedEvent(0.0, 0.0)
		val keyDown = KeyDownEvent(Keys.INVALID)
		val keyUp = KeyUpEvent(Keys.INVALID)
		val keyPress = KeyPressEvent(Keys.INVALID)
		val onEvent = context.onEvent
		println("GdxApp.create()")
		Gdx.input.inputProcessor = object : InputProcessor {
			override fun touchUp(screenX: Int, screenY: Int, pointer: Int, button: Int): Boolean {
				clickEvent.x = screenX.toDouble()
				clickEvent.y = screenY.toDouble()
				clickEvent.button = button
				onEvent.dispatch(clickEvent)
				return true
			}

			override fun mouseMoved(screenX: Int, screenY: Int): Boolean {
				moveEvent.x = screenX.toDouble()
				moveEvent.y = screenY.toDouble()
				onEvent.dispatch(moveEvent)
				return true
			}

			override fun keyTyped(character: Char): Boolean {
				keyPress.code = character.toInt()
				onEvent.dispatch(keyPress)
				return true
			}

			override fun touchDown(screenX: Int, screenY: Int, pointer: Int, button: Int): Boolean {
				return true
			}

			override fun scrolled(amount: Int): Boolean {
				return true
			}

			override fun keyUp(keycode: Int): Boolean {
				keyUp.code = keycode
				onEvent.dispatch(keyUp)
				return true
			}

			override fun touchDragged(screenX: Int, screenY: Int, pointer: Int): Boolean {
				return true
			}

			override fun keyDown(keycode: Int): Boolean {
				keyDown.code = keycode
				onEvent.dispatch(keyDown)
				return true
			}
		}
	}

	override public fun dispose() {
	}

	override public fun render(): Unit {
		Gdx.gl.glClearColor(0f, 0f, 0f, 1f);
		Gdx.gl.glClear(GL.GL_COLOR_BUFFER_BIT);

		views.render(context)
		views.frame()
	}

	override public fun resize(width: Int, height: Int): Unit {
	}

	override public fun pause() {
	}

	override public fun resume() {
	}
}
