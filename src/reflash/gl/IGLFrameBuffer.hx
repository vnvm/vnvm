package reflash.gl;

import lang.IDisposable;
import reflash.display.Color2;
import reflash.display.IDrawable;

interface IGLFrameBuffer extends IDrawable extends IDisposable
{
	public var texture(default, null):IGLTexture;
	function clear(color:Color2):IGLFrameBuffer;
	function draw(drawable:IDrawable, x:Int = 0, y:Int = 0):IGLFrameBuffer;
	function finish():IGLFrameBuffer;
}
