class RIO_OP_EFFECTS_base
{
	</ id=0x54, format="s", description="" />
	static function TRANS_IMAGE(name)
	{
		this.scene.maskLayer = ::resman.get_mask(name).images[0];
		this.TODO();
	}

	</ id=0x4A, format="121", description="" />
	static function TRANSITION(kind, ms_time, unk1)
	{
		local effect = null;
		//if (ms_time == 0) ms_time = 1;
		
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
		
		if (ms_time <= 225 && ms_time > 10) {
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
	static function ANIMATE_ADD(object_id, inc_x, inc_y, time, unk0, alpha, unk2)
	{
		if (this.skipping()) {
			time /= 5;
		}
		local object = this.scene.get(object_id);
		local anim = object.animation;
		anim.reset(time);
		anim.increment("x", inc_x);
		anim.increment("y", inc_y);
		if (alpha == -1) {
			anim.set("alpha", 1.0, 0.0);
		} else if (alpha == 1) {
			anim.set("alpha", 0.0, 1.0);
		}
		
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
		
		printf("EFFECT(%d, %d, %d, %d)\n", kind, duration, quantity, unk1);
		
		switch (kinds[kind]) {
			case "quake":
				if (duration >= 255) duration = 20;
				//printf("duration: %d\n", duration);
				::input.setVibration(1.0, 0.0, 50 * duration, 0);
				local ms_time = (duration * 5) * 1000 / fps;
				
				local q = ((quantity + 1) * screen.w) / 255.0;
				//printf("quake: %f, %f\n", q, ms_time);
				this.scene.setEffectTime(ms_time);
				while (!this.ended()) {
					this.scene.x = rand_between(-q, q);
					this.scene.y = rand_between(-q, q);
					//printf("quake: %d, %d\n", this.scene.x, this.scene.y);
					gameStep();
				}
				this.scene.x = 0;
				this.scene.y = 0;
				this.scene.copyDrawLayerToShowLayer();
				gameStep();
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