class RIO_OP_ANIM
{
	</ id=0x43, format="42s", description="" />
	static function ANIM_LOAD(unk, unk, file)
	{
		this.anim.load(file);
		this.state.background = "";
		this.state.background_color = null;
		this.draw_interface = false;

		//this.updateSceneLayer();
	}
	
	</ id=0x45, format="121", description="" />
	static function ANIM_PUT(unk1, index, unk2)
	{
		//printf("ANIM_PUT(%d, %d, %d)\n", unk1, index, unk2);
		this.anim.active_set(index, 1);
		//this.TODO();
	}

	</ id=0x4F, format="121", description="" />
	static function ANIM_UNPUT(unk1, index, unk2)
	{
		//printf("ANIM_UNPUT(%d, %d, %d)\n", unk1, index, unk2);
		//this.TODO();
		this.anim.active_set(index, 0);
	}

	</ id=0x50, format="s", description="" />
	static function TABLE(table_name)
	{
		this.table.load(table_name);
		//this.table.print();
		//this.TODO();
	}
	
	</ id=0x51, format="ff.", description="" />
	// flag_move_click, flag_set, value?
	static function TABLE_SELECT(flag_move_click, flag_mask_kind)
	{
		local click = 0;
		local mask_kind = 0;
		
		updateSceneLayer();
		sceneLayerShow.drawBitmap(sceneLayerDraw);
		
		while (1) {
			this.input_update();

			if (keyboard.pressed("up"   )) { this.table.keymap_move( 0, -1); this.table.using_mouse = false; }
			if (keyboard.pressed("down" )) { this.table.keymap_move( 0,  1); this.table.using_mouse = false; }
			if (keyboard.pressed("left" )) { this.table.keymap_move(-1,  0); this.table.using_mouse = false; }
			if (keyboard.pressed("right")) { this.table.keymap_move( 1,  0); this.table.using_mouse = false; }
			if (keyboard.pressed("enter")) { click = 1; this.table.using_mouse = false; }
			if (keyboard.pressed("escape")) { click = -1; this.table.using_mouse = false; }
			
			//printf("@@@@@@@@@POSITION: (%d, %d, %d)\n", this.table.position.x, this.table.position.y, this.table.position.kind);
			// Mouse moved
			if (mouse.dx != 0 || mouse.dy != 0) {
				this.table.using_mouse = true;
			}
			
			if (this.table.using_mouse) {
				mask_kind = this.table.mask.images[0].getpixel(mouse.x, mouse.y);
				if (!this.state.flags[this.table.enable_flags[mask_kind]]) {
					mask_kind = 0;
				} else {
					this.table.keymap_goto_kind(mask_kind);
				}
			} else {
				mask_kind = this.table.position.kind;
			}
			
			if (mouse.clicked(0)) click = 1;
			if (mouse.clicked(2)) {
				mask_kind = 0;
				click = -1;
			}

			//printf("%d,%d : %d\n", mouse.x, mouse.y, mask_kind);

			this.frame_draw();
			this.frame_tick();

			break;
		}

		this.state.flags[flag_move_click] = click;
		this.state.flags[flag_mask_kind]  = mask_kind;
		//this.TODO();

		//this.anm.start_drawing();
		/*
		this.frame_draw_anim();
		this.frame_draw();
		this.frame_tick();
		*/
		
		//this.TODO();

		return flag_mask_kind;
	}
}
