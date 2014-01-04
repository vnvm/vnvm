package reflash.gl.wgl;

import lang.LangMacros;
import reflash.display.HtmlColors;
import lang.MathEx;
import reflash.display.Color2;
import reflash.display.Image2;
import reflash.display.IDrawable;
import common.StageReference;
import haxe.Log;
import flash.geom.Matrix3D;
import reflash.display.DrawContext;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import openfl.gl.GLFramebuffer;
import openfl.gl.GLTexture;
import openfl.gl.GL;

class WGLFrameBuffer implements IGLFrameBuffer
{
	//private var renderbuffer:GLRenderbuffer;
	public var texture(default, null):IGLTexture;
	private var temporalTexture:IGLTexture;
	private var frameBuffer:GLFramebuffer = null;
	private var _width:Int;
	private var _height:Int;

	private function isScreenBuffer():Bool
	{
		return (frameBuffer == null);
	}

	private function getWidth():Int
	{
		return isScreenBuffer() ? Std.int(StageReference.stage.stageWidth) : _width;
	}

	private function getHeight():Int
	{
		return isScreenBuffer() ? Std.int(StageReference.stage.stageHeight) : _height;
	}

	private function new()
	{
	}

	static private var screen:IGLFrameBuffer;

	static public function getScreen():IGLFrameBuffer
	{
		if (screen == null) screen = new WGLFrameBuffer();
		return screen;
	}

	private function createFrameBuffer(width:Int, height:Int):IGLFrameBuffer
	{
		this._width = width;
		this._height = height;

		frameBuffer = GL.createFramebuffer();
		//renderbuffer = GL.createRenderbuffer();

		temporalTexture = WGLTexture.fromEmpty(_width, _height);
		texture = WGLTexture.fromEmpty(_width, _height);

		bind();
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, temporalTexture.textureBase.textureId, 0);
		//GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, renderbuffer);

		return this;
	}

	static public function create(width:Int, height:Int):IGLFrameBuffer
	{
		var frameBuffer = new WGLFrameBuffer();
		return frameBuffer.createFrameBuffer(width, height).clear(HtmlColors.transparent).finish();
	}

	private function getRectangle():Rectangle
	{
		return new Rectangle(0, 0, getWidth(), getHeight());
	}

	private function setViewport()
	{
		var rect = getRectangle();
		//Log.trace('$rect');
		GL.viewport(Std.int(rect.x), Std.int(rect.y), Std.int(rect.width), Std.int(rect.height));
	}

	private function bindAndSetViewport()
	{
		bind();
		setViewport();
	}

	public function clear(color:Color2):IGLFrameBuffer
	{
		bindAndSetViewport();
		GL.clearColor(color.r, color.g, color.b, color.a);
		GL.clear(GL.COLOR_BUFFER_BIT);
		//unbind();

		return this;
	}

	public function draw(drawable:IDrawable, x:Int = 0, y:Int = 0):IGLFrameBuffer
	{
		var rect = getRectangle();

		var drawContext:DrawContext = new DrawContext();

		var left = rect.left;
		var right = rect.right;
		var top = rect.top;
		var bottom = rect.bottom;

		if (isScreenBuffer()) LangMacros.swap(top, bottom);

		drawContext.projectionMatrix = Matrix3D.createOrtho(left, right, top, bottom, -1, 1);
		drawContext.modelViewMatrix.prependTranslation(x, y, 0);

		bindAndSetViewport();
		drawable.drawElement(drawContext);
		//unbind();
		//GL.bindFramebuffer(GL.FRAMEBUFFER, null);

		return this;
	}

	public function drawElement(drawContext:DrawContext):Void
	{
		new Image2(texture).setAnchor(0, 0).drawElement(drawContext);
	}

	/*
	public function temporalBind(callback: DrawContext -> Void)
	{
		//Log.trace(GL.getParameter(GL.VIEWPORT));

		var rect = new Rectangle(0, 0, getWidth(), getHeight());
		var drawContext:DrawContext = new DrawContext();
		if (isScreenBuffer()) {
			drawContext.projectionMatrix = Matrix3D.createOrtho(rect.left, rect.right, rect.bottom, rect.top, -1, 1);
		} else {
			drawContext.projectionMatrix = Matrix3D.createOrtho(rect.left, rect.right, rect.top, rect.bottom, -1, 1);
		}
		//GL.viewport(Std.int(rect.x), Std.int(rect.y), Std.int(rect.width), Std.int(rect.height));
		setViewport();

		//Log.trace(frameBuffer);

		//var oldFrameBuffer = GL.getParameter(GL.FRAMEBUFFER_BINDING);
		bind();
		{
			callback(drawContext);
		}
		unbind();
		//GL.bindFramebuffer(GL.FRAMEBUFFER, oldFrameBuffer);
	}
	*/

	/*
	public function readPixels():ByteArray
	{
		var data = new ByteArray(4 * width * height);
		GL.readPixels(0, 0, width, height, GL.RGBA, GL.UNSIGNED_BYTE, data);
		return data;
	}
	*/

	static private var lastFrameBuffer:IGLFrameBuffer;

	private function bind()
	{
		// no change
		if (lastFrameBuffer == this) return;

		if (lastFrameBuffer != null)
		{
			//lastFrameBuffer.unbind();
		}
		//GL.bindTexture(GL.TEXTURE_2D, texture.textureBase.textureId);
		//GL.enable(GL.TEXTURE_2D);
		GL.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
		lastFrameBuffer = this;
		//GL.bindRenderbuffer(GL.RENDERBUFFER, renderbuffer);

		//GL.bindRenderbuffer(GL.RENDERBUFFER, renderbuffer);
		//GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height);
	}

	public function finish():IGLFrameBuffer
	{
		if (!isScreenBuffer())
		{
			GL.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
			texture.textureBase.bindToUnit(4);
			GL.copyTexSubImage2D(GL.TEXTURE_2D, 0, 0, 0, 0, 0, getWidth(), getHeight());
			GL.bindTexture(GL.TEXTURE_2D, null);
		}
		return this;
	}

	public function dispose()
	{
		if (frameBuffer != null) { GL.deleteFramebuffer(frameBuffer); frameBuffer = null; }
		if (texture != null) { texture.textureBase.dispose(); texture = null; }
		if (temporalTexture != null) { temporalTexture.textureBase.dispose(); temporalTexture = null; }
	}

	/*
	static public function unbind()
	{
		//GL.bindTexture(GL.TEXTURE_2D, null);
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
		//GL.bindRenderbuffer(GL.RENDERBUFFER, null);
	}
	*/
}