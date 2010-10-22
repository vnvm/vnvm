class Engine
{
	name        = "";
	engine_name = "";
	image       = null;
	alpha       = 0.3;
	alphaFrom   = 0;
	alphaTo     = 0;
	alphaStep   = 0;
	selected    = -1;
	enabled     = 0;
	base_path   = "";
	rect        = null;

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
local x = 8, y = 8;
foreach (index, engine in engines) {
	engine.rect = {x = x, y = y, w = engine.image.w, h = engine.image.h };
	y += engine.image.h + 8;
}

//local image = Bitmap.fromFile(info.game_data_path + "/pw/translation/es/EC_001.0 - copia.png");


local option_index = 0;
while (1) {
	local selectedEngine = null;
	local using_mouse = false;
	local option_clicked = false;

	while (selectedEngine == null) {
		::input.update();
		
		if (::input.pad_pressed("up"    )) { option_index--; using_mouse = false; option_index = clamp(option_index, 0, engines.len() - 1); }
		if (::input.pad_pressed("down"  )) { option_index++; using_mouse = false; option_index = clamp(option_index, 0, engines.len() - 1); }
		if (::input.pad_pressed("accept")) { option_clicked = true; using_mouse = false; }
		if (::input.pad_pressed("cancel")) { }
		
		if (::input.mouseMoved()) using_mouse = true;
		if (::input.mouse.pressed(0)) {
			option_clicked = true;
			using_mouse = true;
		}
		
		if (using_mouse) {
			option_index = -1;
			foreach (n, engine in engines) if (::input.mouseInRect(engine.rect)) option_index = n;
		}
		
		screen.clear([0, 0, 0, 1]);

		local x = 8, y = 8;
		foreach (index, engine in engines) {
			if (!engine.enabled) continue;
			if (index == option_index) {
				engine.setSelected(1);
				if (option_clicked) {
					selectedEngine = engine;
				}
			} else {
				engine.setSelected(0);
			}
			engine.transitionStep();
			screen.drawBitmap(engine.image, x, y, engine.alpha);
			y += engine.image.h + 8;
		}
		//screen.drawBitmap(image);
		Screen.frame();
		Screen.flip();
	}
	
	info.game_data_path = selectedEngine.base_path + "/" + selectedEngine.name;
	include(info.engine_path + "/" + selectedEngine.engine_name + "/main.nut");
}