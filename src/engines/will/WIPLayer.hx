package engines.will;

import reflash.gl.wgl.WGLTexture;
import reflash.display.Image2;
import engines.will.formats.wip.WIP;
import reflash.display.Sprite2;

class WIPLayer extends Sprite2
{
	private var wip:WIP;

	private function new(wip:WIP)
	{
		super();

		this.wip = wip;

		for (index in 0 ... wip.length)
		{
			var wipEntry = wip.get(index);
			this.addChild(new Image2(WGLTexture.fromBitmapData(wipEntry.bitmapData)).setPosition(wipEntry.x, wipEntry.y).setZIndex(index));
		}
	}

	static public function fromWIP(wip:WIP):WIPLayer
	{
		return new WIPLayer(wip);
	}
}
