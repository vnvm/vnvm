package engines.will.display;

import reflash.display.Sprite2;

class GameGraphics extends Sprite2
{
	private var willResourceManager:WillResourceManager;

	public function new(willResourceManager:WillResourceManager)
	{
		this.willResourceManager = willResourceManager;
	}
}
