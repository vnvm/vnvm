class RIO_OP_SCENE
{
	</ id=0x46, format="22221s", description="Puts a background in a position" />
	static function BACKGROUND(x, y, unk1, unk2, index, name)
	{
		this.state.background_color = null;
		this.state.background = {x=x, y=y, index=index, name=name, animation=null};
		//this.state.background = {x=0, y=0, index=index, name=name};
		this.updateSceneLayer();
	}
	
	</ id=0x47, format="11", description="" />
	static function BACKGROUND_COLOR(color, param)
	{
		switch (color) {
			case 0:
				this.state.background_color = [0, 0, 0, 1];
				this.state.background = "";
			break;
			default:
				this.TODO();
			break;
		}
		this.updateSceneLayer();
	}
	
	</ id=0x48, format="122221s", description="" />
	static function CHARA_PUT(index, x, y, unk1, unk2, index2, name)
	{
		index = index % 3;
		local sprite = {
			index = index2,
			x = x,
			y = y,
			name = name,
			animation = null,
		};
		this.state.sprites_l1[index] = sprite;
		this.updateSceneLayer();
	}
	
	// OBJ_PUT : [243,276,0,0,0,"EC_001"]
	</ id=0x73, format="22221s", description="" />
	static function OBJ_PUT(x, y, unk1, unk2, unk3, name)
	{
		local sprite = {
			x = x,
			y = y,
			name = name,
			animation = null,
		};
		this.state.sprites_object = sprite;
		this.updateSceneLayer();
	}

	</ id=0x49, format="2.", description="Clears an object/character in layer1 (0=LEFT, 1=CENTER, 2=RIGHT)" />
	static function CLEAR_L1(index)
	{
		this.state.sprites_l1[index % 3] = null;
		this.updateSceneLayer();
	}

	</ id=0xB8, format="2.", description="" />
	static function CLEAR_L2(index)
	{
		this.state.sprites_l2[index % 3] = null;
		this.updateSceneLayer();
	}

	</ id=0x74, format="2", description="" />
	static function OBJ_CLEAR(index)
	{
		this.state.sprites_object = null;
		this.updateSceneLayer();
	}
}