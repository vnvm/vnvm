package ;

import lang.Reference;
import openfl.gl.GL;
import reflash.gl.IGLFrameBuffer;
import reflash.display.Image2;
import reflash.gl.wgl.WGLFrameBuffer;
import common.StageReference;
import flash.geom.Rectangle;
import flash.display.Sprite;
import openfl.display.OpenGLView;

class FilteredSprite extends Sprite
{
	public var container(default, null):Sprite;
	private var framebuffer:IGLFrameBuffer;
	//private var reference:Reference

	public function new(width:Int, height:Int)
	{
		super();

		width = StageReference.stage.stageWidth;
		height = StageReference.stage.stageHeight;

		framebuffer = WGLFrameBuffer.create(width, height);

		this.addChild(new Before(framebuffer));
		this.addChild(this.container = new Sprite());
		this.addChild(new After(framebuffer));
	}
}

private class Before extends OpenGLView
{
	var framebuffer:IGLFrameBuffer;

	public function new(framebuffer:IGLFrameBuffer)
	{
		super();
		this.framebuffer = framebuffer;
	}

	override public function render(rect:Rectangle)
	{
		framebuffer.bindAndSetViewport();
//GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
	}
}

private class After extends OpenGLView
{
	var framebuffer:IGLFrameBuffer;

	public function new(framebuffer:IGLFrameBuffer)
	{
		super();

		this.framebuffer = framebuffer;
	}

	override public function render(rect:Rectangle)
	{
		framebuffer.finish();

		WGLFrameBuffer.getScreen().bindAndSetViewport();

		//new Image2(framebuffer.texture).drawElement

		/*
		WGLFrameBuffer.getScreen().draw(
			new Image2(framebuffer.texture)
		);
		*/

/*
		var shader = SolidColorShader.getInstance();
		shader.use();
		shader.setProjection(Matrix3D.createOrtho(0, 1280, 720, 0, -1, 1));
		shader.setModelView(new Matrix3D());
		shader.setColor(1, 1, 1, 1);
		shader.addVertex(0, 0);
		shader.addVertex(100, 0);
		shader.addVertex(0, 100);
		shader.addVertex(100, 100);
		shader.draw();
		*/

/*
		var shader = TextureShader.getInstance();
		shader.use();
		shader.setProjection(Matrix3D.createOrtho(0, StageReference.stage.stageWidth, StageReference.stage.stageHeight, 0, -1, 1));
		shader.setModelView(new Matrix3D());
		shader.setTexture(new WGLTextureBase(texture));
		shader.addVertex(0, 0, 0, 0);
		shader.addVertex(StageReference.stage.stageWidth, 0, 1, 0);
		shader.addVertex(0, StageReference.stage.stageHeight, 0, 1);
		shader.addVertex(StageReference.stage.stageWidth, StageReference.stage.stageHeight, 1, 1);
		shader.draw();
		*/
	}
}