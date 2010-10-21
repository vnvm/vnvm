class Scene extends Component
{
	background  = null;
	table       = null;
	sprites_l1  = null;
	sprites_l2  = null;
	overlay     = null;
	all         = null;
	allUpdate   = null;
	allDraw     = null;
	drawLayer   = null;
	tempLayer   = null;
	maskLayer   = null;
	maskLayer2  = null;
	showLayer   = null;
	effect      = null;
	effectTimer = null;
	state       = null;
	stepf       = 0.0;
	effectCallback = null;
	effectCallbackParameter = null;
	x = 0;
	y = 0;
	
	not_ended_object = "<none>";
	
	constructor(state = null)
	{
		this.all        = array(8);
		this.sprites_l1 = array(3);
		this.sprites_l2 = array(3);

		for (local n = 0; n < 8; n++) this.all[n] = SceneObject(null);

		this.background    = this.all[0]; this.background.type = "background";
		this.sprites_l1[0] = this.all[1]; this.sprites_l1[0].type = "sprites_l1[0]";
		this.sprites_l1[1] = this.all[2]; this.sprites_l1[1].type = "sprites_l1[1]";
		this.sprites_l1[2] = this.all[3]; this.sprites_l1[2].type = "sprites_l1[2]";
		this.sprites_l2[0] = this.all[4]; this.sprites_l2[0].type = "sprites_l2[0]";
		this.sprites_l2[1] = this.all[5]; this.sprites_l2[1].type = "sprites_l2[1]";
		this.sprites_l2[2] = this.all[6]; this.sprites_l2[2].type = "sprites_l2[2]";
		this.overlay       = this.all[7]; this.overlay.type = "overlay";
		
		this.state         = state;
		this.table         = SceneTable(state);

		this.drawLayer     = Bitmap(screen.w, screen.h);
		this.maskLayer     = Bitmap(screen.w, screen.h);
		this.maskLayer2    = Bitmap(screen.w, screen.h);
		this.showLayer     = Bitmap(screen.w, screen.h);
		this.tempLayer     = Bitmap(screen.w, screen.h);
		
		this.maskLayer2.clear([0, 0, 0, 1]);
		
		this.x = 0;
		this.y = 0;
		this.stepf = 0.0;
		
		this.effectTimer = TimerComponent(0);
		
		setEffect("normal");
		
		this.allDraw = [];
		this.allDraw.push(background);
		this.allDraw.push(table);
		foreach (object in this.all.slice(1)) this.allDraw.push(object);
		
		this.allUpdate = all;
	}
	
	function get(object_id)
	{
		if (object_id < 0 || object_id >= all.len()) {
			printf("WARNING: Invalid object_id('%d')\n", object_id);
			//throw(format("WARNING: Invalid object_id('%d')\n", object_id));
			//return all[0];
		}
		return all[object_id % all.len()];
	}
	
	function setEffect(effectName, extraParams = {})
	{
		printf("setEffect('%s')\n", effectName);
		this.effect = Effect(effectName);
		this.effect.image = drawLayer;
		//this.effect.mask  = maskLayer;
		foreach (k, v in extraParams) {
			this.effect[k] = v;
		}
		setEffectCallback(normalEffectCallback);
	}
	
	function normalEffectCallback(scene, destinationBitmap, param)
	{
		if ((scene.x != 0) || (scene.y != 0)) {
			destinationBitmap.drawBitmap(scene.showLayer, 0, 0);
		}

		if (scene.stepf < 1) {
			destinationBitmap.drawBitmap(scene.showLayer, scene.x, scene.y);
		}
		if (scene.stepf > 0) {
			Screen.pushEffect(scene.effect);
			{
				destinationBitmap.drawBitmap(scene.drawLayer, scene.x, scene.y, 1.0, 1.0);
			}
			Screen.popEffect();
		}
	}
	
	function setEffectCallback(callback, param = null)
	{
		this.effectCallback = callback;
		this.effectCallbackParameter = param;
	}
	
	function setEffectTime(time = 0)
	{
		this.effectTimer = TimerComponent(time);
	}
	
	/**
	 * Updates the animations
	 */
	function update(elapsed_time)
	{
		effectTimer.update(elapsed_time);
		table.update(elapsed_time);
		foreach (obj in all) {
			obj.update(elapsed_time);
			//obj.animation.timer.update(elapsed_time);
		}
		// Updates effect step.
		this.stepf = this.effectTimer.elapsedf;
		this.effect.step = this.stepf;
		//printf("%f\n", this.stepf);
	}

	function ended()
	{
		local v = ended2();
		//printf("ended():%d : %s\n", v ? 1 : 0, not_ended_object);
		return v;
	}
	
	function ended2()
	{
		//printf("++++++\n");
		foreach (n, obj in all) if (!obj.ended()) {
			this.not_ended_object = format("%d:%s", n, obj.animation.timer.tostring());
			return false;
		}
		if (!this.effectTimer.ended) {
			this.not_ended_object = "-1";
			return false;
		}
		//printf("------\n");
		return true;
	}
	
	function updateDrawLayer()
	{
		this.drawLayer.clear([0, 0, 0, 1]);
		foreach (obj in allDraw) {
			obj.drawTo(this.drawLayer);
		}

		if (this.state.flags[999]) {
			this.tempLayer.clear([0, 0, 0, 1]); this.tempLayer.drawBitmap(this.drawLayer);
			
			local effect = Effect("postEffect");
			local eftype = this.state.flags[999].tointeger();
			effect.image = this.tempLayer;
			switch (eftype) {
				case 1:
					effect.eftype = 1;
				break;
				case 2:
					effect.color = rgb("ffffff");
					effect.eftype = 3;
				break;
				case 3:
					effect.color = rgb("efca97");
					effect.eftype = 3;
				break;
				default:
					effect.eftype = eftype;
				break;
			}
			Screen.pushEffect(effect);
			{
				this.drawLayer.drawBitmap(this.tempLayer, 0, 0, 1.0, 1.0);
			}
			Screen.popEffect();
		}
	}
	
	function copyDrawLayerToShowLayer()
	{
		this.showLayer.clear([0, 0, 0, 1]);
		this.showLayer.drawBitmap(this.drawLayer, 0, 0, 1.0, 1.0);
	}
	
	function drawTo(destinationBitmap)
	{
		destinationBitmap.clear([0, 0, 0, 1]);

		if ((x != 0) || (y != 0)) {
			destinationBitmap.drawBitmap(this.showLayer, 0, 0);
		}

		if (this.stepf < 1) {
			destinationBitmap.drawBitmap(this.showLayer, x, y);
		}

		if (this.stepf > 0) {
			this.updateDrawLayer();
		}
		
		effectCallback(this, destinationBitmap, this.effectCallbackParameter);
	}
	
	function saveStream(stream)
	{
		foreach (v in all) v.saveStream(stream);
	}

	function loadStream(stream)
	{
		foreach (v in all) v.loadStream(stream);
	}
}

