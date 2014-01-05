package engines.will.script;
/*
SPECIAL FLAGS:
	993 - TEXT_SPEED
	996 - DISABLE SAVE

PRINCESS WALTZ:
	sub_406F00
*/

import reflash.display.HtmlColors;
import lang.signal.Signal;
import lang.promise.Deferred;
import common.input.Keys;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.events.Event;
import common.input.GameInput;
import common.geom.Anchor;
import haxe.Log;
import lang.time.Timer2;
import lang.MathEx;
import common.BitUtils;
import lang.exceptions.NotImplementedException;
import flash.errors.Error;
class RIO_OP
{
	private var scene:IScene;
	private var state:GameState;
	private var script:IScript;
	private var clicked:Bool;

	public function new(scene:IScene, state:GameState, script:IScript)
	{
		this.scene = scene;
		this.state = state;
		this.script = script;
		GameInput.onClick.add(function(e) {
			clicked = true;
		});
	}

	/*
		pw0001@04DC: OP(0x86) : UNK_86_DELAY : [230,0]
		pw0001@04DC: OP(0x86) : UNK_86_DELAY : [230,0]...  @TODO
		pw0001@04DF: OP(0x01) : JUMP_IF : [3,998,0,20]
		pw0001@04EA: OP(0x03) : SET : [1,996,0,1]
		**SET 996=1
		pw0001@04F2: OP(0x82) : WAIT : [1000,0]
	*/

	@Opcode({ id:0x86, format:"11", description:"" })
	public function UNK_86_DELAY(unk1, unk2)
	{

		//throw(new NotImplementedException());
		/*
		if (unk1 > 0)
		{
			//this.interface.enabled = false;
			//this.interface.enabled = 0;
			//gameStep();
		}
		this.TODO();
		//Screen.delay(unk1);
		*/
	}

	@Opcode({ id:0x55, format:"1", description:"" })
	public function UNK_55(unk:Int)
	{
		//scene.setDirectMode(true);
		//this.interface.enabled = false;
		//gameStep();
		//this.interface.enabled = false;
		/*
		this.interface.enabled = true;
		this.interface.text_title = "";
		this.interface.text_body = "";
		*/
		//this.TODO();
	}

	@Opcode({ id:0x29, format:"22", description:"" })
	public function UNK_29(param1:Int, param2:Int)
	{
	}

	@Opcode({ id:0x30, format:"22", description:"" })
	public function UNK_30(param1:Int, param2:Int)
	{
	}

	@Opcode({ id:0x61, format:"1s", description:"" })
	public function MOVIE(can_stop:Int, name:String)
	{
		throw(new NotImplementedException());

		/*
		local movie = Movie();
		local movie_buffer = movie.load(path_to_files + "/" + name);
		movie.viewport(0, 0, screen.w, screen.h);
		movie.play();
		local timer = TimerComponent(500);
		movie_buffer.cx = 400;
		movie_buffer.cy = 300;
		while (movie.playing) {
			input.update();

			if (can_stop && timer.ended && pressedNext()) break;

			timer.update(this.ms_per_frame);
			movie.update();
			screen.drawBitmap(movie_buffer, 400, 300, 1.0, 1.0, 0.0);
			//this.interface.print_text("Hello", 100, 100);
			_Screen.flip();
			_Screen.frame(30);
		}
		this.scene.showLayer.clear([0, 0, 0, 1]);
		this.scene.showLayer.drawBitmap(movie_buffer, 400, 300, 1.0, 1.0);
		movie.stop();
		*/
	}

	@Opcode({ id:0x4E, format:"4", description:"" })
	public function UNK_4E(param:Int)
	{
	}

	@Opcode({ id:0x76, format:"441", description:"" })
	public function UNK_76(unk1:Int, unk2:Int, unk3:Int)
	{
	}

	@Opcode({ id:0x62, format:"1", description:"" })
	public function UNK_62(param:Int)
	{
	}

	@Opcode({ id:0x85, format:"2", description:"" })
	public function UNK_85(param:Int)
	{
		// @TODO: Maybe related with being able to save?
	}

