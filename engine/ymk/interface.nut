class Interface extends Component
{
	text_title   = "";
	text_body    = "";
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

	constructor()
	{
		this.text_title = "";
		this.text_body  = "";
		this.text_size = 1.0;
		
		this.waitingSkip = true;

		this.wip_clkwait = resman.get_image("CLKWAIT", 0);
		
		local iwait = wip_clkwait.images[0];
		
		switch (engine_version) {
			case "pw":
				this.wip_clkwait_frames = iwait.slice(1, 0, iwait.w, iwait.h).split(55, iwait.h);
			break;
			default:
				this.wip_clkwait_frames = iwait.split(iwait.h, iwait.h);
			break;
		}
		this.font = Font("lucon.ttf", 19);

		this.position_title = { x = 60, y = screen.h - 152, w = 0, h = 0};
		this.position_body  = { x = 80, y = 512           , w = 0, h = 0};
		this.position_wait  = { x = 595, y = screen.h - 45, w = 0, h = 0 };
		this.color_face     = rgba("FFFFFF");
		this.color_border   = rgba("3C5FAF");

		switch (engine_version) {
			case "pw":
				this.position_title.y = screen.h - 166;
				this.position_title.x = 90;
				this.position_body.y = 512 - 40;
				this.position_wait.x = 680;
				this.position_wait.y = screen.h - 72;
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
		
		local wip = resman.get_image("WINBASE0", 0);
		local x = 800 / 2 - wip.infos[0].w / 2;
		local y = 600 - wip.infos[0].h;
		
		local num_buttons;
		
		switch (engine_version) {
			case "pw":
				num_buttons = 10;
			break;
			default:
				num_buttons = 8;
			break;
		}
		
		for (local n = 0; n < num_buttons; n++) {
			wip.drawTo(destinationBitmap, n, x, y);
		}
		
		if (this.text_title.len()) {
			wip.drawTo(destinationBitmap, num_buttons * 3 + 1, x, y);
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