class SceneTable extends Component
{
	anim  = null;
	table = null;
	mustUpdate = false;
	flag_move_click = -1;
	flag_mask_kind  = -1;
	
	constructor(state = null)
	{
		this.anim  = ANM();
		this.table = TBL();

		this.flag_move_click = -1;
		this.flag_mask_kind  = -1;

		this.table.state = state;
		mustUpdate = false;
	}
	
	function update(elapsed_time)
	{
		//if (!enabled) return;
		if (!mustUpdate) return;

		local click = 0;
		local mask_kind = 0;

		if (input.pad_pressed("up"    )) { this.table.keymap_move( 0, -1); this.table.using_mouse = false; }
		if (input.pad_pressed("down"  )) { this.table.keymap_move( 0,  1); this.table.using_mouse = false; }
		if (input.pad_pressed("left"  )) { this.table.keymap_move(-1,  0); this.table.using_mouse = false; }
		if (input.pad_pressed("right" )) { this.table.keymap_move( 1,  0); this.table.using_mouse = false; }
		if (input.pad_pressed("accept")) { click =  1; this.table.using_mouse = false; }
		if (input.pad_pressed("cancel")) { click = -1; this.table.using_mouse = false; }

		//printf("@@@@@@@@@POSITION: (%d, %d, %d)\n", this.table.position.x, this.table.position.y, this.table.position.kind);
		if (input.mouseMoved()) {
			this.table.using_mouse = true;
		}
		
		if (this.table.using_mouse) {
			mask_kind = this.table.mask.images[0].getpixel(input.mouse.x, input.mouse.y);
			if (!this.table.tbl_enable(mask_kind)) {
				mask_kind = 0;
			} else {
				this.table.keymap_goto_kind(mask_kind);
			}
		} else {
			mask_kind = this.table.position.kind;
		}
		
		if (input.mouse.clicked(0)) click = 1;
		if (input.mouse.clicked(2)) { click = -1; mask_kind = 0; }

		
		if (flag_move_click != -1) this.table.state.flag_set(flag_move_click, click);
		if (flag_mask_kind  != -1) this.table.state.flag_set(flag_mask_kind, mask_kind);
		
		flag_move_click = -1;
		flag_mask_kind = -1;
	}
	