	@Opcode({ id:0x89, format:"1", description:"" })
	public function UNK_89(unk:Int)
	{
	}

	@Opcode({ id:0x8C, format:"21", description:"" })
	public function UNK_8C(unk1:Int, unk2:Int)
	{
		//scene.setDirectMode(false);
	}

	@Opcode({ id:0x8E, format:"1", description:"" })
	public function UNK_8E(param:Int)
	{
	}

	@Opcode({ id:0xBD, format:"2", description:"" })
	public function UNK_BD(param:Int)
	{
	}

	@Opcode({ id:0xBE, format:"1", description:"" })
	public function UNK_BE(param:Int)
	{
	}

	@Opcode({ id:0xBC, format:"22", description:"" })
	public function UNK_BC(param1:Int, param2:Int)
	{
	}

	@Opcode({ id:0xE5, format:"1", description:"" })
	public function UNK_E5(param:Int)
	{
	}

	/*
	@Opcode({ id:0xE6, format:"...", description:"" })
	public function UNK_E6()
	{
		this.TODO();
	}
	*/

	/////////////////////////////////////////////////////////////////////////////////////
	// ANIM                                                                            //
	/////////////////////////////////////////////////////////////////////////////////////

	@Opcode({ id:0x43, format:"42s", description:"" })
	public function TABLE_ANIM_LOAD(unk1:Int, unk1:Int, file:String)
	{
		return scene.animLoadAsync(file);
		/*
		this.scene.table.anim.load(file);
		this.scene.table.enabled = true;
		this.scene.background.enabled = false;
		*/
	}

	@Opcode({ id:0x45, format:"121", description:"" })
	public function TABLE_ANIM_OBJECT_PUT(unk1:Int, index:Int, unk2:Int)
	{
		//throw(new NotImplementedException());
		return this.scene.setAnimObjectVisibility(index, true);

		//this.scene.table.anim.active_set(index, 1);
	}

	@Opcode({ id:0x4F, format:"121", description:"" })
	public function TABLE_ANIM_OBJECT_UNPUT(unk1:Int, index:Int, unk2:Int)
	{
		return this.scene.setAnimObjectVisibility(index, false);
		//throw(new NotImplementedException());

		//this.scene.table.anim.active_set(index, 0);
	}

	@Opcode({ id:0x50, format:"s", description:"" })
	public function TABLE_TABLE_LOAD(table_name:String)
	{
		return scene.tableLoadAsync(table_name);
	}

	@Opcode({ id:0x51, format:"ff1", description:"" })
	@SkipLog
	public function TABLE_PICK(flagMaskClick:Int, flagMaskOver:Int, unk1:Int)
	{
		scene.setDirectMode(true);

		var deferred = new Deferred<Dynamic>();
		var mousePosition:Point = scene.getMousePosition();
		var overKind1:Int = scene.getMaskValueAt(mousePosition);
		var overKind:Int = scene.isEnabledKind(overKind1) ? overKind1 : 0;
		//Log.trace('$mousePosition: $overKind1: $overKind');

		function onClick() {
			//throw(new Error("onClick!"));
			this.state.setFlag(flagMaskClick, (overKind != 0) ? 1 : 0);
			this.state.setFlag(flagMaskOver, overKind);
			clicked = false;
			deferred.resolve(null);
		}

		function onMove() {
			this.state.setFlag(flagMaskClick, 0);
			this.state.setFlag(flagMaskOver, overKind);
			clicked = false;
			deferred.resolve(null);
		}

		if (clicked)
		{
			onClick();
		}
		else
		{
			Signal.addAnyOnce([GameInput.onClick, GameInput.onMouseMoveEvent], function(e:MouseEvent) {
				if (e.type == MouseEvent.CLICK || e.type == MouseEvent.MOUSE_DOWN) {
					onClick();
				} else {
					onMove();
				}
			});
		}

		return deferred.promise;
		//throw(new NotImplementedException());
		/*
		this._interface.enabled = false;
		this.scene.table.flag_move_click = flag_move_click;
		this.scene.table.flag_mask_kind = flag_mask_kind;
		//this.TODO();
		this.scene.table.mustUpdate = true;
		gameStep();
		this.scene.table.mustUpdate = false;
		*/
	}

