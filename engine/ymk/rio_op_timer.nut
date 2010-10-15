class RIO_OP_TIMER
{
	</ id=0x05, format="1", description="Wait until the timer reaches 0" />
	static function TIMER_WAIT(can_skip)
	{
		while (this.state.timer > 0) {
			this.input_update();
			if (can_skip && mouse.click_left) break;
			this.frame_tick();
		}
	}
	
	</ id=0x0B, format="2", description="Sets the timer in ticks. Each tick is 1 frame. And the game runs at 25fps. 40 ticks = 1 second." />
	static function TIMER_SET(ticks)
	{
		this.state.timer_max = this.state.timer = ticks;
	}

	</ id=0x0C, format="21", description="Decreases the timer and returns true if reached 0." />
	static function TIMER_DEC(flag, param)
	{
		if (this.state.timer > 0) this.state.timer--;
		this.state.flags[flag % State.MAX_FLAGS] = (this.state.timer <= 0) ? 1 : 0;
		return this.state.timer;
		//this.TODO();
	}

	</ id=0x82, format="2.", description="" />
	static function WAIT(delay_ms)
	{
		if (!this.skipping()) {
			Screen.delay(delay_ms);
		}
	}

	</ id=0x86, format="2", description="" />
	static function UNK_86(unk1)
	{
		//this.TODO();
		Screen.delay(unk1);
	}
}
