class RIO_OP_EFFECTS
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
				local effect_type = this.state.flag_get(996);
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
			//case 6: // BOXES; // pw0002_1@0FC1
			break;
			//case 9: // DIAGONAL TRANSITION
			break;
			case 11: // COURTAIN TOP-BOTTOM:
			case 12: // COURTAIN BOTTOM-TOP:
			case 13: // COURTAIN LEFT->RIGHT
			case 14: // COURTAIN RIGHT->LEFT
				local mask2 = this.scene.maskLayer2;
				mask2.clear([0, 0, 0, 1]);
				local step_width = 16, wave_width = 64;
				local vertical = (kind == 11) || (kind == 12);
				local reverse  = (kind == 12) || (kind == 14);
				local totalSize = vertical ? 600 : 800;

				for (local n = 0; n < totalSize; n += step_width) {
					local nf = (n.tofloat() / totalSize.tofloat()) * 255;
					local set = [ nf, nf + wave_width ];
					for (local m = 0; m < step_width; m++) {
						local mf = m.tofloat() / step_width.tofloat();
						local value = interpolate(set[0], set[1], mf) / (255.0 + wave_width);
						if (reverse) value = 1.0 - value;
						mask2.setColor([value, 0, 0, 1.0]);
						if (vertical) {
							mask2.drawFillRect(0, n + m, mask2.w, 1);
						} else {
							mask2.drawFillRect(n + m, 0, 1, mask2.h);
						}
					}
				}
				
				//ms_time *= 20;
				
				ms_time *= 2;
				
				//mask2.save("test2.png", "png");
				this.scene.setEffect("transition", {
					blend   = 0,
					reverse = 0,
					mask    = mask2,
				});
			break;
			case 21: // PIXELATE
				this.scene.setEffectCallback(function(scene, destinationBitmap, kind) {
					local effect = Effect("pixelate");
					local pixelSize = 1;
					local maxPixelSize = 40;
					local showBitmap;
					if (scene.stepf < 0.5) {
						local stepf = scene.stepf / 0.5;
						pixelSize = (stepf * maxPixelSize.tofloat()).tointeger();
						showBitmap = scene.showLayer;
					} else {
						local stepf = (scene.stepf - 0.5) / 0.5;
						pixelSize = ((1.0 - stepf) * maxPixelSize.tofloat()).tointeger();
						showBitmap = scene.drawLayer;
					}
					pixelSize = clamp(pixelSize, 1, maxPixelSize).tointeger();
					//printf("pixelSize: %d\n", pixelSize);
					effect.image = showBitmap;
					effect.pixelSize = pixelSize.tofloat();
					Screen.pushEffect(effect);
					{
						destinationBitmap.drawBitmap(showBitmap, 0, 0, 1.0);
					}
					Screen.popEffect();
				}, kind);
			break;
			case 5:
			case 22: // ZOOM IN
			case 34:
				this.scene.setEffectCallback(function(scene, destinationBitmap, kind) {
					local alpha = scene.stepf;
					destinationBitmap.drawBitmap(scene.showLayer, 0, 0, 1.0);
					scene.drawLayer.cx = 400;
					scene.drawLayer.cy = 300;
					if (kind == 5) alpha = 1.0;
					destinationBitmap.drawBitmap(scene.drawLayer, 400, 300, alpha, interpolate(3.0, 1.0, scene.stepf));
					scene.drawLayer.cx = 0;
					scene.drawLayer.cy = 0;
				}, kind);
			break;
			case 35: // ZOOM OUT
				this.scene.setEffectCallback(function(scene, destinationBitmap, kind) {
					local alpha = 1.0 - scene.stepf;

					destinationBitmap.drawBitmap(scene.drawLayer, 0, 0, 1.0);

					scene.showLayer.cx = 400;
					scene.showLayer.cy = 300;
					destinationBitmap.drawBitmap(scene.showLayer, 400, 300, alpha, interpolate(1.0, 3.0, scene.stepf));
					scene.showLayer.cx = 0;
					scene.showLayer.cy = 0;
				}, kind);
			break;
			case 23: // TRANSITION MASK (NO BLEND) (REVERSED=0)
			case 24: // TRANSITION MASK (NO BLEND) (REVERSED=1)
				this.scene.setEffect("transition", {
					blend   = 0,
					reverse = ((kind == 24) ? 1 : 0),
					mask    = this.scene.maskLayer,
				});
				ms_time *= 2;
				//printf("Effect::transition_hide_show\n");
			break;
			case 25: // TRANSITION NORMAL FADE IN (alpha)
				this.scene.setEffect("normal");
			break;
			case 26: // TRANSITION NORMAL FADE IN BURN (alpha)
				this.scene.setEffectCallback(function(scene, destinationBitmap, kind) {
					destinationBitmap.drawBitmap(scene.showLayer, 0, 0, 1.0);
					destinationBitmap.setBlending("burn"  ); destinationBitmap.drawBitmap(scene.drawLayer, 0, 0, scene.stepf * 2.0);
					destinationBitmap.setBlending("normal"); destinationBitmap.drawBitmap(scene.drawLayer, 0, 0, (scene.stepf - 0.5) * 2.0);
					// @TODO: Check this works.
					//destinationBitmap.setBlending("burn"  ); destinationBitmap.drawBitmap(scene.drawLayer, 0, 0, convertRange(scene.stepf, 0.0, 0.5, 0.0, 1.0));
					//destinationBitmap.setBlending("normal"); destinationBitmap.drawBitmap(scene.drawLayer, 0, 0, convertRange(scene.stepf, 0.5, 1.0, 0.0, 1.0));
				}, kind);
				//this.TODO();
				// Burn effect. glBlendFunc 
			break;
			case 28: // BOTTOM->TOP EFFECT
			case 29: // TOP->BOTTOM EFFECT
			case 30: // RIGHT->LEFT EFFECT
			case 31: // LEFT->RIGHT EFFECT
				//this.scene.setEffect("normal");
				this.scene.setEffectCallback(function(scene, destinationBitmap, kind) {
					local vector = {x=0, y=0};
					
					switch (kind) {
						case 28: vector = {x= 0, y=-1}; break;
						case 29: vector = {x= 0, y= 1}; break;
						case 30: vector = {x=-1, y= 0}; break;
						case 31: vector = {x= 1, y= 0}; break;
					}
					
					destinationBitmap.drawBitmap(scene.showLayer, 0, 0);
					destinationBitmap.drawBitmap(
						scene.showLayer,
						(scene.stepf * 800) * vector.x,
						(scene.stepf * 600) * vector.y,
						1.0 - scene.stepf
					);
					destinationBitmap.drawBitmap(
						scene.drawLayer,
						(scene.stepf * 800) * vector.x - (800 * vector.x),
						(scene.stepf * 600) * vector.y - (600 * vector.y),
						scene.stepf
					);
				}, kind);
				//ms_time *= 2;
			break;
			case 36: // WAVE
				//ms_time *= 2;
				this.scene.setEffectCallback(function(scene, destinationBitmap, kind) {
					destinationBitmap.drawBitmap(scene.showLayer, 0, 0);
					
					local effect = Effect("wave");
					effect.amplitude    = sin(scene.stepf * 3.145982 * 2) * 80.0;
					effect.width        = 200.0;
					effect.displacement = scene.stepf * 200.0;
					//effect.width     = [240.0, 0.0];
					effect.alpha     = scene.stepf;
					
					destinationBitmap.drawBitmap(scene.drawLayer, 0, 0, 1.0);

					Screen.pushEffect(effect);
					{
						destinationBitmap.drawBitmap(scene.drawLayer, 0, 0, 1.0);
					}
					Screen.popEffect();
				}, kind);
			break;
			case 40: // ROTATE CLOCK WISE
				this.scene.setEffectCallback(function(scene, destinationBitmap, kind) {
					destinationBitmap.drawBitmap(scene.showLayer, 0, 0);
					scene.drawLayer.cx = 400;
					scene.drawLayer.cy = 300;
					destinationBitmap.drawBitmap(scene.drawLayer, 400, 300, scene.stepf, 1.0, scene.stepf * PI * 2.0);
					scene.drawLayer.cx = 0;
					scene.drawLayer.cy = 0;
				}, kind);
			break;
			//case 43: // STRETCHING EFFECT (pw0002_1@A5D2)
			break;
			case 42: // TRANSITION MASK (blend)
			case 44: // TRANSITION MASK (blend) (reverse)
				this.scene.setEffect("transition", {
					blend   = 1,
					reverse = (kind == 44) ? 1 : 0,
					mask    = this.scene.maskLayer,
				});
				//printf("Effect::transition_blend\n");
			break;
			default: // UNKNOWN EFFECT
				this.scene.setEffect("normal");
				this.TODO();
			break;
		}
		
		//this.TODO();
		
		if (ms_time <= 225 && ms_time > 10) {
			input.setVibration(0.2, 0.8, 40 * (300.0 / ms_time.tofloat()), 0);
		}
		
		if (this.skipping()) {
			ms_time /= 5;
		}
		
		this.scene.setEffectTime(ms_time);

		loopUntilAnimationEnds(0);

		//this.TODO();
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
		
		if (object_id == 0) {
			inc_x = -inc_x;
			inc_y = -inc_y;
		}
		
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
		local kind_name = (kind in kinds) ? kinds[kind] : "unknown";
		
		printf("EFFECT(%d('%s'), %d, %d, %d)\n", kind, kind_name, duration, quantity, unk1);
		
		
		switch (kind_name) {
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
				printf("Unprocessed effect: " + kind);
				//throw("Unprocessed effect: " + kind);
			break;
		}
	}
}