	/////////////////////////////////////////////////////////////////////////////////////
	// AUDIO                                                                           //
	/////////////////////////////////////////////////////////////////////////////////////

	@Opcode({ id:0x22, format:"121", description:"" })
	public function MUSIC_STOP(unk:Int, fadeout_ms:Int, idx:Int)
	{
		return this.scene.soundPlayStopAsync('music', null, fadeout_ms);
	}

	// 23 - VOICE_PLAY idx, u2, u3, kind(girl=0,boy=1), unk4, voice_file   //
	@Opcode({ id:0x23, format:"12112s", description:"" })
	public function VOICE_PLAY(channel:Int, u2:Int, u3:Int, kind:Int, unk4:Int, voice_file:String)
	{
		return this.scene.soundPlayStopAsync('voice', voice_file, 0);
	}

	@Opcode({ id:0x26, format:"2", description:"" })
	public function SOUND_STOP(channel:Int)
	{
		Log.trace('SOUND_STOP: $channel');
		return this.scene.soundPlayStopAsync('sound', null, 0);
		//throw(new NotImplementedException());

		//Audio.channelStop(channel);
	}

	@Opcode({ id:0x52, format:"2", description:"" })
	@Unimplemented
	public function SOUND_WAIT(channel:Int)
	{
		//throw(new NotImplementedException());
		/*
		while (Audio.channelProgress(idx) < 0.25) {
			//printf("%f\n", Audio.channelProgress(idx));
			gameStep();
		}
		*/
	}

	/////////////////////////////////////////////////////////////////////////////////////
	// EFFECTS                                                                         //
	/////////////////////////////////////////////////////////////////////////////////////

	@Opcode({ id:0x54, format:"s", description:"" })
	public function TRANS_IMAGE(name:String)
	{
		return this.scene.setTransitionMaskAsync(name);
	}

	private function isSkipping():Bool
	{
		return GameInput.isPressing(Keys.Control);
	}

	@Opcode({ id:0x4A, format:"121", description:"" })
	public function TRANSITION(kind:Int, ms_time:Int, unk1:Int)
	{
		if (this.isSkipping()) ms_time = Std.int(ms_time / 10);
		Log.trace('TRANSITION: $kind, $ms_time');

		scene.setDirectMode(false);
		return this.scene.performTransitionAsync(kind, ms_time);

		/*
		switch (kind) {
			default:

			case 23, 24: // TRANSITION MASK (NO BLEND) (23: REVERSED=0, 24: REVERSED=1)
				return this.scene.performTransitionMaskAsync(ms_time);
				//this.scene.setEffect("transition", {
				//blend   = 0,
				//reverse = ((kind == 24) ? 1 : 0),
				//mask    = this.scene.maskLayer,
				//});
				//ms_time *= 2;
		}

		return Timer2.waitAsync(10);
		*/
		//throw(new NotImplementedException());

	/*
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

				for (local n = 0; n < totalSize; n += step_width)
				{
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
	*/
	}

	@Opcode({ id:0x4B, format:"1222221", description:"" })
	public function ANIMATE_ADD(object_id, inc_x, inc_y, time, unk0, alpha, unk2)
	{
		throw(new NotImplementedException());
		/*
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
		*/
	}

	@Opcode({ id:0x4D, format:"1121", description:"" })
	@Unimplemented
	public function EFFECT(kind:Int, duration:Int, quantity:Int, unk1:Int)
	{
		//throw(new NotImplementedException());
		/*
		local kinds = [null, "quake", "heat"];
		local kind_name = (kind in kinds) ? kinds[kind] : "unknown";

		printf("EFFECT(%d('%s'), %d, %d, %d)\n", kind, kind_name, duration, quantity, unk1);


		switch (kind_name)
		{
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
		*/
	}

	/////////////////////////////////////////////////////////////////////////////////////
	// FLOW                                                                            //
	/////////////////////////////////////////////////////////////////////////////////////