	function drawTo(destinationBitmap)
	{
		if (!enabled) return;

		this.anim.drawTo(destinationBitmap);
	}
}

class SceneObject extends Component
{
	type = null;
	x = 0;
	y = 0;
	cx = 0;
	cy = 0;
	alpha = 1.0;
	size = 1.0;
	rotation = 0.0;
	name = "";
	//wip = null;
	animation = null;
	index = 0;
	color = null;
	
	function saveStream(stream)
	{
		stream.writen(enabled ? 1 : 0, 'b');
		stream.writen(index, 'i');
		stream.writen(x, 'i');
		stream.writen(y, 'i');
		stream.writen(cx, 'i');
		stream.writen(cy, 'i');
		stream.writen(alpha, 'f');
		stream.writen(size, 'f');
		stream.writen(rotation, 'f');
		_writestringz(stream, name);
	}

	function loadStream(stream)
	{
		enabled  = stream.readn('b') ? true : false;
		index    = stream.readn('i');
		x        = stream.readn('i');
		y        = stream.readn('i');
		cx       = stream.readn('i');
		cy       = stream.readn('i');
		alpha    = stream.readn('f');
		size     = stream.readn('f');
		rotation = stream.readn('f');
		name     = stream.readstringz(-1);
	}

	constructor(type = null)
	{
		this.type      = type;
		this.x         = 400;
		this.y         = 300;
		this.index     = 0;
		this.alpha     = 1.0;
		this.size      = 1.0;
		this.rotation  = 0.0;
		this.color     = null;
		this.name      = "";
		this.animation = Animation(this);
		/*if (type == "background") {
			this.cx = 800;
			this.cy = 600;
		}*/
	}
	
	function update(elapsed_time)
	{
		if (!enabled) return true;
		return animation.update(elapsed_time);
	}
	
	function ended()
	{
		if (!enabled) return true;
		return animation.ended();
	}
	
	function setXY(x, y, anchorX, anchorY)
	{
		local wip = resman.get_image(name);
		cx = wip.images[0].w / 2;
		cy = wip.images[0].h / 2;
		this.x = x + cx;
		this.y = y + cy;
	}
	
	function drawTo(destinationBitmap)
	{
		//printf("SceneObject.drawTo('%s') : '%d'\n", type, enabled ? 1 : 0);
		if (!enabled) return;
		if (color != null) {
			destinationBitmap.clear(color);
		} else {
			local wip = resman.get_image(name);
			local rx = x, ry = y;
			wip.images[0].cx = cx;
			wip.images[0].cy = cy;
			/*if (type == "background") {
				//rx = -x; ry = -y;
				//resman.get_image(name).images[0].cx = 400;
				//resman.get_image(name).images[0].cy = 300;
				printf("%d, %d\n", rx, ry);
			}*/
			wip.drawTo(destinationBitmap, index, rx, ry, alpha, size, rotation);
		}
	}
}
