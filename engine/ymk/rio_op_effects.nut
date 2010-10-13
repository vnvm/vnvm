class Animation
{
	from = {};
	to = {};
	updateObject = null;
	timer = null;

	constructor(updateObject = null, totalTime = 0)
	{
		this.from = {};
		this.to = {};
		this.timer = Timer(totalTime);
		this.updateObject = updateObject;
	}
	
	function increment(key, inc = 0)
	{
		this.from[key] <- this.updateObject[key];
		this.to[key] <- this.from[key] + inc;
	}
	
	function ended()
	{
		return this.timer.ended();
	}
	
	function start()
	{
		this.timer.reset();
	}
	
	function update()
	{
		foreach (k, v in from) {
			local f = from[k], t = to[k];
			local v = interpolate(f, t, this.timer.elapsedf);
			updateObject[k] = v;
			//print("Animation::update::" + k + " = " + v + "\n");
		}
	}
}

class RIO_OP_EFFECTS_base
{
	</ id=0x4A, format="12.", description="" />
	static function TRANSITION(kind, time)
	{
		local step = 0.0;
		local nsteps = floor((time * this.fps) / 1000.0).tofloat();
		//printf("nsteps: %f\n", nsteps);
		this.input_update();
		//if (!this.mouse.press_left) {
		if (nsteps == 0.0) step = nsteps = 1.0;
		
		this.updateSceneLayer();
		local effect = null;
		
		switch (kind) {
			case 0: // EFFECT
				// FLAGS: 996, 999 (effect_type related)
				local effect_type = this.state.flags[996];
				switch (effect_type) {
					case 0:
						effect = Effect("normal");
						effect.image = sceneLayerDraw;
						printf("Effect::normal\n");
					break;
					case 1:
						effect = Effect("invert");
						effect.image = sceneLayerDraw;
						printf("Effect::invert\n");
					break;
				}
			break;
			case 42: // TRANSITION MASK
				effect = Effect("transition");
				effect.image = sceneLayerDraw;
				effect.mask = this.maskWip.images[0];
				effect.reverse = 0;
				printf("Effect::transition\n");
			break;
			default: // UNKNOWN EFFECT
				this.TODO();
			break;
		}

		while (step <= nsteps) {
			this.input_update();
			
			//if (mouse.click_left) step = nsteps;
			if (this.skipping()) step = nsteps;

			local fstep = step / nsteps;
			
			// Clears layer.
			sceneLayerMixed.clear([0, 0, 0, 1]);
			
			// Draws previous layer.
			sceneLayerMixed.drawBitmap(sceneLayerShow);

			// Draws the new layer using an effect.
			if (effect != null) {
				Screen.pushEffect(effect);
				{
					effect.step = fstep;
					sceneLayerMixed.drawFillRect();
				}
				Screen.popEffect();
			} else {
				sceneLayerMixed.drawBitmap(sceneLayerDraw, 0, 0, fstep);
			}
			
			// Draws mixed layer and interface and performs a frame.
			screen.drawBitmap(sceneLayerMixed);
			if (draw_interface) frame_draw_interface();
			this.frame_tick();
			step++;
		}

		sceneLayerShow.clear([0, 0, 0, 1]);
		sceneLayerShow.drawBitmap(sceneLayerMixed, 0, 0, 1.0);
	}
	
	</ id=0x4B, format="1222221", description="" />
	static function ANIMATE_ADD(object_id, inc_x, inc_y, time, unk0, unk1, unk2)
	{
		local object;
		
		switch (object_id) {
			case 0: object = this.state.background; break;
			case 1: object = this.state.sprites_l1[0]; break;
			case 2: object = this.state.sprites_l1[1]; break;
			case 3: object = this.state.sprites_l1[2]; break;
		}
		
		local anim = Animation(object, time);
		anim.increment("x", inc_x);
		anim.increment("y", inc_y);
		object.animation <- anim;

		this.TODO();
	}
	
	</ id=0x4C, format="1", description="" />
	static function ANIMATE_PLAY(can_skip)
	{
		local objects = [this.state.background, this.state.sprites_l1[0], this.state.sprites_l1[1], this.state.sprites_l1[2]];
		local ended;
		foreach (object in objects) {
			if (!("animation" in object)) continue;
			local anim = object.animation;
			if (!anim) continue;
			anim.start();
		}
		do {
			ended = true;
			foreach (object in objects) {
				if (!("animation" in object)) continue;
				local anim = object.animation;
				if (!anim) continue;
				if (!anim.ended()) ended = false;
				anim.update();
			}
			updateSceneLayer();
			screen.clear([0, 0, 0, 1]);
			screen.drawBitmap(sceneLayerDraw);
			if (draw_interface) frame_draw_interface();
			this.frame_tick();
		} while (!ended);
		
		sceneLayerShow.clear([0, 0, 0, 1]);
		sceneLayerShow.drawBitmap(sceneLayerDraw, 0, 0, 1.0);

		foreach (object in objects) {
			if (!("animation" in object)) continue;
			object.animation = null;
		}

		this.TODO();
	}

	</ id=0x4D, format="1121", description="" />
	static function EFFECT(kind, duration, quantity, unk1)
	{
		local kinds = [null, "quake", "heat"];
		
		switch (kinds[kind]) {
			case "quake":
				duration *= 5;
				while (duration-- > 0) {
					this.input_update();

					local q = ((quantity + 1) * screen.w) / 0xFF;
					local x = (rand() % q) - q / 2;
					local y = (rand() % q) - q / 2;

					screen.drawBitmap(sceneLayerShow, x, y);
					if (draw_interface) frame_draw_interface();
						
					frame_tick();
				}
			break;
			default:
				this.TODO();
				throw("Unprocessed effect: " + kind);
			break;
		}
	}

	</ id=0x54, format="s", description="" />
	static function TRANS_IMAGE(name)
	{
		this.state.mask = name;
		this.maskWip = ::resman.get_mask(name);
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