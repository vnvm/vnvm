class RIO_OP_TEXT
{
	static function TEXT_COMMON(text_id, title, text, reset = 1)
	{
		if (reset) {
			this.interface.text_title = "";
			this.interface.text_body = "";
		}
		local trans = translation.get(text_id, text, title);
		this.interface.textProgress = this.interface.text_body.len();
		this.interface.enabled    = true;
		this.interface.text_title += trans.title;
		this.interface.text_body  += trans.text;
		this.interface.skip = false;

		this.interface.waitingSkip = true;
		this.loopUntilAnimationEnds();
		this.interface.waitingSkip = false;

		//this.TODO();
		Audio.channelStop(this.voice_channel);
	}
	
	</ id=0x41, format="2.t", description="" />
	static function TEXT(text_id, text)
	{
		RIO_OP_TEXT.TEXT_COMMON(text_id, "", text, 1);
	}

	</ id=0x42, format="2..tt", description="" />
	static function TEXT2(text_id, title, text)
	{
		RIO_OP_TEXT.TEXT_COMMON(text_id, title, text, 1);
	}

	</ id=0xB6, format="2t", description="" />
	static function TEXT_ADD(text_id, text)
	{
		RIO_OP_TEXT.TEXT_COMMON(text_id, "", text, 0);
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
		local using_mouse = true;
		local option_index = 0;
		local option_clicked = false;

		foreach (option in options) {
			option.rect <- {x=screen.w / 2 - option_w / 2, y=100 + option.n * (option_h + margin_h), w=option_w, h=option_h};
		}
		local selectedOption = null;
		
		while (selectedOption == null) {
			::input.update();
			
			option_clicked = false; 
			
			if (::input.pad_pressed("up"    )) { option_index--; using_mouse = false; option_index = clamp(option_index, 0, options.len() - 1); }
			if (::input.pad_pressed("down"  )) { option_index++; using_mouse = false; option_index = clamp(option_index, 0, options.len() - 1); }
			if (::input.pad_pressed("accept")) { option_clicked = true; using_mouse = false; }
			if (::input.pad_pressed("cancel")) { }
			
			if (::input.mouseMoved()) using_mouse = true;
			if (::input.mouse.pressed(0)) {
				option_clicked = true;
				using_mouse = true;
			}
			
			if (using_mouse) {
				option_index = -1;
				foreach (n, option in options) if (::input.mouseInRect(option.rect)) option_index = n;
			}
			
			this.drawTo(screen);

			foreach (n, option in options) {
				local selwnd = selwnd0;
				//if (pointInRect({x=::input.mouse.x, y=::input.mouse.y}, option.rect)) {
				if (n == option_index) {
					selwnd = selwnd1;
					if (option_clicked) {
						selectedOption = option;
						::input.update();
					}
				}
				selwnd.drawTo(screen, 0, option.rect.x, option.rect.y);
				this.interface.print_text(option.text, option.rect.x + 26, option.rect.y + 12);
			}
			//selwnd0.drawTo(screen, 0, 100, 100);

			Screen.flip();
			Screen.frame(this.fps);
			//break;
		}
		
		if ("flag" in selectedOption.result) {
			this.state.flag_set(selectedOption.result.flag, selectedOption.result.value);
		}
		if ("script" in selectedOption.result) {
			this.load(selectedOption.result.script, 0);
		}
		if ("address" in selectedOption.result) {
			this.jump_absolute(selectedOption.result.address);
		}
	}

	//  02.? [0200], [7201], "Tell her", [01520307], @t001_02b@, [7301], "Don't tell her", [01530307], @t001_02c@
	</ id=0x02, format="C[2t3c]", description="Show a list of options" />
	static function OPTION_SELECT(roptions)
	{
		printf("::: %s\n\n\n", object_to_string(roptions));
		local options = [];
		foreach (n, option in roptions) {
			local option_info = {};
			option_info.n      <- n;
			option_info.index  <- option[0];
			option_info.text   <- option[1];
			option_info.unk1   <- option[2];
			option_info.result <- option[3];
			options.push(option_info);
		}
		RIO_OP_TEXT.OPTION_SELECT_common(options);
		this.TODO();
	}
}
