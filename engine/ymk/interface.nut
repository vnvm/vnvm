class Interface extends Component
{
	text_title   = "";
	text_body    = "";
	wip_winbase0 = null;
	wip_clkwait  = null;
	wip_clkwait_frames = null;
	font         = null;
	textProgress = -1;
	position_title = null;
	position_body  = null;
	position_wait  = null;
	skip = false;
	clkwait_tick = 0;
	color_face = null;
	color_border = null;
	text_size = 1.0;
	waitingSkip = true;
	interface_position = null;
	rio = null;
	buttons = null;

	constructor(rio = null)
	{
		this.rio = rio;
		this.text_title = "";
		this.text_body  = "";
		this.text_size = 1.0;
		
		this.waitingSkip = true;

		this.wip_clkwait = resman.get_image("CLKWAIT", 0);
		
		local iwait = wip_clkwait.images[0];

		this.wip_winbase0 = resman.get_image("WINBASE0", 0);
		interface_position = {x=800 / 2 - wip_winbase0.infos[0].w / 2, y=600 - wip_winbase0.infos[0].h - 8};

		local num_buttons = 0;
		switch (engine_version) {
			case "pw":
				this.wip_clkwait_frames = iwait.slice(1, 0, iwait.w, iwait.h).split(55, iwait.h);
				num_buttons = 9;
			break;
			default:
				this.wip_clkwait_frames = iwait.split(iwait.h, iwait.h);
				num_buttons = 7;
			break;
		}
		this.font = Font("lucon.ttf", 19);
		
		buttons = {};
		for (local n = 1; n <= num_buttons; n++) {
			buttons[n] <- {
				index   = n,
				enabled = 0,
				hover   = 0,
			};
		}
		buttons[1].enabled = 1;
		buttons[2].enabled = 1;

		this.position_title = { x = 60, y = screen.h - 152, w = 0, h = 0};
		this.position_body  = { x = 80, y = 512           , w = 0, h = 0};
		this.position_wait  = { x = 595, y = screen.h - 45, w = 0, h = 0 };
		this.color_face     = rgba("FFFFFF");
		this.color_border   = rgba("3C5FAF");

		switch (engine_version) {
			case "pw":
				this.position_title.x = interface_position.x + 52;
				this.position_title.y = interface_position.y + 26;
				this.position_body.x  = interface_position.x + 52;
				this.position_body.y  = interface_position.y + 64;
				this.position_wait.x  = 680;
				this.position_wait.y  = screen.h - 72;
				this.color_border   = rgba("FFA700");
			break;
		}
		
		this.clkwait_tick = 0;
	}
	
	function update(elapsed_time = 0)
	{
		if (!enabled) return;
		
		if (::input.pad_pressing("skip")) {
			this.textProgress = this.text_body.len();
			this.skip = true;
		}

		foreach (button in buttons) {
			if (!button.enabled) continue;
			local rect = wip_winbase0.getRect(button.index, interface_position.x, interface_position.y);
			if (::input.mouseInRect(rect)) {
				if (::input.mouse.clicked(0)) {
					printf("UI Clicked: %d (%s)\n", button.index, object_to_string(rect));
					switch (button.index) {
						case 1: this.rio.opcall("RUN_QLOAD", []); break;
						case 2: this.rio.opcall("RUN_QSAVE", []); break;
					}
					return;
				}
				button.hover = true;
			} else {
				button.hover = false;
			}
		}

		if (::input.mouse.clicked(0) || ::input.pad_pressed("accept")) {
			if (!endedDrawText()) {
				this.textProgress = this.text_body.len();
			} else {
				this.skip = true;
			}
		}

		this.textProgress = clamp(this.textProgress + 1, 0, this.text_body.len());
		this.clkwait_tick++;
	}

	function drawTo(destinationBitmap)
	{
		if (!enabled) return;
		
		// Textbox
		wip_winbase0.drawTo(destinationBitmap, 0, interface_position.x, interface_position.y);

		// Buttons
		foreach (button in buttons) {
			//printf("%d: %d\n", button.index, button.enabled);
			local type = 0;
			if (button.enabled) {
				if (!button.hover) {
					type = 1;
				} else {
					type = 2;
				}
			}
			wip_winbase0.drawTo(destinationBitmap, 1 + (button.index - 1) + (buttons.len() * type), interface_position.x, interface_position.y);
		}
		
		if (this.text_title.len()) {
			wip_winbase0.drawTo(destinationBitmap, 1 + (buttons.len() + 1) * 3, interface_position.x, interface_position.y);
		}
		
		this.font.setSize(text_size);
		font.setSlice(0, textProgress);
		print_text(this.text_body , position_body.x, position_body.y);
		this.font.setSize(1.0);
		font.setSlice(-1, -1);
		print_text(this.text_title, position_title.x, position_title.y);
		
		if (endedDrawText() && waitingSkip) {
			destinationBitmap.drawBitmap(
				wip_clkwait_frames[floor(clkwait_tick / 3) % wip_clkwait_frames.len()],
				position_wait.x,
				position_wait.y
			);
		}
	}
	
	function endedDrawText()
	{
		if (textProgress == -1) return true;
		return (textProgress >= this.text_body.len());
	}
	
	function ended()
	{
		if (textProgress == -1) return true;
		return skip && endedDrawText();
	}

	function print_text(text, x, y)
	{
		this.font.setColor(this.color_border);
		// 3c5faf
		for (local cy = -1; cy <= 1; cy++) {
			for (local cx = -1; cx <= 1; cx++) {
				if (cx != 0 && cy != 0) {
					this.font.print(screen, text, x + cx, y + cy);
				}
			}
		}
		this.font.setColor(this.color_face);
		this.font.print(screen, text, x, y);
	}
}