	private function doBinaryOperation(operator:String, left:Int, right:Int):Dynamic
	{
		return switch (operator)
		{
			// JUMP_IF
			case ">="  : left >= right;
			case "<="  : left <= right;
			case "=="  : left == right;
			case "!="  : left != right;
			case ">"   : left >  right;
			case "<"   : left <  right;

			// SET
			case "+"   : left + right;
			case "-"   : left - right;
			case "%"   : left % right;
			case "="   : right;
			case "ref" : this.state.getFlag(right);
			case "rand": MathEx.randomInt(0, right);

			default: throw("Unknown binary_operation::op :: '" + operator + "'");
		}
	}

	static private var ops_set;
	static private var ops_jump_if;

	static public function __init__()
	{
		ops_set = [ "?", "=", "+", "-", "ref", "%", "rand" ];
		ops_jump_if = [ "", ">=", "<=", "==", "!=", ">", "<" ];
	}

	/*
			MAINMENU@000002D4: Executing OP(0x0C) : TIMER_GET : [867,0]...249
			MAINMENU@000002D8: Executing OP(0x01) : JUMP_IF : [4,867,0,50]...true
		*/

	@Opcode({ id:0x01, format:"Of2l.", description:"Jumps if the condition is false" })
	@SkipLog
	public function JUMP_IF(operation:Int, leftFlag:Int, rightValueOrFlag:Int, relativeOffset:Int)
	{
		var isRightFlag = BitUtils.extract(operation, 4, 4) != 0;
		var operator = ops_jump_if[BitUtils.extract(operation, 0, 4)];
		var left = this.state.getFlag(leftFlag);
		var right = isRightFlag
			? this.state.getFlag(rightValueOrFlag)
			: rightValueOrFlag
		;

		var result = doBinaryOperation(operator, left, right);
		//printf("JUMP_IF %d(%d) %s %d(%d)...\n", left_flag, left, operator, right_value_or_flag, right);

		if (!result)
		{
			this.script.jumpRelative(relativeOffset);
			//printf("result: %d\n", result ? 1 : 0);
			//this.TODO();
		}
	}

	// 03 - SET (=+-) op(1) variable(2) kind(1) variable/value(2)          //
	// // [OP.03]: [1, 993, 0, 1000, 0, ] ('12121', 'SET')
	@Opcode({ id:0x03, format:"ofkF.", description:"Sets the value of a flag" })
	public function SET(operation:Int, leftFlag:Int, isRightFlag:Int, rightValueOrFlag:Int)
	{
		var left  = this.state.getFlag(leftFlag);
		var right = (isRightFlag != 0)
			? this.state.getFlag(rightValueOrFlag)
			: rightValueOrFlag
		;

		if (operation == 0)
		{
			this.state.setFlagsRange(0, 1000, 0);
			//printf("**SET_ALL_TEMPORAL_FLAGS_TO_ZERO()\n");
		}
		else
		{
			var value = doBinaryOperation(ops_set[operation], left, right);
			this.state.setFlag(leftFlag, value);
			//if (leftFlag == 996 && value) {
				//this.interface.enabled = false;
				//gameStep();
			//}
			//printf("**SET %d=%d\n", left_flag, this.state.flags[left_flag % State.MAX_FLAGS]);
		}
	}

	@Opcode({ id:0x04, format:"", description:"Ends the execution" })
	public function EXIT()
	{
		throw(new NotImplementedException());
		//this.exit();
	}

	@Opcode({ id:0x06, format:"L1", description:"Jumps always" })
	@SkipLog
	public function JUMP(absolute_position:Int, param)
	{
		this.script.jumpAbsolute(absolute_position);
		//throw(new NotImplementedException());
		//this.jump_absolute(absolute_position);
	}

	@Opcode({ id:0x07, format:"s", description:"Switches to an script" })
	public function SCRIPT(name:String)
	{
		return script.loadAsync(name);
	}

	@Opcode({ id:0x09, format:"s", description:"Calls a script" })
	public function SCRIPT_CALL(name)
	{
		throw(new NotImplementedException());

		//this.load(name, 1);
	}

