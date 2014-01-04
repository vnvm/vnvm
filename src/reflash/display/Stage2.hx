package reflash.display;

import reflash.gl.wgl.util._WGLInstances;
import haxe.Log;
import reflash.gl.wgl.WGLFrameBuffer;
import flash.geom.Rectangle;
import openfl.display.OpenGLView;
import flash.display.Stage;

class Stage2 extends Sprite2
{
	static public var instance(default, null):Stage2;

	private var stage:Stage;

	private function new(stage:Stage)
	{
		super();
		this.stage = stage;
		initialize();
	}

	private function initialize()
	{
		var view = new OpenGLView();
		view.render = render;
		this.stage.addChild(view);
		this.stage.addEventListener(OpenGLView.CONTEXT_LOST, onContextLost);
		this.stage.addEventListener(OpenGLView.CONTEXT_RESTORED, onContextRestored);
	}

	private function onContextLost(?e)
	{
		Log.trace('OpenGLView.CONTEXT_LOST');
	}

	private function onContextRestored(?e)
	{
		Log.trace('OpenGLView.CONTEXT_RESTORED');
		_WGLInstances.getInstance().restore();
	}

	private function render(rect:Rectangle)
	{
		var screen = WGLFrameBuffer.getScreen();
		//screen.clear(Color2.create(8 / 256, 146 / 256, 208 / 256, 1));
		screen.draw(this);
	}

	static public function createAndInitializeStage2(stage:Stage)
	{
		instance = new Stage2(stage);
	}
}
