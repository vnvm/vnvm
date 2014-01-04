package engines.will.display;

import haxe.Log;
import common.geom.Anchor;
import reflash.display.Sprite2;

class GameInterfaceLayerList extends Sprite2
{
	private var willResourceManager:WillResourceManager;

	private var objectsLayer:GameElementsLayer;
	private var layer1Layer:GameElementsLayer;
	private var layer2Layer:GameElementsLayer;
	private var backgroundLayer:GameElementsLayer;
	private var menuLayer:GameMenuLayer;

	public function new(willResourceManager:WillResourceManager)
	{
		super();
		this.willResourceManager = willResourceManager;
		this.addChild(this.backgroundLayer = new GameElementsLayer(willResourceManager, Anchor.centerCenter));
		this.addChild(this.layer1Layer = new GameElementsLayer(willResourceManager, Anchor.topLeft));
		this.addChild(this.layer2Layer = new GameElementsLayer(willResourceManager, Anchor.topLeft));
		this.addChild(this.objectsLayer = new GameElementsLayer(willResourceManager, Anchor.topLeft));
		this.addChild(this.menuLayer = new GameMenuLayer());

		//for (name in willResourceManager.getFileNames()) Log.trace(name);
	}

	public function getLayerWithName(name:String):IGameElementsLayer
	{
		return switch (name) {
			case 'layer2': layer2Layer;
			case 'layer1': layer1Layer;
			case 'objects': objectsLayer;
			case 'background': backgroundLayer;
			default: throw('Can\'t find layer $name');
		}
	}

	public function getMenuLayer():GameMenuLayer
	{
		return this.menuLayer;
	}
}
