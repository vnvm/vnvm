class Engine
{
	name = "";
	engine_name = "";
	image = null;
	alpha = 0.3;
	alphaFrom = 0;
	alphaTo = 0;
	alphaStep = 0;
	selected = -1;
	enabled = 0;
	base_path = "";

	constructor(name, engine_name)
	{
		this.name  = name;
		this.image = Bitmap.fromFile(info.engine_path + "/game_selector/" + name + ".png");
		this.engine_name = engine_name;
		this.base_path = info.game_data_path;
		enabled = true;
		//enabled = exists_in_game_path_any(name);
	}
	
	function setSelected(value)
	{
		if (this.selected != value) {
			this.selected = value;
			this.alphaStep = 0;
			this.alphaFrom = this.alpha;
			this.alphaTo = value ? 1.0 : 0.3;
			if (value) {
				//joypad.setVibration(1.0, 0.0, 60, 1);
				//Screen.frame(5);
				//joypad.setVibration(0.0, 0.0);
			}
		}
	}
	
	function transitionStep()
	{
		if (alphaStep < 1) alphaStep += 0.1;
		this.alpha = (this.alphaTo - this.alphaFrom) * alphaStep + this.alphaFrom;
	}
	
}

screen <- Screen.init(640, 480);
engines <- [];
engines.push(Engine("pw", "ymk"));
engines.push(Engine("ymk", "ymk"));
engines.push(Engine("dividead", "dividead"));
engines.push(Engine("tlove", "tlove"));

while (1) {
	local selectedEngine = null;

	while (selectedEngine == null) {
		mouse.update();
		keyboard.update();
		
		screen.clear([0, 0, 0, 1]);

		local y = 8;
		local x = 8;
		foreach (engine in engines) {
			if (!engine.enabled) continue;
			if (mouse.x >= x && mouse.y >= y && mouse.x <= x + engine.image.w && mouse.y <= y + engine.image.h) {
				engine.setSelected(1);
				if (mouse.clicked(0)) {
					selectedEngine = engine;
				}
			} else {
				engine.setSelected(0);
			}
			engine.transitionStep();
			screen.drawBitmap(engine.image, x, y, engine.alpha);
			y += engine.image.h + 8;
		}
		Screen.frame();
		Screen.flip();
	}
	
	info.game_data_path = selectedEngine.base_path + "/" + selectedEngine.name;
	include(info.engine_path + "/" + selectedEngine.engine_name + "/main.nut");
}