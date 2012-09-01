
class SceneObject
{
	name = "<unknown>";
	mgd = null;
	x = 0;
	y = 0;
	
	constructor(name)
	{
		this.name = name;
	}
	
	function drawTo(screen, x = 0, y = 0)
	{
		//printf("Drawing: %s : %d\n", this.name, (this.mgd != null) ? 1 : 0);
		if (this.mgd != null) this.mgd.drawTo(screen, x, y);
	}
}

class Scene
{
	allObjects = null;
	background = null;
	characters = null;

	layerDraw = null;
	layerShow = null;
	transitionMask = null;
	stepf = 0.0;
	
	constructor()
	{
		this.layerDraw = Bitmap(800, 600, 32); this.layerDraw.clear([0, 0, 0, 1.0]);
		this.layerShow = Bitmap(800, 600, 32); this.layerShow.clear([0, 0, 0, 1.0]);
		this.stepf = 0.0;
		this.background = SceneObject(::format("background"));
		this.characters = []; for (local n = 0; n < 16; n++) this.characters.push(SceneObject(::format("character %d", n)));
		this.allObjects = [this.background];
		foreach (character in this.characters) this.allObjects.push(character);
	}

	function updateLayerDraw()
	{
		this.layerDraw.clear([0, 0, 0, 1.0]);
		background.drawTo(this.layerDraw);
		foreach (object in characters) object.drawTo(this.layerDraw);
		//foreach (object in allObjects) object.drawTo(this.layerDraw);
	}
	
	function copyLayerShowToDraw()
	{
		this.layerShow.clear([0, 0, 0, 1.0]);
		this.layerShow.drawBitmap(this.layerDraw, 0, 0);
	}
	
	function drawTo(screen, x = 0, y = 0)
	{
		this.updateLayerDraw();
		screen.drawBitmap(this.layerShow, x, y);
		
		local effect;
		if (transitionMask != null) {
			effect         = Effect("transition");
			effect.blend   = 1;
			effect.reverse = 0;
			effect.image   = this.layerDraw;
			effect.mask    = this.transitionMask;
		} else {
			effect         = Effect("normal");
		}
		effect.step = this.stepf;
		Screen.pushEffect(effect);
		{
			screen.drawBitmap(this.layerDraw, x, y, this.stepf);
		}
		Screen.popEffect();
	}
}