	@Opcode({ id:0x0A, format:"1", description:"Returns from a script" })
	public function SCRIPT_RET(param)
	{
		throw(new NotImplementedException());

		//this.script_return();
	}

	@Opcode({ id:0xFF, format:"", description:"" })
	public function EOF()
	{
		throw(new NotImplementedException());

		//this.TODO();
	}

	/////////////////////////////////////////////////////////////////////////////////////
	// MENUS                                                                           //
	/////////////////////////////////////////////////////////////////////////////////////

	@Opcode({ id:0x83, format:".", description:"" })
	public function RUN_LOAD()
	{
		throw(new NotImplementedException());
		/*
		this.state.load(100);
		this.TODO();
		*/
	}

	@Opcode({ id:0x84, format:"1", description:"" })
	public function RUN_SAVE(param)
	{
		throw(new NotImplementedException());

		//this.TODO();
	}

	@Opcode({ id:0x88, format:"111", description:"" })
	public function BATTLE(unk1, battle_id, unk3)
	{
		throw(new NotImplementedException());
		/*
		this.TODO();
		this.state.flag_set(916, 1); // WIN
		//this.state.flag_set(916, 0); // LOOSE
		*/
	}

	@Opcode({ id:0x8A, format:"1", description:"" })
	public function UNK_8A(param)
	{
		throw(new NotImplementedException());

		//this.TODO();
	}

	@Opcode({ id:0x8B, format:".", description:"" })
	public function RUN_CONFIG()
	{
		throw(new NotImplementedException());
		/*
		local cfgbg = resman.get_image("CFGBG");
		local mask  = resman.get_mask("CFG_P1M");
		while (1) {
			this.input_update();

			//this.frame_draw();
			//if (draw_interface) this.frame_draw_interface(0);

			cfgbg.drawTo(screen, 0);
			cfgbg.drawTo(screen, 1); // return button
			cfgbg.drawTo(screen, 3); // yes/no options
			cfgbg.drawTo(screen, 6); // volume on
			cfgbg.drawTo(screen, 9); // numeric options

			local hover_kind = mask.images[0].getpixel(mouse.x, mouse.y);

			if (pressedNext()) {
				break;
			}

			this.frame_tick();
		}
		this.TODO();
		*/
	}

	@Opcode({ id:0xE2, format:".", description:"" })
	public function RUN_QLOAD()
	{
		throw(new NotImplementedException());

		/*
		printf("RUN_QLOAD()\n");
		this.state.load(100);
		this.TODO();
		*/
	}

	// Special.
	@Opcode({ id:0x201, format:"", description:"" })
	public function RUN_QSAVE()
	{
		throw(new NotImplementedException());
		/*
		printf("RUN_QSAVE()\n");
		this.state.save(100);
		this.TODO();
		*/
	}

	/////////////////////////////////////////////////////////////////////////////////////
	// TIMER                                                                           //
	/////////////////////////////////////////////////////////////////////////////////////

	@Opcode({ id:0x05, format:"1", description:"Wait until the timer reaches 0" })
	public function TIMER_WAIT(can_skip)
	{
		throw(new NotImplementedException());

		/*
		while (this.state.timer > 0) {
			this.input_update();
			if (can_skip && mouse.click_left) break;
			this.frame_tick();
		}
		*/
	}

	@Opcode({ id:0x0B, format:"2", description:"Sets the timer in ticks. Each tick is 1 frame. And the game runs at 25fps. 40 ticks = 1 second." })
	public function TIMER_SET(ticks)
	{
		throw(new NotImplementedException());
		/*
		this.state.timer_max = this.state.timer = ticks;
		*/
	}

	@Opcode({ id:0x0C, format:"21", description:"Decreases the timer and returns true if reached 0." })
	public function TIMER_DEC(flag, param)
	{
		throw(new NotImplementedException());
		/*
		if (this.state.timer > 0) this.state.timer--;

		this.state.flag_set(flag % State.MAX_FLAGS, (this.state.timer <= 0) ? 1 : 0);
		return this.state.timer;
		//this.TODO();
		*/
	}

