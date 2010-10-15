class RIO_OP_EFFECTS_base
{
	</ id=0x54, format="s", description="" />
	static function TRANS_IMAGE(name)
	{
		this.scene.maskLayer = ::resman.get_mask(name).images[0];
		this.TODO();
	}

	</ id=0x4A, format="12.", description="" />
	static function TRANSITION(kind, ms_time)
	{
		local effect = null;
		
		switch (kind) {
			case 0: // EFFECT
				// FLAGS: 996, 999 (effect_type related)
				local effect_type = this.state.flags[996];
				switch (effect_type) {
					case 0:
						//this.scene.setEffect("normal");
						//printf("Effect::normal\n");
					break;
					case 1:
						//this.scene.setEffect("invert");
						//printf("Effect::invert\n");
					break;
				}
				this.scene.setEffect("normal");
			break;
			case 13: // TRANSITION MASK (show)
				this.scene.setEffect("transition", {
					blend = 0,
					reverse = 0
				});
				//printf("Effect::transition_show\n");
			break;
			case 42: // TRANSITION MASK (blend)
				this.scene.setEffect("transition", {
					blend = 1,
					reverse = 0
				});
				//printf("Effect::transition_blend\n");
			break;
			default: // UNKNOWN EFFECT
				this.TODO();
			break;
		}
		
		if (ms_time <= 225) {
			input.setVibration(0.2, 0.8, 40 * (300.0 / ms_time.tofloat()), 0);
		}
		
		if (this.skipping()) {
			ms_time /= 5;
		}
		
		this.scene.setEffectTime(ms_time);

		loopUntilAnimationEnds(0);

		this.TODO();
		this.scene.setEffect("normal");
		//printf("-------------------------------\n");
	}
	
	</ id=0x4B, format="1222221", description="" />
	static function ANIMATE_ADD(object_id, inc_x, inc_y, time, unk0, unk1, unk2)
	{
		local anim = this.scene.get(object_id).animation;
		anim.reset(time);
		anim.increment("x", inc_x);
		anim.increment("y", inc_y);
		
		this.TODO();
	}
	
	</ id=0x4C, format="1", description="" />
	static function ANIMATE_PLAY(can_skip)
	{
		//anim.start();
		this.loopUntilAnimationEnds(can_skip);

		this.TODO();
	}

	</ id=0x4D, format="1121", description="" />
	static function EFFECT(kind, duration, quantity, unk1)
	{
		local kinds = [null, "quake", "heat"];
		
		switch (kinds[kind]) {
			case "quake":
				//printf("duration: %d\n", duration);
				::input.setVibration(1.0, 0.0, 50 * duration, 0);
				local ms_time = (duration * 5) * 1000 / fps;
				
				local q = ((quantity + 1) * screen.w) / 255.0;
				//printf("quake: %f, %f\n", q, ms_time);
				this.scene.setEffectTime(ms_time);
				while (!this.ended()) {
					this.scene.x = (rand() % q) - q / 2;
					this.scene.y = (rand() % q) - q / 2;
					//printf("quake: %d, %d\n", this.scene.x, this.scene.y);
					gameStep();
				}
				this.scene.x = 0;
				this.scene.y = 0;
				this.scene.copyDrawLayerToShowLayer();
			break;
			default:
				this.TODO();
				throw("Unprocessed effect: " + kind);
			break;
		}
	}
}

switch (engine_version) {
	case "pw": // For Pricess Waltz.
		class RIO_OP_EFFECTS extends RIO_OP_EFFECTS_base
		{
			</ id=0x4C, format="1.", description="" />
			static function ANIMATE_PLAY(can_skip)
			{
				RIO_OP_EFFECTS_base.ANIMATE_PLAY(can_skip);
			}
		}
	break;
	// For YMK and others.
	default:
	//case "ymk": 
		class RIO_OP_EFFECTS extends RIO_OP_EFFECTS_base
		{
		}
	break;
}