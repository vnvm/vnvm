class RIO_OP_TEXT_base
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

	static function OPTION_SELECT_common(options)
	{
		if (options.len() == 0) return;
	
		local selwnd0 = resman.get_image("SELWND0", 1);
		local selwnd1 = resman.get_image("SELWND1", 1);
		local option_w = selwnd0.images[0].w;
		local option_h = selwnd0.images[0].h;
		local margin_h = 16;

		foreach (option in options) {
			option.rect <- {x=screen.w / 2 - option_w / 2, y=100 + option.n * (option_h + margin_h), w=option_w, h=option_h};
		}
		local selectedOption = null;
		
		while (selectedOption == null) {
			this.input_update();
			
			this.frame_draw();
			if (draw_interface) this.frame_draw_interface(0);

			foreach (option in options) {
				local selwnd = selwnd0;
				if (between2({x=mouse.x, y=mouse.y}, option.rect)) {
					selwnd = selwnd1;
					if (mouse.pressed(0)) {
						selectedOption = option;
						this.input_update();
					}
				}
				selwnd.drawTo(screen, 0, option.rect.x, option.rect.y);
				print_text(option.text, option.rect.x + 26, option.rect.y + 12);
			}
			//selwnd0.drawTo(screen, 0, 100, 100);

			this.frame_tick();
			//break;
		}
		
		if ("flag" in selectedOption) {
			this.state.flags[selectedOption.flag] = 1;
		}
		if ("script" in selectedOption) {
			this.load(selectedOption.script, 0);
		}
	}

	//  02.? [0200], [7201], "Tell her", [01520307], @t001_02b@, [7301], "Don't tell her", [01530307], @t001_02c@
	</ id=0x02, format="C[2t4s]", description="Show a list of options" variadic=1 />
	static function OPTION_SELECT(params)
	{
		local options = [];
		local count = params[1];
		for (local n = 0; n < count; n++) {
			local flag = params[2 + n * 4 + 0];
			local text = params[2 + n * 4 + 1];
			local unk1 = params[2 + n * 4 + 2];
			local script = params[2 + n * 4 + 3];
			options.push({n=n, flag=flag, text=text, script=script});
		}
		RIO_OP_TEXT_base.OPTION_SELECT_common(options);
		this.TODO();
	}
}

switch (engine_version) {
	case "pw":
		class RIO_OP_TEXT extends RIO_OP_TEXT_base
		{
			//  02.? [0200], [7201], "Tell her", [01520307], @t001_02b@, [7301], "Don't tell her", [01530307], @t001_02c@
			//</ id=0x02, format="C[Ct44[.]]", description="Show a list of options" variadic=1 />
			</ id=0x02, format="*", description="Show a list of options" variadic=1 />
			static function OPTION_SELECT(params)
			{
				local options = [];
				local count = data.readn('s');
				local extras = {};
				for (local n = 0; n < count; n++) {
					local extra = data.readn('s');
					extras[n] <- extra;
					local text = process_text(data.readstringz(-1));
					data.readn('s');
					data.readn('s');
					data.readn('s');
					data.readn('s');
					//data.readn('s');
					//data.readn('b');
					for (local m = 0; m < extras[0]; m++) {
						data.readn('b');
					}
					options.push({n=n, text=text});
				}
				RIO_OP_TEXT_base.OPTION_SELECT_common(options);
				printf("Selected!\n");
				this.TODO();
			}
		}
	break;
	default:
		class RIO_OP_TEXT extends RIO_OP_TEXT_base
		{
		}
	break;
}