	@Opcode({ id:0x82, format:"21", description:"" })
	public function WAIT(delay_ms:Int, unk1:Int)
	{
		if (state.debug) delay_ms = Std.int(delay_ms / 10);
		return Timer2.waitAsync(delay_ms / 1000);
		throw(new NotImplementedException());
		/*
		local timer = Timer(delay_ms);
		while (!timer.ended) {
			if (this.skipping()) break;
			timer.update(ms_per_frame);
			gameStep();
		}
		*/
	}

	/////////////////////////////////////////////////////////////////////////////////////
	// SCENE                                                                           //
	/////////////////////////////////////////////////////////////////////////////////////

	@Opcode({ id:0x46, format:"22221s", description:"Puts a background in a position" })
	public function BACKGROUND(x:Int, y:Int, unk1:Int, unk2:Int, index:Int, name:String)
	{
		return scene.getLayerWithName('background').putObjectAsync(0, x, y, name, Anchor.centerCenter);
	}

	@Opcode({ id:0x47, format:"11", description:"" })
	public function BACKGROUND_COLOR(colorIndex:Int, param:Int)
	{
		var color = switch(colorIndex) {
			case 0: HtmlColors.black;
			default: throw('Unknown colorIndex: $colorIndex');
		};
		scene.getLayerWithName('background').putColor(0, 400, 300, 800, 600, color, Anchor.centerCenter);
	}

	@Opcode({ id:0x68, format:"2221", description:"Sets background size and position x and y coords are the center points of the viewport." })
	public function BACKGROUND_VIEWPORT(size:Int, x:Int, y:Int, unk4:Int)
	{
		return scene.getLayerWithName('background').setLayerViewPort(size / 100.0, x, y);
	}

	@Opcode({ id:0x48, format:"122221s", description:"" })
	@Unimplemented
	public function CHARA_PUT(index:Int, x:Int, y:Int, unk1:Int, unk2:Int, index2:Int, name:String)
	{
		return scene.getLayerWithName("layer2").putObjectAsync(
			index,
			x,
			y,
			name,
			Anchor.topLeft
		);
		//throw(new NotImplementedException());
		/*
		local object = this.scene.sprites_l1[index];
		object.index = index2;
		object.name = name;
		object.alpha = 1.0;
		object.size = 1.0;
		object.rotation = 0.0;
		object.enabled = true;
		object.setXY(x, y, 0.0, 0.0);

		this.TODO();
		*/
	}

	// OBJ_PUT : [243,276,0,0,0,"EC_001"]
	@Opcode({ id:0x73, format:"22221s", description:"" })
	public function OBJ_PUT(x:Int, y:Int, unk1:Int, unk2:Int, unk3:Int, name:String)
	{
		return scene.getLayerWithName('objects').putObjectAsync(0, x, y, name, Anchor.topLeft);
		/*
		local object = this.scene.overlay;
		object.index = 0;
		object.x = x;
		object.y = y;
		object.name = name;
		object.alpha = 1.0;
		object.enabled = true;

		this.TODO();
		*/
	}

	@Opcode({ id:0x49, format:"2.", description:"Clears an object/character in layer1 (0=LEFT, 1=CENTER, 2=RIGHT)" })
	@SkipLog
	public function CLEAR_L1(index:Int)
	{
		scene.getLayerWithName('layer1').removeObject(index);
	}

	@Opcode({ id:0xB8, format:"2.", description:"" })
	@SkipLog
	public function CLEAR_L2(index:Int)
	{
		scene.getLayerWithName('layer2').removeObject(index);
	}

	@Opcode({ id:0x74, format:"2", description:"" })
	@SkipLog
	public function OBJ_CLEAR(index:Int)
	{
		scene.getLayerWithName('objects').removeObject(index);
	}

	/////////////////////////////////////////////////////////////////////////////////////
	// TEXT                                                                            //
	/////////////////////////////////////////////////////////////////////////////////////

