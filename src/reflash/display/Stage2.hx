package reflash.display;

import reflash.wgl.WGLFrameBuffer;
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
	}

	private function render(rect:Rectangle)
	{
		var screen = WGLFrameBuffer.getScreen();
		screen.clear(Color.create(8 / 256, 146 / 256, 208 / 256, 1));
		screen.draw(this);
	}

	static public function createAndInitializeStage2(stage:Stage)
	{
		instance = new Stage2(stage);
	}
}
