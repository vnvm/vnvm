class RIO_OP_TEXT
{
	static function TEXT_COMMON(text_id, title, text, start = 0)
	{
		draw_interface = 1;
		local clkwait_tick = 0;
		local fstep
		local ended = false;
		local number_of_letters = text.len();
		local text_show_time;
		local can_skip = true;
		local ms_time_per_character = 40;
		local text_speed_flag = this.state.flags[993];
		local skip_on_end = false;

		last_title = title;
		last_text  = text;
		
		//printf("Variable 993 (velocidad de texto): %d\n", text_speed_flag);
		if (text_speed_flag == 0) {
			text_show_time = number_of_letters * ms_time_per_character;
			can_skip = true;
		} else {
			text_show_time = text_speed_flag;
			//ms_time_per_character = this.state.flags[993] / 10;
			can_skip = false;
			skip_on_end = true;
		}
		
		//text_show_time = number_of_letters * ms_time_per_character;
		
		local timer = Timer();

		if (start > 0) {
			timer.increment(ms_time_per_character * start);
		}
		
		local draw_text_scene = function(title, text, number_of_letters, fstep, screen, draw_interface) {
			this.frame_draw();
			if (draw_interface) this.frame_draw_interface(title.len());
			
			local title_pos = { x = 60, y = screen.h - 152, w = 0, h = 0};
			local text_pos  = { x = 80, y = 512           , w = 0, h = 0};
			
			switch (engine_version) {
				case "pw":
					title_pos.y = screen.h - 166;
					title_pos.x = 90;
					text_pos.y = 512 - 40;
				break;
			}

			print_text(title, title_pos.x, title_pos.y);
			font.setSlice(0, number_of_letters * fstep);
			print_text(text, text_pos.x, text_pos.y);
			font.setSlice(-1, -1);
		};
		
		printf("ID(%d) TITLE('%s') TEXT('%s')\n", text_id, title, text);
		
		while (1) {
			this.input_update();

			if (this.skipping()) {
				fstep = 1.0;
				draw_text_scene(title, text, number_of_letters, fstep, screen, draw_interface);	
				this.frame_tick();
				break;
			}

			if (!ended) {
				fstep = timer.elapsed.tofloat() / text_show_time.tofloat();
				if (fstep >= 1.0) ended = true;
			} else {
				fstep = 1.0;
			}

			draw_text_scene(title, text, number_of_letters, fstep, screen, draw_interface);
			if (ended) {
				screen.drawBitmap(
					wip_clkwait_frames[floor(clkwait_tick / 3) % wip_clkwait_frames.len()],
					595,
					screen.h - 45
				);
			}
			
			this.frame_tick();
			clkwait_tick++;
			
			if (skip_on_end && ended) break;

			if (this.pressedNext()) {
				if (ended) break;
				if (can_skip) ended = true;
			}
		}

		this.frame_draw();
		if (draw_interface) this.frame_draw_interface(title.len());
		this.frame_tick();

		//this.TODO();
		Audio.channelStop(this.voice_channel);
	}
	
	</ id=0x41, format="2.t", description="" />
	static function TEXT(text_id, text)
	{
		local trans = translation.get(text_id, text);
		RIO_OP_TEXT.TEXT_COMMON(text_id, trans.title, trans.text);
	}

	</ id=0x42, format="2..tt", description="" />
	static function TEXT2(text_id, title, text)
	{
		local trans = translation.get(text_id, text, title);
		RIO_OP_TEXT.TEXT_COMMON(text_id, trans.title, trans.text);
	}

	</ id=0xB6, format="2t", description="" />
	static function TEXT_ADD(text_id, text)
	{
		local trans = translation.get(text_id, text);
		RIO_OP_TEXT.TEXT_COMMON(text_id, last_title, last_text + trans.text, last_text.len());
	}

	</ id=0x08, format="2", description="Sets the size of the text (00=small, 01=big)" />
	static function TEXT_SIZE(size)
	{
		this.TODO();
	}

	//  02.? [0200], [7201], "Tell her", [01520307], @t001_02b@, [7301], "Don't tell her", [01530307], @t001_02c@
	</ id=0x02, format="C[2t4s]", description="Show a list of options" variadic=1 />
	static function OPTION_SELECT(params)
	{
		local selwnd0 = resman.get_image("SELWND0", 1);
		local selwnd1 = resman.get_image("SELWND1", 1);
		
		local options = [];
		local count = params[0];
		for (local n = 0; n < count; n++) {
			local unk1 = params[1 + n * 4 + 0];
			local unk2 = params[1 + n * 4 + 1];
			local unk3 = params[1 + n * 4 + 2];
			local unk4 = params[1 + n * 4 + 3];
			options.push([
				unk1, unk2, unk3, unk4
			]);
		}
		
		while (1) {
			this.input_update();
			
			this.frame_draw();
			if (draw_interface) this.frame_draw_interface(title.len());

			//for (local n = 0; n < )
			selwnd0.drawTo(screen, 0, 100, 100);

			this.frame_tick();
			break;
		}

		this.TODO();
	}
}