	public function TEXT_COMMON(text_id:Int, text:String, ?title:String)
	{
		var deferred = new Deferred<Dynamic>();
		scene.setTextAsync(text, isSkipping() ? 0 : 0.05).then(function(?e)
		{
			Signal.addAnyOnce([GameInput.onClick, GameInput.onKeyPress], function(e:Event) {
				scene.setTextAsync('', 0).then(function(?e)
				{
					deferred.resolve(null);
				});
			});
		});
		return deferred.promise;

		/*
		if (reset) {
			this.interface.text_title = "";
			this.interface.text_body = "";
		}
		local trans = translation.get(text_id, text, title);
		this.interface.textProgress = this.interface.text_body.len();
		this.interface.enabled     = true;
		this.interface.text_id     = text_id;
		this.interface.text_title += trans.title;
		this.interface.text_body  += trans.text;
		this.interface.text_title_ori = title;
		this.interface.text_body_ori  = text;
		this.interface.skip = false;

		this.interface.waitingSkip = true;
		this.loopUntilAnimationEnds();
		this.interface.waitingSkip = false;

		//this.TODO();
		Audio.channelStop(this.voice_channel);
		*/
	}

	@Opcode({ id:0x41, format:"2.t", description:"" })
	public function TEXT(text_id:Int, text:String)
	{
		return TEXT_COMMON(text_id, text);
	}

	@Opcode({ id:0x42, format:"2..tt", description:"" })
	public function TEXT2(text_id:Int, title:String, text:String)
	{
		return TEXT_COMMON(text_id, text, title);
	}

	@Opcode({ id:0xB6, format:"2t", description:"" })
	public function TEXT_ADD(text_id, text)
	{
		throw(new NotImplementedException());
		//RIO_OP_TEXT.TEXT_COMMON(text_id, "", text, 0);
	}

	@Opcode({ id:0x08, format:"2", description:"Sets the size of the text (00=small, 01=big)" })
	public function TEXT_SIZE(size)
	{
		throw(new NotImplementedException());
		//this.TODO();
	}

	public function OPTION_SELECT_common(options)
	{
		throw(new NotImplementedException());
		/*
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

		while (selectedOption == null)
		{
			input.update();

			option_clicked = false;

			if (::input.pad_pressed("up"    )) { option_index--; using_mouse = false; option_index = clamp(option_index, 0, options.len() - 1); }
			if (::input.pad_pressed("down"  )) { option_index++; using_mouse = false; option_index = clamp(option_index, 0, options.len() - 1); }
			if (::input.pad_pressed("accept")) { option_clicked = true; using_mouse = false; }
			if (::input.pad_pressed("cancel")) { }

			if (::input.mouseMoved()) using_mouse = true;
			if (::input.mouse.pressed(0))
			{
				option_clicked = true;
				using_mouse = true;
			}

			if (using_mouse)
			{
				option_index = -1;
				foreach (n, option in options) if (::input.mouseInRect(option.rect)) option_index = n;
			}

			this.drawTo(screen);

			foreach (n, option in options)
			{
				local selwnd = selwnd0;
				//if (pointInRect({x=::input.mouse.x, y=::input.mouse.y}, option.rect)) {
				if (n == option_index)
				{
					selwnd = selwnd1;
					if (option_clicked)
					{
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
		*/
	}

	//  02.? [0200], [7201], "Tell her", [01520307], @t001_02b@, [7301], "Don't tell her", [01530307], @t001_02c@
	@Opcode({ id:0x02, format:"C[2t3c]", description:"Show a list of options" })
	public function OPTION_SELECT(roptions)
	{
		throw(new NotImplementedException());
		/*
		printf("::: %s\n\n\n", object_to_string(roptions));
		local options = [];
		foreach (n, option in roptions) {
			local option_info = {};
			option_info.n       <- n;
			option_info.text_id <- option[0];
			option_info.text    <- option[1];
			option_info.unk1    <- option[2];
			option_info.result  <- option[3];
			options.push(option_info);
		}
		RIO_OP_TEXT.OPTION_SELECT_common(options);
		this.TODO();
		*/
	}

}
