class RIO_OP_SCENE
{
	</ id=0x46, format="22221s", description="Puts a background in a position" />
	static function BACKGROUND(x, y, unk1, unk2, index, name)
	{
		local background = this.scene.background;
		if (background.name != name) {
			// Background changed.
			this.interface.enabled = false;
		}
		
		background.x = -x;
		background.y = -y;
		background.index = index;
		background.alpha = 1.0;
		background.name = name;
		background.color = null;
		background.enabled = true;
		this.scene.table.enabled = false;
		this.TODO();
	}
	
	</ id=0x47, format="11", description="" />
	static function BACKGROUND_COLOR(color, param)
	{
		switch (color) {
			case 0:
				//this.state.background_color = [0, 0, 0, 1];
				//this.state.background = "";
				local background = this.scene.background;
				background.color = [0, 0, 0, 1];
				background.enabled = true;
				this.scene.table.enabled = false;
				this.TODO();
			break;
			default:
				this.TODO();
			break;
		}
	}

	</ id=0x68, format="2221", description="Sets background size and position x and y coords are the center points of the viewport." />
	static function BACKGROUND_VIEWPORT(size, x, y, unk4)
	{
		local sizef = size / 100.0;
		this.scene.background.size = sizef;
		this.scene.background.x = 400 - x * sizef;
		this.scene.background.y = 300 - y * sizef;
		//this.scene.setViewport(size / 100.0, x, y);
		//this.TODO();
		//this.interface.enabled = false;
	}

	</ id=0x48, format="122221s", description="" />
	static function CHARA_PUT(index, x, y, unk1, unk2, index2, name)
	{
		local object = this.scene.sprites_l1[index];
		object.index = index2;
		object.name = name;
		object.alpha = 1.0;
		object.size = 1.0;
		object.rotation = 0.0;
		object.enabled = true;
		object.setXY(x, y, 0.0, 0.0);
		
		this.TODO();
	}

	</ id=0x64, format="1111", description="" />
	static function CHARA_PUT_INFO(index, size, rotation, unk4)
	{
		local object = this.scene.sprites_l1[index];
		object.size = size / 100.0;
		this.TODO();
	}

	// OBJ_PUT : [243,276,0,0,0,"EC_001"]
	</ id=0x73, format="22221s", description="" />
	static function OBJ_PUT(x, y, unk1, unk2, unk3, name)
	{
		local object = this.scene.overlay;
		object.index = 0;
		object.x = x;
		object.y = y;
		object.name = name;
		object.alpha = 1.0;
		object.enabled = true;
		
		this.TODO();
	}

	</ id=0x49, format="2.", description="Clears an object/character in layer1 (0=LEFT, 1=CENTER, 2=RIGHT)" />
	static function CLEAR_L1(index)
	{
		this.scene.sprites_l1[index].enabled = false;
	}

	</ id=0xB8, format="2.", description="" />
	static function CLEAR_L2(index)
	{
		this.scene.sprites_l2[index].enabled = false;
	}

	</ id=0x74, format="2", description="" />
	static function OBJ_CLEAR(index)
	{
		this.scene.overlay.enabled = false;
	}
}