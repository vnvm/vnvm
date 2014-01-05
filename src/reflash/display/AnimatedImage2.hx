package reflash.display;

import lang.time.Timer2;
import haxe.Log;
import reflash.gl.IGLTexture;

class AnimatedImage2 extends DisplayObject2
{
	private var frames:Array<IGLTexture>;
	private var currentFrame:Int = 0;
	private var startedTime:Float;
	private var fps:Int;

	public function new(frames:Array<IGLTexture>, fps:Int)
	{
		super();
		this.width = frames[0].width;
		this.height = frames[0].height;
		this.frames = frames;
		this.fps = fps;
		this.start();
	}

	public function start()
	{
		startedTime = Timer2.stamp();
	}

	override private function drawInternal(drawContext:DrawContext)
	{
		var elapsed = Timer2.stamp() - startedTime;
		new Image2(frames[Std.int(elapsed * fps) % frames.length]).drawInternal(drawContext);
	}
}
