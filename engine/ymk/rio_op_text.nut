class RIO_OP_TEXT_base
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
				if (pointInRect({x=mouse.x, y=mouse.y}, option.rect)) {
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