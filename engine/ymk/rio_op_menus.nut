class RIO_OP_MENUS
{
	</ id=0x83, format=".", description="" />
	static function RUN_LOAD()
	{
		this.TODO();
	}

	</ id=0x84, format="1", description="" />
	static function RUN_SAVE(param)
	{
		this.TODO();
	}

	</ id=0x88, format="111", description="" />
	static function BATTLE(unk1, battle_id, unk3)
	{
		this.TODO();
		this.state.flags[916] = 1; // WIN
		//this.state.flags[916] = 0; // LOOSE
	}

	</ id=0x8A, format="1", description="" />
	static function UNK_8A(param)
	{
		this.TODO();
	}

	</ id=0x8B, format=".", description="" />
	static function RUN_CONFIG()
	{
		local cfgbg = resman.get_image("CFGBG");
		local mask  = resman.get_mask("CFG_P1M");
		while (1) {
			this.input_update();
			
			//this.frame_draw();
			//if (draw_interface) this.frame_draw_interface(0);
			
			cfgbg.drawTo(screen, 0);
			cfgbg.drawTo(screen, 1); // return button
			cfgbg.drawTo(screen, 3); // yes/no options
			cfgbg.drawTo(screen, 6); // volume on
			cfgbg.drawTo(screen, 9); // numeric options
			
			local hover_kind = mask.images[0].getpixel(mouse.x, mouse.y);
			
			if (pressedNext()) {
				break;
			}
			
			this.frame_tick();
		}
		this.TODO();
	}

	</ id=0xE2, format=".", description="" />
	static function RUN_QLOAD()
	{
		this.TODO();
	}
}